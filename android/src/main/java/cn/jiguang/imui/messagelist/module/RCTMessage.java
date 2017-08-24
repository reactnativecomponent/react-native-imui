package cn.jiguang.imui.messagelist.module;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IExtend;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.commons.models.IUser;

/**
 * Created by caiyaoguan on 2017/5/24.
 */

public class RCTMessage implements IMessage {

    public static final String MSG_ID = "msgId";
    public static final String STATUS = "status";
    public static final String MSG_TYPE = "msgType";
    public static final String IS_OUTGOING = "isOutgoing";
    public static final String TIME_STRING = "timeString";
    public static final String TIME = "time";
    public static final String MSG_TEXT = "text";
    public static final String MEDIA_FILE_PATH = "mediaPath";
    public static final String DURATION = "duration";
    public static final String PROGRESS = "progress";
    public static final String FROM_USER = "fromUser";
    public static final String EXTEND = "extend";

    final static String TEXT = "text";
    final static String VOICE = "voice";
    final static String IMAGE = "image";
    final static String VIDEO = "video";
    final static String FILE = "file";
    final static String ROBOT = "robot";
    final static String BANK_TRANSFER = "bank_transfer";
    final static String ACCOUNT_NOTICE = "account_notice";
    final static String EVENT = "event";
    final static String LOCATION = "location";
    final static String NOTIFICATION = "notification";
    final static String TIP = "tip";
    final static String RED_PACKET = "red_packet";
    final static String RED_PACKET_OPEN = "red_packet_open";
    final static String LINK = "link";

    private final String msgId;
    private final String statusStr;
    private final MessageStatus status;
    private final String msgTypeStr;
    private final MessageType msgType;
    private final boolean isOutgoing;

    private String timeString;
    private long time;
    private String text;
    private RCTExtend extend;
    private String mediaFilePath;
    private String thumb;
    private long duration = -1;
    private String progress;
    private RCTUser rctUser;
    private static Gson sGSON = new Gson();

    public RCTMessage(String msgId, String status, String msgType, boolean isOutgoing) {
        this.msgId = msgId;
        this.statusStr = status;
        this.msgTypeStr = msgType;
        this.isOutgoing = isOutgoing;

        this.status = getStatus(status);
        this.msgType = getType(msgType, isOutgoing);
    }

    MessageStatus getStatus(String status) {
        switch (status) {
            case "send_failed":
                return MessageStatus.SEND_FAILED;
            case "send_going":
                return MessageStatus.SEND_GOING;
            case "download_failed":
                return MessageStatus.RECEIVE_FAILED;
            default:
                return MessageStatus.SEND_SUCCEED;
        }
    }

    MessageType getType(String msgType, boolean isOutgoing) {
        if (isOutgoing) {
            switch (msgType) {
                case TEXT:
                    return MessageType.SEND_TEXT;
                case VOICE:
                    return MessageType.SEND_VOICE;
                case IMAGE:
                    return MessageType.SEND_IMAGE;
                case VIDEO:
                    return MessageType.SEND_VIDEO;
                case TIP:
                    return MessageType.TIP;
                case EVENT:
                    return MessageType.EVENT;
                case NOTIFICATION:
                    return MessageType.NOTIFICATION;
                case RED_PACKET_OPEN:
                    return MessageType.RED_PACKET_OPEN;
                case RED_PACKET:
                    return MessageType.SEND_RED_PACKET;
                case BANK_TRANSFER:
                    return MessageType.SEND_BANK_TRANSFER;
                case ACCOUNT_NOTICE:
                    return MessageType.SEND_ACCOUNT_NOTICE;
                case LOCATION:
                    return MessageType.SEND_LOCATION;
                case LINK:
                    return MessageType.SEND_LINK;
                default:
                    return MessageType.SEND_CUSTOM;
            }
        } else {
            switch (msgType) {
                case TEXT:
                    return MessageType.RECEIVE_TEXT;
                case VOICE:
                    return MessageType.RECEIVE_VOICE;
                case IMAGE:
                    return MessageType.RECEIVE_IMAGE;
                case VIDEO:
                    return MessageType.RECEIVE_VIDEO;
                case TIP:
                    return MessageType.TIP;
                case EVENT:
                    return MessageType.EVENT;
                case NOTIFICATION:
                    return MessageType.NOTIFICATION;
                case RED_PACKET_OPEN:
                    return MessageType.RED_PACKET_OPEN;
                case RED_PACKET:
                    return MessageType.RECEIVE_RED_PACKET;
                case BANK_TRANSFER:
                    return MessageType.RECEIVE_BANK_TRANSFER;
                case ACCOUNT_NOTICE:
                    return MessageType.RECEIVE_ACCOUNT_NOTICE;
                case LOCATION:
                    return MessageType.RECEIVE_LOCATION;
                case LINK:
                    return MessageType.RECEIVE_LINK;
                default:
                    return MessageType.RECEIVE_CUSTOM;
            }
        }
    }

    @Override
    public String getMsgId() {
        return this.msgId;
    }

    public void setFromUser(RCTUser user) {
        this.rctUser = user;
    }

    @Override
    public IUser getFromUser() {
        return rctUser;
    }

    public void setTimeString(String timeString) {
        this.timeString = timeString;
    }

    @Override
    public String getTimeString() {
        return this.timeString;
    }

    public void setTime(long time) {
        this.time = time;
    }

    @Override
    public long getTime() {
        return time;
    }

    @Override
    public MessageType getType() {
        return msgType;
    }


    @Override
    public MessageStatus getMessageStatus() {
        return status;
    }

    public void setThumb(String thumb) {
        this.thumb = thumb;
    }

    @Override
    public String getThumb() {
        return thumb;
    }

    public void setText(String text) {
        this.text = text;
    }

    @Override
    public String getText() {
        return this.text;
    }

    public void setExtend(RCTExtend extend) {
        this.extend = extend;
    }

    @Override
    public IExtend getExtend() {
        return extend;
    }

    public void setMediaFilePath(String path) {
        this.mediaFilePath = path;
    }

    @Override
    public String getMediaFilePath() {
        return this.mediaFilePath;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    @Override
    public long getDuration() {
        return this.duration;
    }

    public void setProgress(String progress) {
        this.progress = progress;
    }

    @Override
    public String getProgress() {
        return this.progress;
    }

    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        if (msgId != null) {
            json.addProperty(MSG_ID, msgId);
        }
        if (status != null) {
            json.addProperty(STATUS, statusStr);
        }
        if (msgType != null) {
            json.addProperty(MSG_TYPE, msgTypeStr);
        }
        json.addProperty(IS_OUTGOING, isOutgoing);
        if (timeString != null) {
            json.addProperty(TIME_STRING, timeString);
        }
        if (time != 0L) {
            json.addProperty(TIME, time);
        }
        if (text != null) {
            json.addProperty(MSG_TEXT, text);
        }
        if (mediaFilePath != null) {
            json.addProperty(MEDIA_FILE_PATH, mediaFilePath);
        }
        if (duration != -1) {
            json.addProperty(DURATION, duration);
        }
        if (progress != null) {
            json.addProperty(PROGRESS, progress);
        }
        if (extend != null) {
            json.add(EXTEND, extend.toJSON());
        }
        json.add(FROM_USER, rctUser.toJSON());

        return json;
    }


    @Override
    public String toString() {
        return sGSON.toJson(toJSON());
    }
}
