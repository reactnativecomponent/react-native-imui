package cn.jiguang.imui.messagelist.module;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import cn.jiguang.imui.commons.models.ILocation;

/**
 * Created by dowin on 2017/8/18.
 */

public class RCTLocation extends RCTExtend implements ILocation {

    public final static String LATITUDE = "latitude";
    public final static String LONGITUDE = "longitude";
    public final static String ADDRESS = "address";

    private String latitude;
    private String longitude;
    private String address;

    public RCTLocation(String latitude, String longitude, String address) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
    }

    @Override
    public JsonElement toJSON() {
        JsonObject json = new JsonObject();
        json.addProperty(LATITUDE, latitude);
        json.addProperty(LONGITUDE, longitude);
        json.addProperty(ADDRESS, address);
        return json;
    }

    @Override
    public String getlatitude() {
        return latitude;
    }

    @Override
    public String getLongitude() {
        return longitude;
    }

    @Override
    public String getAddress() {
        return address;
    }
}
