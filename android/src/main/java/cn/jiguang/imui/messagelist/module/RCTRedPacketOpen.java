package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IRedPacketOpen;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTRedPacketOpen extends RCTExtend implements IRedPacketOpen {

    public final static String HAS_RED_PACKET = "hasRedPacket";
    public final static String SERIA_NO = "seriaNo";
    public final static String TIP_MSG = "tipMsg";

    public final static String SEND_ID = "sendId";
    public final static String OPEN_ID = "openId";

    private String hasRedPacket;
    private String seriaNo;
    private String tipMsg;
    private String sendId;
    private String openId;

    public RCTRedPacketOpen(String hasRedPacket, String seriaNo, String tipMsg, String sendId, String openId) {
        this.hasRedPacket = hasRedPacket;
        this.seriaNo = seriaNo;
        this.tipMsg = tipMsg;
        this.sendId = sendId;
        this.openId = openId;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(HAS_RED_PACKET, hasRedPacket);
        json.addProperty(SERIA_NO, seriaNo);
        json.addProperty(TIP_MSG, tipMsg);
        json.addProperty(SEND_ID, sendId);
        json.addProperty(OPEN_ID, openId);
        return json;
    }

    @Override
    public String getOpenId() {
        return openId;
    }

    @Override
    public String getSendId() {
        return sendId;
    }

    @Override
    public String getHasRedPacket() {
        return hasRedPacket;
    }

    @Override
    public String getSeriaNo() {
        return seriaNo;
    }

    @Override
    public String getTipMsg() {
        return tipMsg;
    }
}
