package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.ILink;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTLink extends RCTExtend implements ILink {

    public final static String TITLE = "title";
    public final static String DESCRIBE = "describe";
    public final static String IMAGE = "image";
    public final static String LINK_URL = "linkUrl";

    private String title;
    private String describe;
    private String image;
    private String linkUrl;

    public RCTLink(String title, String describe, String image, String linkUrl) {
        this.title = title;
        this.describe = describe;
        this.image = image;
        this.linkUrl = linkUrl;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(TITLE, title);
        json.addProperty(DESCRIBE, describe);
        json.addProperty(IMAGE, image);
        json.addProperty(LINK_URL, linkUrl);
        return json;
    }


    @Override
    public String getTitle() {
        return title;
    }

    @Override
    public String getDescribe() {
        return describe;
    }

    @Override
    public String getImage() {
        return image;
    }

    @Override
    public String getLinkUrl() {
        return linkUrl;
    }
}
