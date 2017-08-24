package cn.jiguang.imui.messagelist;


import android.content.Intent;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerModule;

import cn.jiguang.imui.messagelist.module.RCTAccountNotice;
import cn.jiguang.imui.messagelist.module.RCTBankTransfer;
import cn.jiguang.imui.messagelist.module.RCTExtend;
import cn.jiguang.imui.messagelist.module.RCTLink;
import cn.jiguang.imui.messagelist.module.RCTLocation;
import cn.jiguang.imui.messagelist.module.RCTMediaFile;
import cn.jiguang.imui.messagelist.module.RCTMessage;
import cn.jiguang.imui.messagelist.module.RCTRedPacket;
import cn.jiguang.imui.messagelist.module.RCTRedPacketOpen;
import cn.jiguang.imui.messagelist.module.RCTUser;
import cn.jiguang.imui.utils.TimeUtil;

/**
 * Created by caiyaoguan on 2017/6/2.
 */

public class AuroraIMUIModule extends ReactContextBaseJavaModule {
    private static final String MSG_ID = "_id";
    private static final String STATUS = "status";
    private static final String MSG_TYPE = "msgType";
    private static final String IS_OUTGOING = "direct";
    private static final String TIME_STRING = "createdAt";
    private static final String TIME = "time";
    private static final String TEXT = "content";
    private static final String MEDIA_FILE_PATH = "mediaPath";
    private static final String DURATION = "duration";
    private static final String PROGRESS = "progress";
    private static final String FROM_USER = "user";
    private static final String EXTEND = "extend";

    private static final String USER_ID = "_id";
    private final String DISPLAY_NAME = "name";
    private final String AVATAR_PATH = "avatar";

    private final String REACT_MSG_LIST_MODULE = "AuroraIMUIModule";

