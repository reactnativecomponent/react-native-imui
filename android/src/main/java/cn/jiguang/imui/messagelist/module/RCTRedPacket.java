package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IRedPacket;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTRedPacket extends RCTExtend implements IRedPacket {

    public final static String TYPE = "type";
    public final static String COMMENTS = "comments";
    public final static String SERIA_NO = "seriaNo";

    private String type;
    private String comments;
    private String serialNo;

    public RCTRedPacket(String type, String comments, String serialNo) {
        this.type = type;
        this.comments = comments;
        this.serialNo = serialNo;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(TYPE, type);
        json.addProperty(COMMENTS, comments);
        json.addProperty(SERIA_NO, serialNo);
        return json;
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public String getComments() {
        return comments;
    }

    @Override
    public String getSeriaNo() {
        return serialNo;
    }

}
