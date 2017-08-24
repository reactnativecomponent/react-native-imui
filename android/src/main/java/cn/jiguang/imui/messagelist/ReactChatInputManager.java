package cn.jiguang.imui.messagelist;

import android.Manifest;
import android.app.Activity;
import android.util.Log;
import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.List;
import java.util.Map;

import cn.jiguang.imui.chatinput.ChatInputView;
import cn.jiguang.imui.chatinput.listener.OnClickEditTextListener;
import cn.jiguang.imui.chatinput.listener.OnMenuClickListener;
import cn.jiguang.imui.chatinput.listener.RecordVoiceListener;
import cn.jiguang.imui.chatinput.model.FileItem;
import cn.jiguang.imui.chatinput.model.VideoItem;

/**
 * Created by caiyaoguan on 2017/5/22.
 */

public class ReactChatInputManager extends ViewGroupManager<ChatInputView> {

    private static final String REACT_CHAT_INPUT = "RCTChatInput";
    private static final String TAG = "RCTChatInput";

    private static final String ON_SEND_TEXT_EVENT = "onSendText";
    private static final String ON_SEND_FILES_EVENT = "onSendGalleryFiles";
    private static final String SWITCH_TO_MIC_EVENT = "onSwitchToMicrophoneMode";
    private static final String SWITCH_TO_ACTION_EVENT = "onSwitchToActionMode";
    private static final String SWITCH_TO_EMOJI_EVENT = "onSwitchToEmojiMode";
    private static final String TAKE_PICTURE_EVENT = "onTakePicture";

    private static final String START_RECORD_VIDEO_EVENT = "onStartRecordVideo";
    private static final String FINISH_RECORD_VIDEO_EVENT = "onFinishRecordVideo";
    private static final String CANCEL_RECORD_VIDEO_EVENT = "onCancelRecordVideo";

    private static final String START_RECORD_VOICE_EVENT = "onStartRecordVoice";
    private static final String FINISH_RECORD_VOICE_EVENT = "onFinishRecordVoice";
    private static final String RECORD_VOICE_EVENT = "onRecordingVoice";
    private static final String CANCEL_RECORD_VOICE_EVENT = "onCancelRecordVoice";

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
            public void onSendFiles(List<FileItem> list) {
                if (list == null || list.isEmpty()) {
                    return;
                }
                WritableMap event = Arguments.createMap();
                WritableArray array = new WritableNativeArray();
                for (FileItem fileItem : list) {
                    WritableMap map = new WritableNativeMap();
                    if (fileItem.getType().ordinal() == 0) {
                        map.putString("mediaType", "image");
                    } else {
                        map.putString("mediaType", "video");
                        map.putInt("duration", (int) ((VideoItem) fileItem).getDuration());
                    }
                    map.putString("mediaPath", fileItem.getFilePath());
                    array.pushMap(map);
                }
                event.putArray("mediaFiles", array);
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(), ON_SEND_FILES_EVENT, event);
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
            @Override
            public void onStartRecord() {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        START_RECORD_VOICE_EVENT, null);
            }

            @Override
            public void onFinishRecord(String voiceFile, int duration) {
                WritableMap event = Arguments.createMap();
                event.putString("mediaPath", voiceFile);
                event.putString("duration", Integer.toString(duration));
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        FINISH_RECORD_VOICE_EVENT, event);
            }

            @Override
            public void onCancelRecord() {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        CANCEL_RECORD_VOICE_EVENT, null);
            }

            @Override
            public void onRecording(boolean cancelAble, int dbSize, int time) {
                WritableMap event = Arguments.createMap();
                event.putString("status", cancelAble ? "1" : "0");
                event.putString("db", Integer.toString(dbSize));
                event.putString("time", Integer.toString(time));
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(chatInput.getId(),
                        RECORD_VOICE_EVENT, event);
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
                .put(ON_SEND_FILES_EVENT, MapBuilder.of("registrationName", ON_SEND_FILES_EVENT))
                .put(SWITCH_TO_MIC_EVENT, MapBuilder.of("registrationName", SWITCH_TO_MIC_EVENT))
                .put(SWITCH_TO_ACTION_EVENT, MapBuilder.of("registrationName", SWITCH_TO_ACTION_EVENT))
                .put(SWITCH_TO_EMOJI_EVENT, MapBuilder.of("registrationName", SWITCH_TO_EMOJI_EVENT))
                .put(TAKE_PICTURE_EVENT, MapBuilder.of("registrationName", TAKE_PICTURE_EVENT))
                .put(START_RECORD_VIDEO_EVENT, MapBuilder.of("registrationName", START_RECORD_VIDEO_EVENT))
                .put(FINISH_RECORD_VIDEO_EVENT, MapBuilder.of("registrationName", FINISH_RECORD_VIDEO_EVENT))
                .put(CANCEL_RECORD_VIDEO_EVENT, MapBuilder.of("registrationName", CANCEL_RECORD_VIDEO_EVENT))
                .put(START_RECORD_VOICE_EVENT, MapBuilder.of("registrationName", START_RECORD_VOICE_EVENT))
                .put(FINISH_RECORD_VOICE_EVENT, MapBuilder.of("registrationName", FINISH_RECORD_VOICE_EVENT))
                .put(RECORD_VOICE_EVENT, MapBuilder.of("registrationName", RECORD_VOICE_EVENT))
                .put(CANCEL_RECORD_VOICE_EVENT, MapBuilder.of("registrationName", CANCEL_RECORD_VOICE_EVENT))
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
