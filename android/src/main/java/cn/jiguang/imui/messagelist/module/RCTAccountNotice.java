package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IAccountNotice;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTAccountNotice extends RCTExtend implements IAccountNotice {

    public final static String TITLE = "title";
    public final static String TIME = "time";
    public final static String DATE = "date";
    public final static String AMOUNT = "amount";
    public final static String BODY = "body";
    public final static String SERIA_NO = "serialNo";

    private String title;
    private String time;
    private String date;
    private String amount;
    private String body;
    private String serialNo;

    public RCTAccountNotice(String title, String time, String date, String amount,String body, String serialNo) {
        this.title = title;
        this.time = time;
        this.date = date;
        this.amount = amount;
        this.body = body;
        this.serialNo = serialNo;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(TITLE, title);
        json.addProperty(TIME, time);
        json.addProperty(DATE, date);
        json.addProperty(AMOUNT, amount);
        json.addProperty(BODY, body);
        json.addProperty(SERIA_NO, serialNo);
        return json;
    }

    @Override
    public String getTitle() {
        return title;
    }

    @Override
    public String getTime() {
        return time;
    }

    @Override
    public String getDate() {
        return date;
    }

    @Override
    public String getAmount() {
        return amount;
    }

 @Override
    public String getBody() {
        return body;
    }

    @Override
    public String getSeriaNo() {
        return serialNo;
    }
}