    public AuroraIMUIModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_MSG_LIST_MODULE;
    }

    @Override
    public void initialize() {
        super.initialize();
        UIImplementation t;
        UIManagerModule a;
    }

    @ReactMethod
    public void appendMessages(ReadableArray messages) {
        String[] rctMessages = new String[messages.size()];
        for (int i = 0; i < messages.size(); i++) {
            RCTMessage rctMessage = configMessage(messages.getMap(i));
            rctMessages[i] = rctMessage.toString();
        }
        Intent intent = new Intent();
        intent.setAction(ReactMsgListManager.RCT_APPEND_MESSAGES_ACTION);
        intent.putExtra("messages", rctMessages);
        getReactApplicationContext().sendBroadcast(intent);
    }

    @ReactMethod
    public void updateMessage(ReadableMap message) {
        RCTMessage rctMessage = configMessage(message);
        Intent intent = new Intent();
        intent.setAction(ReactMsgListManager.RCT_UPDATE_MESSAGE_ACTION);
        intent.putExtra("message", rctMessage.toString());
        getReactApplicationContext().sendBroadcast(intent);
    }

    @ReactMethod
    public void insertMessagesToTop(ReadableArray messages) {
        String[] rctMessages = new String[messages.size()];
        for (int i = 0; i < messages.size(); i++) {
            RCTMessage rctMessage = configMessage(messages.getMap(i));
            rctMessages[i] = rctMessage.toString();
        }
        Intent intent = new Intent();
        intent.setAction(ReactMsgListManager.RCT_INSERT_MESSAGES_ACTION);
        intent.putExtra("messages", rctMessages);
        getReactApplicationContext().sendBroadcast(intent);
    }

    @ReactMethod
    public void insertMessage(ReadableMap message) {
    }

    @ReactMethod
    public void deleteMessage(ReadableMap message) {
    }

    private RCTMessage configMessage(ReadableMap message) {
        Log.d("AuroraIMUIModule", "configure message: " + message);
        RCTMessage rctMsg = new RCTMessage(message.getString(MSG_ID),
                message.getString(STATUS), message.getString(MSG_TYPE),
                "0".equals(message.getString(IS_OUTGOING)));
        RCTExtend extend = null;
        ReadableMap ext;
        switch (rctMsg.getType()) {
            case SEND_VOICE:
            case RECEIVE_VOICE:
            case SEND_VIDEO:
            case RECEIVE_VIDEO:
            case SEND_FILE:
            case RECEIVE_FILE:
            case SEND_IMAGE:
            case RECEIVE_IMAGE:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    RCTMediaFile e = new RCTMediaFile(ext.getString("thumbPath"), ext.getString("path"), ext.getString("url"));
                    if (ext.hasKey("displayName")) {
                        e.setDisplayName(ext.getString("displayName"));
                    }
                    if (ext.hasKey("duration")) {
                        try {
                            e.setDuration(Long.parseLong(ext.getString("duration")));
                        } catch (NumberFormatException e1) {
                            e1.printStackTrace();
                        }
                    }
                    if (ext.hasKey("height")) {
                        e.setHeight(ext.getString("height"));
                    }
                    if (ext.hasKey("width")) {
                        e.setWidth(ext.getString("width"));
                    }
                    extend = e;
                }
                break;
            case SEND_LOCATION:
            case RECEIVE_LOCATION:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTLocation(ext.getString("latitude"), ext.getString("longitude"), ext.getString("address"));
                }
                break;
            case SEND_BANK_TRANSFER:
            case RECEIVE_BANK_TRANSFER:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTBankTransfer(ext.getString("amount"), ext.getString("serialNo"), ext.getString("comments"));
                }
                break;
            case SEND_ACCOUNT_NOTICE:
            case RECEIVE_ACCOUNT_NOTICE:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTAccountNotice(ext.getString("title"), ext.getString("time"), ext.getString("date"),
                            ext.getString("amount"), ext.getString("body"), ext.getString("serialNo"));
                }
                break;
            case SEND_RED_PACKET:
            case RECEIVE_RED_PACKET:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTRedPacket(ext.getString("type"), ext.getString("comments"), ext.getString("serialNo"));
                }
                break;
            case SEND_LINK:
            case RECEIVE_LINK:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTLink(ext.getString("title"), ext.getString("describe"), ext.getString("image"), ext.getString("linkUrl"));
                }
                break;
            case RED_PACKET_OPEN:
                if (message.hasKey(EXTEND)) {
                    ext = message.getMap(EXTEND);
                    extend = new RCTRedPacketOpen(ext.getString("hasRedPacket"), ext.getString("serialNo"), ext.getString("tipMsg"),
                            ext.getString("sendId"), ext.getString("openId"));
                }
                break;
            case SEND_CUSTOM:
            case RECEIVE_CUSTOM:
            case TIP:
            case NOTIFICATION:
            case EVENT:

            case SEND_TEXT:
            case RECEIVE_TEXT:
                rctMsg.setText(message.getString(TEXT));
                break;
            default:
                rctMsg.setText(message.getString(TEXT));
        }
        rctMsg.setExtend(extend);
        ReadableMap user = message.getMap(FROM_USER);
        RCTUser rctUser = new RCTUser(user.getString(USER_ID), user.getString(DISPLAY_NAME),
                user.getString(AVATAR_PATH));
        Log.d("AuroraIMUIModule", "fromUser: " + rctUser);
        rctMsg.setFromUser(rctUser);
        if (message.hasKey(TIME_STRING)) {
            String timeString = message.getString(TIME_STRING);
            if (timeString != null) {

                try {
                    rctMsg.setTime(Long.parseLong(timeString) * 1000);
                    rctMsg.setTimeString(TimeUtil.getTimeShowString(rctMsg.getTime(), false));
                } catch (NumberFormatException e) {
                    rctMsg.setTime(0L);
                    rctMsg.setTimeString(timeString);
                    e.printStackTrace();
                }
            }

        }
        if (message.hasKey(PROGRESS)) {
            String progress = message.getString(PROGRESS);
            if (progress != null) {
                rctMsg.setProgress(progress);
            }
        }
        return rctMsg;
    }

    @ReactMethod
    public void scrollToBottom() {
        Intent intent = new Intent();
        intent.setAction(ReactMsgListManager.RCT_SCROLL_TO_BOTTOM_ACTION);
        getReactApplicationContext().sendBroadcast(intent);
    }


}
