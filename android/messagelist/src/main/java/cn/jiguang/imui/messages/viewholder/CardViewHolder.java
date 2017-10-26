package cn.jiguang.imui.messages.viewholder;

import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.ICard;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.messages.MessageListStyle;

/**
 * Created by dowin on 2017/10/23.
 */

public class CardViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    private ImageView image;
    private TextView name;
    private TextView cardType;
    private TextView sessionId;

    public CardViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);

        image = (ImageView) itemView.findViewById(R.id.card_icon);
        name = (TextView) itemView.findViewById(R.id.card_name);
        cardType = (TextView) itemView.findViewById(R.id.card_type);
        sessionId = (TextView) itemView.findViewById(R.id.card_id);
    }

    @Override
    public void onBind(final MESSAGE message) {
        super.onBind(message);
        ICard card = getExtend(message);
        if (card != null) {
            if(!TextUtils.isEmpty(card.getImgPath())) {
                mImageLoader.loadAvatarImage(image, card.getImgPath());
            }
            name.setText(card.getName());
            cardType.setText(card.getCardType());
            sessionId.setText(card.getSessionId());
        }

    }

    @Override
    public void applyStyle(MessageListStyle style) {
        super.applyStyle(style);
    }
}
