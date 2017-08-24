package cn.jiguang.imui.messages.viewholder;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.ILocation;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.messages.MessageListStyle;

/**
 * Created by dowin on 2017/8/9.
 */

public class LocationViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    private TextView address;

    public LocationViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);
        address = (TextView) itemView.findViewById(R.id.location_text);
    }

    @Override
    public void onBind(MESSAGE message) {
        super.onBind(message);
        ILocation extend = getExtend(message);
        if (extend != null) {
            address.setText(extend.getAddress());
        }

    }

    @Override
    public void applyStyle(MessageListStyle style) {
        super.applyStyle(style);
    }
}