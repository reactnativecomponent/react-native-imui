package cn.jiguang.imui.messages.viewholder;

import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import cn.jiguang.imui.BuildConfig;
import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.messages.MessageListStyle;

public class CustonViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    protected TextView mMsgTv;


    public CustonViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);
        mMsgTv = (TextView) itemView.findViewById(R.id.aurora_tv_msgitem_message);

    }


    @Override
    public void onBind(final MESSAGE message) {
        super.onBind(message);
//        mMsgTv.setText(message.getText());
        String mText = message.getText();

        mMsgTv.setText("暂不支持该消息类型");

        mMsgTv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mMsgClickListener != null) {
                    mMsgClickListener.onMessageClick(message);
                }
            }
        });

        mMsgTv.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (mMsgLongClickListener != null) {
                    mMsgLongClickListener.onMessageLongClick(message);
                } else {
                    if (BuildConfig.DEBUG) {
                        Log.w("MsgListAdapter", "Didn't set long click listener! Drop event.");
                    }
                }
                return true;
            }
        });
    }

    @Override
    public void applyStyle(MessageListStyle style) {
        mMsgTv.setMaxWidth((int) (style.getWindowWidth() * style.getBubbleMaxWidth()));
        mMsgTv.setTextSize(17);
        mMsgTv.setLinkTextColor(Color.rgb(173,0,151));
    }


    public TextView getMsgTextView() {
        return mMsgTv;
    }

}