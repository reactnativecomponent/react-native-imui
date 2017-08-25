package cn.jiguang.imui.messagelist.module;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IBankTransfer;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTBankTransfer extends RCTExtend implements IBankTransfer {

    public final static String AMOUNT = "amount";
    public final static String SERIA_NO = "serialNo";
    public final static String COMMENTS = "comments";

    private String amount;
    private String serialNo;
    private String comments;
    private static Gson sGSON = new Gson();

    public RCTBankTransfer(String amount, String serialNo, String comments) {
        this.amount = amount;
        this.serialNo = serialNo;
        this.comments = comments;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(AMOUNT,amount);
        json.addProperty(SERIA_NO,serialNo);
        json.addProperty(COMMENTS,comments);
        return json;
    }

    @Override
    public String getAmount() {
        return amount;
    }

    @Override
    public String getSeriaNo() {
        return serialNo;
    }

    @Override
    public String getComments() {
        return comments;
    }
}
