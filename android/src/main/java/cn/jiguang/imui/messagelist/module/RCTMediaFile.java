package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.IMediaFile;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTMediaFile extends RCTExtend implements IMediaFile{

    public final static String HEIGHT = "height";
    public final static String WIDTH = "width";
    public final static String DISPLAY_NAME = "displayName";
    public final static String DURATION = "duration";
    public final static String THUMB_PATH = "thumbPath";
    public final static String PATH = "path";
    public final static String URL = "url";

    private String height;
    private String width;
    private String displayName;
    private long duration;
    private String thumbPath;
    private String path;
    private String url;

    public RCTMediaFile(String thumbPath,String path, String url) {
        this.thumbPath = thumbPath;
        this.path = path;
        this.url = url;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(HEIGHT, height);
        json.addProperty(WIDTH, width);
        json.addProperty(DISPLAY_NAME, displayName);
        json.addProperty(DURATION, duration);
        json.addProperty(THUMB_PATH, thumbPath);
        json.addProperty(PATH, path);
        json.addProperty(URL, url);
        return json;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public void setWidth(String width) {
        this.width = width;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    @Override
    public String getHeight() {
        return height;
    }

    @Override
    public String getWidth() {
        return width;
    }

    @Override
    public String getDisplayName() {
        return displayName;
    }

    @Override
    public long getDuration() {
        return duration;
    }

    @Override
    public String getPath() {
        return path;
    }

    @Override
    public String getThumbPath() {
        return thumbPath;
    }

    @Override
    public String getUrl() {
        return url;
    }
}
