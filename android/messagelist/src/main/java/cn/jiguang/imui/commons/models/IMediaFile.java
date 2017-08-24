package cn.jiguang.imui.commons.models;

/**
 * Created by dowin on 2017/8/18.
 */

public interface IMediaFile extends IExtend {

    String getHeight();

    String getWidth();

    String getDisplayName();

    long getDuration();

    String getThumbPath();

    String getPath();

    String getUrl();
}
