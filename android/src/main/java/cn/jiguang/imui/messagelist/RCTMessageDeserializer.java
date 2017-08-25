package cn.jiguang.imui.messagelist;

import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;

import java.lang.reflect.Type;

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

import static cn.jiguang.imui.messagelist.module.RCTMessage.EXTEND;

/**
 * Created by caiyaoguan on 2017/6/6.
 */

public class RCTMessageDeserializer implements JsonDeserializer<RCTMessage> {


    String getGsonString(JsonObject ext, String key) {
        JsonElement e = ext.get(key);
        return e == null ? null : e.getAsString();
    }

    @Override
    public RCTMessage deserialize(JsonElement jsonElement, Type type, JsonDeserializationContext jsonDeserializationContext)
            throws JsonParseException {
        JsonObject jsonObject = jsonElement.getAsJsonObject();
        JsonObject userObject = jsonObject.get(RCTMessage.FROM_USER).getAsJsonObject();

        String userId = getGsonString(userObject,RCTUser.USER_ID);
        String displayName = getGsonString(userObject,RCTUser.DISPLAY_NAME);
        String avatarPath = getGsonString(userObject,RCTUser.AVATAR_PATH);
        RCTUser rctUser = new RCTUser(userId, displayName, avatarPath);

        String msgId = getGsonString(jsonObject,RCTMessage.MSG_ID);
        String status = getGsonString(jsonObject,RCTMessage.STATUS);
        String msgType = getGsonString(jsonObject,RCTMessage.MSG_TYPE);
        boolean isOutgoing = jsonObject.get(RCTMessage.IS_OUTGOING).getAsBoolean();

        RCTMessage rctMessage = new RCTMessage(msgId, status, msgType, isOutgoing);
        rctMessage.setFromUser(rctUser);
        if (jsonObject.has(RCTMessage.MEDIA_FILE_PATH)) {
            rctMessage.setMediaFilePath(getGsonString(jsonObject,RCTMessage.MEDIA_FILE_PATH));
        }
        if (jsonObject.has(RCTMessage.DURATION)) {
            rctMessage.setDuration(jsonObject.get(RCTMessage.DURATION).getAsLong());
        }
        if (jsonObject.has(RCTMessage.MSG_TEXT)) {
            rctMessage.setText(getGsonString(jsonObject,RCTMessage.MSG_TEXT));
        }
        if (jsonObject.has(RCTMessage.TIME_STRING)) {
            rctMessage.setTimeString(getGsonString(jsonObject,RCTMessage.TIME_STRING));
        }
        if (jsonObject.has(RCTMessage.TIME)) {
            rctMessage.setTime(jsonObject.get(RCTMessage.TIME).getAsLong());
        }
        if (jsonObject.has(RCTMessage.PROGRESS)) {
            rctMessage.setProgress(getGsonString(jsonObject,RCTMessage.PROGRESS));
        }
        if (jsonObject.has(EXTEND)) {
            JsonObject ext = jsonObject.get(EXTEND).getAsJsonObject();
//            Map<String,String> extend = new HashMap<>();
//            for(Map.Entry<String,JsonElement> entry:ext.entrySet()){
//                extend.put(entry.getKey(),entry.getValue().getAsString());
//            }
            RCTExtend extend = null;
            switch (rctMessage.getType()) {
                case SEND_VOICE:
                case RECEIVE_VOICE:
                case SEND_VIDEO:
                case RECEIVE_VIDEO:
                case SEND_FILE:
                case RECEIVE_FILE:
                case SEND_IMAGE:
                case RECEIVE_IMAGE:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        RCTMediaFile e = new RCTMediaFile(getGsonString(ext,RCTMediaFile.THUMB_PATH), getGsonString(ext,RCTMediaFile.PATH),
                                getGsonString(ext,RCTMediaFile.URL));
                        if (ext.has(RCTMediaFile.DISPLAY_NAME)) {
                            e.setDisplayName(getGsonString(ext,RCTMediaFile.DISPLAY_NAME));
                        }
                        if (ext.has(RCTMediaFile.DURATION)) {
                            e.setDuration(ext.get(RCTMediaFile.DURATION).getAsLong());
                        }
                        if (ext.has(RCTMediaFile.HEIGHT)) {
                            e.setHeight(getGsonString(ext,RCTMediaFile.HEIGHT));
                        }
                        if (ext.has(RCTMediaFile.WIDTH)) {
                            e.setWidth(getGsonString(ext,RCTMediaFile.WIDTH));
                        }
                        extend = e;
                    }
                    break;
                case SEND_LOCATION:
                case RECEIVE_LOCATION:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTLocation(getGsonString(ext,RCTLocation.LATITUDE), getGsonString(ext,RCTLocation.LONGITUDE),
                                getGsonString(ext,RCTLocation.ADDRESS));
                    }
                    break;
                case SEND_BANK_TRANSFER:
                case RECEIVE_BANK_TRANSFER:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTBankTransfer(getGsonString(ext,RCTBankTransfer.AMOUNT), getGsonString(ext,RCTBankTransfer.SERIA_NO),
                                getGsonString(ext,RCTBankTransfer.COMMENTS));
                    }
                    break;
                case SEND_ACCOUNT_NOTICE:
                case RECEIVE_ACCOUNT_NOTICE:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTAccountNotice(getGsonString(ext,RCTAccountNotice.TITLE), getGsonString(ext,RCTAccountNotice.TIME),
                                getGsonString(ext,RCTAccountNotice.DATE), getGsonString(ext,RCTAccountNotice.AMOUNT),
                                getGsonString(ext,RCTAccountNotice.BODY), getGsonString(ext,RCTAccountNotice.SERIA_NO));
                    }
                    break;
                case SEND_RED_PACKET:
                case RECEIVE_RED_PACKET:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTRedPacket(getGsonString(ext,RCTRedPacket.TYPE), getGsonString(ext,RCTRedPacket.COMMENTS),
                                getGsonString(ext,RCTRedPacket.SERIA_NO));
                    }
                    break;
                case SEND_LINK:
                case RECEIVE_LINK:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = ext.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTLink(getGsonString(ext,RCTLink.TITLE), getGsonString(ext,RCTLink.DESCRIBE),
                                getGsonString(ext,RCTLink.IMAGE), getGsonString(ext,RCTLink.LINK_URL));
                    }
                    break;
                case RED_PACKET_OPEN:
                    if (jsonObject.has(RCTMessage.EXTEND)) {
                        ext = jsonObject.get(RCTMessage.EXTEND).getAsJsonObject();
                        extend = new RCTRedPacketOpen(getGsonString(ext,RCTRedPacketOpen.HAS_RED_PACKET), getGsonString(ext,RCTRedPacketOpen.SERIA_NO),
                                getGsonString(ext,RCTRedPacketOpen.TIP_MSG), getGsonString(ext,RCTRedPacketOpen.SEND_ID), getGsonString(ext,RCTRedPacketOpen.OPEN_ID));
                    }
                    break;
                default:
            }
            rctMessage.setExtend(extend);
        }
        return rctMessage;
    }
}
