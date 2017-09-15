package cn.jiguang.imui.messagelist;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cn.jiguang.imui.chatinput.ChatInputView;
import cn.jiguang.imui.chatinput.listener.OnClickEditTextListener;
import cn.jiguang.imui.chatinput.listener.OnMenuClickListener;
import cn.jiguang.imui.chatinput.listener.RecordVoiceListener;
import cn.jiguang.imui.messagelist.module.RCTMember;
import cn.jiguang.imui.messagelist.module.RCTMessage;


public class ReactChatInputManager extends ViewGroupManager<ChatInputView> {

    private static final String REACT_CHAT_INPUT = "RCTChatInput";
    private static final String TAG = "RCTChatInput";

    private static final String ON_SEND_TEXT_EVENT = "onSendText";
    private static final String ON_SEND_VOICE = "onSendVoice";

    private static final String ON_EDIT_TEXT_CHANGE_EVENT = "onEditTextChange";
    private static final String ON_FEATURE_VIEW_EVENT = "onFeatureView";
    private static final String ON_SHOW_KEY_BOARD_EVENT = "onShowKeyboard";
    private final int REQUEST_PERMISSION = 0x0001;

    public static final String RCT_DATA = "members";
    public static final String RCT_AIT_MEMBERS_ACTION = "cn.jiguang.imui.chatinput.intent.aitMembers";


    private ReactContext mContext;
    private ChatInputView chatInput;
    private Map<String, RCTMember> idList = new HashMap();

    @Override
    public String getName() {
        return REACT_CHAT_INPUT;
    }

