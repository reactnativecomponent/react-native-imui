package cn.jiguang.imui.chatinput.emoji;

import android.Manifest;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import androidx.annotation.AttrRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import cn.jiguang.imui.chatinput.model.FileItem;
import cn.jiguang.imui.chatinput.model.VideoItem;
import cn.jiguang.imui.messagelist.R;

public class EmojiView extends FrameLayout implements Handler.Callback {

    private final static int MSG_WHAT_SCAN_SUCCESS = 1;
    private final static int MSG_WHAT_SCAN_FAILED = 0;

    private Context mContext;

    private RecyclerView mRvPhotos; // Select photo view
    private EmojiAdapter mEmojiAdapter;

    private List<FileItem> mMedias; // All photo or video files

    private Handler mMediaHandler = new Handler(this);

    public EmojiView(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public EmojiView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public EmojiView(@NonNull Context context, @Nullable AttributeSet attrs,
                     @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        inflate(context, R.layout.layout_chatinput_selectphoto, this);
        mContext = context;

        mRvPhotos = (RecyclerView) findViewById(R.id.aurora_recyclerview_selectphoto);
        mRvPhotos.setLayoutManager(new GridLayoutManager(context, 7, GridLayoutManager.VERTICAL, true));
        mRvPhotos.setHasFixedSize(true);
    }

    public void initData() {
        boolean hasPermission = android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M
                || mContext.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;

        if (hasPermission && mMedias == null) {
            mMedias = new ArrayList<>();

            new Thread(new Runnable() {
                @Override
                public void run() {
                    if (getPhotos()) {
                        mMediaHandler.sendEmptyMessage(MSG_WHAT_SCAN_SUCCESS);
                    } else {
                        mMediaHandler.sendEmptyMessage(MSG_WHAT_SCAN_FAILED);
                    }
                }
            }).start();
        }
    }

    private boolean getPhotos() {
        Uri imageUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        ContentResolver contentResolver = getContext().getContentResolver();
        String[] projection = new String[]{
                MediaStore.Images.ImageColumns.DATA, MediaStore.Images.ImageColumns.DISPLAY_NAME,
                MediaStore.Images.ImageColumns.SIZE, MediaStore.Images.ImageColumns.DATE_ADDED
        };
        Cursor cursor = contentResolver.query(imageUri, projection, null, null,
                MediaStore.Images.Media.DATE_ADDED + " desc");

        if (cursor == null) {
            return false;
        }
        if (cursor.getCount() != 0) {
            while (cursor.moveToNext()) {
                String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA));
                String fileName =
                        cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME));
                String size = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.SIZE));
                String date = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATE_ADDED));

                FileItem item = new FileItem(path, fileName, size, date);
                item.setType(FileItem.Type.Image);
                mMedias.add(item);
                if(mMedias.size()>=8){
                    break;
                }
            }
        }
        cursor.close();
        return true;
    }

    private boolean getVideos() {
        Uri videoUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
        ContentResolver cr = getContext().getContentResolver();
        String[] projection = new String[]{
                MediaStore.Video.VideoColumns.DATA, MediaStore.Video.VideoColumns.DURATION,
                MediaStore.Video.VideoColumns.DISPLAY_NAME, MediaStore.Video.VideoColumns.DATE_ADDED
        };

        Cursor cursor = cr.query(videoUri, projection, null, null, null);
        if (cursor == null) {
            return false;
        }
        if (cursor.getCount() != 0) {
            while (cursor.moveToNext()) {
                String path = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media.DATA));
                String name = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media.DISPLAY_NAME));
                String date = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media.DATE_ADDED));
                long duration = cursor.getLong(cursor.getColumnIndex(MediaStore.Video.Media.DURATION));

                VideoItem item = new VideoItem(path, name, null, date, duration);
                item.setType(FileItem.Type.Video);
                mMedias.add(item);
            }
        }
        cursor.close();
        return true;
    }

    @Override
    public boolean handleMessage(Message message) {

        if (message.what == MSG_WHAT_SCAN_SUCCESS) {
            Collections.sort(mMedias);
            mEmojiAdapter = new EmojiAdapter(mMedias);
            mRvPhotos.setAdapter(mEmojiAdapter);
        } else if (message.what == MSG_WHAT_SCAN_FAILED) {
            Toast.makeText(getContext(), getContext().getString(R.string.sdcard_not_prepare_toast),
                    Toast.LENGTH_SHORT).show();
        }
        return false;
    }
}
