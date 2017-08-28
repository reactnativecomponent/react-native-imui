package cn.jiguang.imui.chatinput.record;

import android.content.Context;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;

import cn.jiguang.imui.chatinput.listener.RecordVoiceListener;

/**
 * Created by dowin on 2017/8/25.
 */

public class OnChatVoiceTouch implements View.OnTouchListener {

    enum UpdateStatus {
        Start, Canceled, Move, Continue, Complete
    }

    final String[] text = new String[]{"按住 说话", "松开 结束", "松开 取消"};
    UpdateStatus updateStatus;
    private RecordHelper recordHelper;
    private Button button;

    public OnChatVoiceTouch(Context context, Button button) {
        this.button = button;
        recordHelper = new RecordHelper(context);
    }


    void updateStatus(UpdateStatus status) {
        if (updateStatus == status) {
            return;
        }
    }

    private void onStartAudioRecord() {
        button.setText(text[1]);
        button.setSelected(false);
        recordHelper.startRecording();
    }

    private void onEndAudioRecord(boolean cancel) {
        button.setText(text[0]);
        button.setSelected(false);


        if (cancel) {
            recordHelper.cancelRecord();
        } else {
            recordHelper.finishRecord();
        }
    }

    /**
     * 取消语音录制
     *
     * @param cancel
     */
    private void cancelAudioRecord(boolean cancel) {
        button.setSelected(true);
        updateTimerTip(cancel);
        recordHelper.setCancelAble(cancel);
    }

    private void updateTimerTip(boolean cancel) {
        button.setText(cancel ? text[2] : text[1]);
    }

    private boolean isCancelled(View view, MotionEvent event) {
        int[] location = new int[2];
        view.getLocationOnScreen(location);

        if (event.getRawX() < location[0] || event.getRawX() > location[0] + view.getWidth()
                || event.getRawY() < location[1] - 40) {
            return true;
        }

        return false;
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            onStartAudioRecord();
            updateStatus(UpdateStatus.Start);
        } else if (event.getAction() == MotionEvent.ACTION_CANCEL
                || event.getAction() == MotionEvent.ACTION_UP) {
            onEndAudioRecord(isCancelled(v, event));
            updateStatus(isCancelled(v, event) ? UpdateStatus.Canceled : UpdateStatus.Complete);
        } else if (event.getAction() == MotionEvent.ACTION_MOVE) {
//                    touched = true;
            cancelAudioRecord(isCancelled(v, event));
            updateStatus(isCancelled(v, event) ? UpdateStatus.Move : UpdateStatus.Continue);
        }
        return false;
    }

    public void setListener(RecordVoiceListener listener) {
        recordHelper.setListener(listener);
    }
}