    @Override
    public void onDropViewInstance(ChatInputView view) {
        Log.w(TAG, "onDropViewInstance");
        super.onDropViewInstance(view);
        try {
            mContext.unregisterReceiver(RCTChatInputReceiver);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        Log.w(TAG, "onCatalystInstanceDestroy");
    }

    @Override
    protected ChatInputView createViewInstance(final ThemedReactContext reactContext) {
        Log.w(TAG, "createViewInstance");

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(RCT_AIT_MEMBERS_ACTION);

        mContext = reactContext;
//        SessorUtil.getInstance(reactContext).register(true);
        mContext.registerReceiver(RCTChatInputReceiver, intentFilter);

        final Activity activity = reactContext.getCurrentActivity();
        chatInput = new ChatInputView(activity, null);
        chatInput.setMenuContainerHeight(666);
        // Use default layout
        chatInput.setMenuClickListener(new OnMenuClickListener() {
            @Override
            public boolean onSendTextMessage(CharSequence input) {
                if (input.length() == 0) {
                    return false;
                }
                WritableMap event = Arguments.createMap();
                WritableArray array = Arguments.createArray();

                if (!idList.isEmpty()) {
                    // 移走后面又删掉的账号
                    removeInvalidAccount(idList, input.toString());
                    // 替换文本中的账号为昵称
//                    input =  replaceNickName(idList, input.toString());

                    for (Map.Entry<String, RCTMember> entry : idList.entrySet()) {
                        array.pushString(entry.getValue().getContactId());
                    }
                }

                event.putString("text", input.toString());
                event.putArray("ids", array);
                idList.clear();
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(), ON_SEND_TEXT_EVENT, event);
                return true;
            }

            @Override
            public void onFeatureView(int inputHeight, int showType) {
                WritableMap event = Arguments.createMap();
                event.putInt("inputHeight", inputHeight);
                event.putInt("showType", showType);
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(), ON_FEATURE_VIEW_EVENT, event);
            }

            @Override
            public void onShowKeyboard(int inputHeight, int showType) {
                WritableMap event = Arguments.createMap();
                event.putInt("inputHeight", inputHeight);
                event.putInt("showType", showType);
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(), ON_SHOW_KEY_BOARD_EVENT, event);
            }
        });

        chatInput.setRecordVoiceListener(new RecordVoiceListener() {
            Dialog dialog;
            TimerTipView view;
            Handler handler = new Handler(){
                @Override
                public void handleMessage(Message msg) {
                    switch (msg.what){
                        case 1:
                            hideDialog();
                            break;
                    }
                }
            };
            @Override
            public void onStartRecord() {
                showDialog();
            }

            @Override
            public void onFinishRecord(String voiceFile, boolean isTooLong,int duration) {
                if(TextUtils.isEmpty(voiceFile)){
                    view.updateStatus(0, 2, 0);
                    handler.sendEmptyMessageDelayed(1,500);
                    return;
                }
                if(isTooLong){
                    view.updateStatus(0, 3, 0);
                    handler.sendEmptyMessageDelayed(1,500);
                }else {
                    hideDialog();
                }
                WritableMap event = Arguments.createMap();
                event.putString("mediaPath", voiceFile);
                event.putString("duration", Integer.toString(duration));
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        ON_SEND_VOICE, event);
            }

            @Override
            public void onCancelRecord() {
                hideDialog();
            }

            @Override
            public void onRecording(boolean cancelAble, int dbSize, int time) {
                view.updateStatus(dbSize, cancelAble ? 1 : 0, time);
            }

            void hideDialog() {
                if (dialog != null && dialog.isShowing()) {
                    dialog.dismiss();
                    dialog = null;
                }
            }

            void showDialog() {
                dialog = new Dialog(reactContext.getCurrentActivity(), R.style.Theme_audioDialog);
                view = new TimerTipView(reactContext);
                dialog.setContentView(view);
                dialog.show();
            }
        });

        chatInput.setOnClickEditTextListener(new OnClickEditTextListener() {

            @Override
            public void onTextChanged(String changeText) {
                if ("@".equals(changeText)) {
                    WritableMap event = Arguments.createMap();
                    event.putString("text", changeText);
                    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                            ON_EDIT_TEXT_CHANGE_EVENT, event);
                }
            }
        });
        return chatInput;
    }


    @ReactProp(name = "menuContainerHeight")
    public void setMenuContainerHeight(ChatInputView chatInputView, int height) {
        Log.w(TAG, "Setting menu container height: " + height);
        chatInputView.setMenuContainerHeight(height);
    }

    @ReactProp(name = "isDismissMenuContainer")
    public void dismissMenuContainer(ChatInputView chatInputView, boolean isDismiss) {
        Log.w(TAG, "dismissMenuContainer: " + isDismiss);
        if (isDismiss) {
            chatInputView.dismissMenuLayout();
        }
    }

    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put(ON_SEND_TEXT_EVENT, MapBuilder.of("registrationName", ON_SEND_TEXT_EVENT))
                .put(ON_SEND_VOICE, MapBuilder.of("registrationName", ON_SEND_VOICE))
                .put(ON_EDIT_TEXT_CHANGE_EVENT, MapBuilder.of("registrationName", ON_EDIT_TEXT_CHANGE_EVENT))
                .put(ON_FEATURE_VIEW_EVENT, MapBuilder.of("registrationName", ON_FEATURE_VIEW_EVENT))
                .put(ON_SHOW_KEY_BOARD_EVENT, MapBuilder.of("registrationName", ON_SHOW_KEY_BOARD_EVENT))
                .build();
    }

    @Override
    public void addView(ChatInputView parent, View child, int index) {
        parent.addActionView(child, index);
        Log.w(TAG, "name:" + child.getClass().getName());
        Log.w(TAG, "index:" + index);
    }

    private void removeInvalidAccount(Map<String, RCTMember> selectedMembers, String text) {
        if (TextUtils.isEmpty(text) || selectedMembers.isEmpty()) {
            return;
        }
        Iterator<Map.Entry<String, RCTMember>> entry = selectedMembers.entrySet().iterator();
        while (entry.hasNext()) {
            Map.Entry<String, RCTMember> next = entry.next();
            String account = next.getKey();
            String name =  next.getValue().getName();
            Pattern p = Pattern.compile("(@" + name + " )");
            Matcher matcher = p.matcher(text);
            if (matcher.find()) {
                continue;
            }
            entry.remove();
        }
    }

    private String replaceNickName(Map<String, RCTMember> selectedMembers, String text) {
        if (TextUtils.isEmpty(text) || selectedMembers.isEmpty()) {
            return "";
        }
        for (Map.Entry<String, RCTMember> entry : selectedMembers.entrySet()) {
            String account = entry.getKey();
            String aitName = entry.getValue().getName();
            text = text.replaceAll("(@" + account + " )", "@" + aitName + " ");
        }
        return text;
    }

    private BroadcastReceiver RCTChatInputReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Gson gson = new GsonBuilder().registerTypeAdapter(RCTMessage.class, new RCTChatInputDeserialize())
                    .create();
            if (intent.getAction().equals(RCT_AIT_MEMBERS_ACTION)) {
                String member = intent.getStringExtra(RCT_DATA);
                RCTMember item = gson.fromJson(member, RCTMember.class);
                chatInput.appendReplace(item.getContactId(), item.getName());
                idList.put(item.getContactId(), item);
            }
        }
    };
}
