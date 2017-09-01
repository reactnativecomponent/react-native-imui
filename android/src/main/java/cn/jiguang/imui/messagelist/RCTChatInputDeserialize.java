package cn.jiguang.imui.messagelist;

import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonParseException;

import java.lang.reflect.Type;

import cn.jiguang.imui.messagelist.module.RCTChatInput;

/**
 * Created by dowin on 2017/9/1.
 */

public class RCTChatInputDeserialize implements JsonDeserializer<RCTChatInput> {
    @Override
    public RCTChatInput deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
        RCTChatInput input = new RCTChatInput();
        return input;
    }
}
