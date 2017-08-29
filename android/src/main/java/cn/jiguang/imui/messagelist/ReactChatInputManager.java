package cn.jiguang.imui.messagelist;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.Map;

import cn.jiguang.imui.chatinput.ChatInputView;
import cn.jiguang.imui.chatinput.listener.OnClickEditTextListener;
import cn.jiguang.imui.chatinput.listener.OnMenuClickListener;
import cn.jiguang.imui.chatinput.listener.RecordVoiceListener;


public class ReactChatInputManager extends ViewGroupManager<ChatInputView> {

    private static final String REACT_CHAT_INPUT = "RCTChatInput";
    private static final String TAG = "RCTChatInput";

    private static final String SWITCH_TO_MIC_EVENT = "onSwitchToMicrophoneMode";
    private static final String SWITCH_TO_ACTION_EVENT = "onSwitchToActionMode";
    private static final String SWITCH_TO_EMOJI_EVENT = "onSwitchToEmojiMode";

    private static final String ON_SEND_TEXT_EVENT = "onSendText";
    private static final String ON_SEND_VIDEO = "onSendVideo";
    private static final String ON_SEND_VOICE = "onSendVoice";

    private static final String ON_TOUCH_EDIT_TEXT_EVENT = "onTouchEditText";
    private static final String ON_EDIT_TEXT_CHANGE_EVENT = "onEditTextChange";
    private final int REQUEST_PERMISSION = 0x0001;

    @Override
    public String getName() {
        return REACT_CHAT_INPUT;
    }

    @Override
    public void onDropViewInstance(ChatInputView view) {
        Log.w(TAG, "onDropViewInstance");
        super.onDropViewInstance(view);
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        Log.w(TAG, "onCatalystInstanceDestroy");
    }

    @Override
    protected ChatInputView createViewInstance(final ThemedReactContext reactContext) {
        Log.w(TAG, "createViewInstance");
        final Activity activity = reactContext.getCurrentActivity();
        final ChatInputView chatInput = new ChatInputView(activity, null);
        chatInput.setMenuContainerHeight(666);
        // Use default layout
        chatInput.setMenuClickListener(new OnMenuClickListener() {
            @Override
            public boolean onSendTextMessage(CharSequence input) {
                if (input.length() == 0) {
                    return false;
                }
                WritableMap event = Arguments.createMap();
                event.putString("text", input.toString());
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(), ON_SEND_TEXT_EVENT, event);
                return true;
            }

            @Override
            public void switchToMicrophoneMode() {
                Activity activity = reactContext.getCurrentActivity();
                String[] perms = new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO
                };

//                if ((ActivityCompat.checkSelfPermission(activity, perms[0]) != PackageManager.PERMISSION_GRANTED
//                        && ActivityCompat.checkSelfPermission(activity, perms[1]) != PackageManager.PERMISSION_GRANTED
//                        && ActivityCompat.checkSelfPermission(activity, perms[2]) != PackageManager.PERMISSION_GRANTED
//                        && ActivityCompat.checkSelfPermission(activity, perms[3]) != PackageManager.PERMISSION_GRANTED)) {
//                    ActivityCompat.requestPermissions(activity, perms, REQUEST_PERMISSION);
//                }
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        SWITCH_TO_MIC_EVENT, null);
            }

            @Override
            public void switchToActionMode() {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        SWITCH_TO_ACTION_EVENT, null);
            }

            @Override
            public void switchToEmojiMode() {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        SWITCH_TO_EMOJI_EVENT, null);
            }
        });

        chatInput.setRecordVoiceListener(new RecordVoiceListener() {
            Dialog dialog;
            TimerTipView view;

            @Override
            public void onStartRecord() {
                showDialog();
            }

            @Override
            public void onFinishRecord(String voiceFile, int duration) {
                hideDialog();
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
                view.updateStatus(dbSize, cancelAble ? 1 : 0, "" + time);
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
            public void onTouchEditText() {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        ON_TOUCH_EDIT_TEXT_EVENT, null);
            }

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
        if (isDismiss) {
            chatInputView.dismissMenuLayout();
        }
    }

    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put(ON_SEND_TEXT_EVENT, MapBuilder.of("registrationName", ON_SEND_TEXT_EVENT))
                .put(SWITCH_TO_MIC_EVENT, MapBuilder.of("registrationName", SWITCH_TO_MIC_EVENT))
                .put(SWITCH_TO_ACTION_EVENT, MapBuilder.of("registrationName", SWITCH_TO_ACTION_EVENT))
                .put(SWITCH_TO_EMOJI_EVENT, MapBuilder.of("registrationName", SWITCH_TO_EMOJI_EVENT))
                .put(ON_SEND_VIDEO, MapBuilder.of("registrationName", ON_SEND_VIDEO))
                .put(ON_SEND_VOICE, MapBuilder.of("registrationName", ON_SEND_VOICE))
                .put(ON_TOUCH_EDIT_TEXT_EVENT, MapBuilder.of("registrationName", ON_TOUCH_EDIT_TEXT_EVENT))
                .put(ON_EDIT_TEXT_CHANGE_EVENT, MapBuilder.of("registrationName", ON_EDIT_TEXT_CHANGE_EVENT))
                .build();
    }

    @Override
    public void addView(ChatInputView parent, View child, int index) {
        parent.addActionView(child, index);
        Log.w(TAG, "name:" + child.getClass().getName());
        Log.w(TAG, "index:" + index);
    }
}
