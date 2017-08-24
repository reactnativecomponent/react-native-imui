package cn.jiguang.imui.messages.viewholder;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;

import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.IBankTransfer;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.messages.MessageListStyle;

/**
 * Created by dowin on 2017/8/9.
 */

public class BankTransferViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    private TextView value;
    private TextView comments;


    public BankTransferViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);
        value = (TextView) itemView.findViewById(R.id.bank_transfer_value);
        comments = (TextView) itemView.findViewById(R.id.bank_transfer_comments);

    }

    @Override
    public void onBind(final MESSAGE message) {
        super.onBind(message);
        IBankTransfer extend = getExtend(message);
        if (extend != null) {
            value.setText(extend.getAmount());
            comments.setText(extend.getComments());
        }
    }

    @Override
    public void applyStyle(MessageListStyle style) {
        super.applyStyle(style);
    }
}