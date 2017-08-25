package cn.jiguang.imui.messages.viewholder;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.commons.models.IRedPacket;
import cn.jiguang.imui.messages.MessageListStyle;

/**
 * Created by dowin on 2017/8/9.
 */

public class RedPacketViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    private TextView comments;
    private View layoutTop;

    public RedPacketViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);

        comments = (TextView) itemView.findViewById(R.id.red_packet_comments);
        layoutTop = itemView.findViewById(R.id.layout_top);
    }

    @Override
    public void onBind(MESSAGE message) {
        super.onBind(message);
        IRedPacket extend = getExtend(message);
        if (extend != null) {
            comments.setText(extend.getComments());
        }

    }

    @Override
    public void applyStyle(MessageListStyle style) {
        super.applyStyle(style);
        layoutTop.setBackground(style.getRedPacketTopDrawable());
    }
}
