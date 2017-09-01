package cn.jiguang.imui.messages.viewholder;


import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;

import cn.jiguang.imui.BuildConfig;
import cn.jiguang.imui.R;
import cn.jiguang.imui.commons.models.IMediaFile;
import cn.jiguang.imui.commons.models.IMessage;
import cn.jiguang.imui.messages.MessageListStyle;
import cn.jiguang.imui.utils.PhotoViewPagerViewUtil;

public class PhotoViewHolder<MESSAGE extends IMessage> extends AvatarViewHolder<MESSAGE> {

    private ImageView mPhotoIv;


    public PhotoViewHolder(RecyclerView.Adapter adapter, View itemView, boolean isSender) {
        super(adapter, itemView, isSender);
        mPhotoIv = (ImageView) itemView.findViewById(R.id.aurora_iv_msgitem_photo);
    }

    @Override
    public void onBind(final MESSAGE message) {
        super.onBind(message);

        final IMediaFile extend = getExtend(message);
        if (extend == null) {
            return;
        }
        mImageLoader.loadImage(mPhotoIv, extend.getThumbPath());

        mPhotoIv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PhotoViewPagerViewUtil.show(getAdapter().getActivity(), getAdapter().getImageList(), getAdapter().getImageIndex(extend));
            }
        });
        mPhotoIv.setOnLongClickListener(new View.OnLongClickListener() {
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
        super.applyStyle(style);
        if (mIsSender) {
            mPhotoIv.setBackground(style.getSendPhotoMsgBg());
        } else {
            mPhotoIv.setBackground(style.getReceivePhotoMsgBg());
        }
    }

}
