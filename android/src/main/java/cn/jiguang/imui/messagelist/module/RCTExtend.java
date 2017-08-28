package cn.jiguang.imui.messagelist.module;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.google.gson.Gson;
import com.google.gson.JsonElement;

import cn.jiguang.imui.commons.models.IExtend;

/**
 * Created by dowin on 2017/8/18.
 */

public abstract class RCTExtend implements IExtend {

    private static Gson sGSON = new Gson();

    abstract JsonElement toJSON();

    WritableMap toWritableMap(){
        WritableMap writableMap = Arguments.createMap();
        return writableMap;
    }
    @Override
    public String toString() {
        return sGSON.toJson(toJSON());
    }
}
