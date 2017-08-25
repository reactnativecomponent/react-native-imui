package cn.jiguang.imui.chatinput;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.SystemClock;
import android.support.v4.widget.Space;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.lang.reflect.Field;

import cn.jiguang.imui.chatinput.listener.OnClickEditTextListener;
import cn.jiguang.imui.chatinput.listener.OnMenuClickListener;
import cn.jiguang.imui.chatinput.listener.RecordVoiceListener;
import cn.jiguang.imui.chatinput.record.RecordHelper;
import cn.jiguang.imui.chatinput.utils.StringUtil;
import dowin.com.emoji.emoji.EmoticonPickerView;
import dowin.com.emoji.emoji.IEmoticonSelectedListener;
import dowin.com.emoji.emoji.MoonUtil;

public class ChatInputView extends LinearLayout implements TextWatcher {

    public static final byte KEYBOARD_STATE_SHOW = -3;
    public static final byte KEYBOARD_STATE_HIDE = -2;
    public static final byte KEYBOARD_STATE_INIT = -1;

    public static final int REQUEST_CODE_TAKE_PHOTO = 0x0001;
    public static final int REQUEST_CODE_SELECT_PHOTO = 0x0002;

    private EditText mChatInput;
    private Button mChatVoice;
    private RecordHelper recordHelper;

    private TextView mSendCountTv;
    private CharSequence mInput;
    private Space mInputMarginLeft;
    private Space mInputMarginRight;

    private ImageButton mVoiceBtn;
    private ImageButton mEmojiBtn;
    private ImageButton mSendBtn;
    private View mSendLayout;
    private View mActionLayout;

    private LinearLayout mChatInputContainer;
    private FrameLayout mMenuContainer;

    EmoticonPickerView emoticonPickerView;
    LinearLayout actionLayout;

    private OnMenuClickListener mListener;
    private OnClickEditTextListener mEditTextListener;

    private ChatInputStyle mStyle;

    private InputMethodManager mImm;
    private Window mWindow;
    private int mLastClickId = 0;

    private int mWidth;
    private int mHeight;
    public static int sMenuHeight = 666;

    private boolean mShowSoftInput = false;

    private Context mContext;

    public ChatInputView(Context context) {
        super(context);
        init(context);
    }

    public ChatInputView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public ChatInputView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context) {
        mContext = context;
        recordHelper = new RecordHelper(context);

        setOrientation(VERTICAL);
        inflate(context, R.layout.view_chatinput, this);

        // menu buttons
        mChatInput = (EditText) findViewById(R.id.aurora_et_chat_input);
        mChatVoice = (Button) findViewById(R.id.aurora_et_chat_voice);
        mVoiceBtn = (ImageButton) findViewById(R.id.aurora_menuitem_ib_voice);
        mEmojiBtn = (ImageButton) findViewById(R.id.imui_item_emoji);
        mSendBtn = (ImageButton) findViewById(R.id.imui_item_send);

        View voiceBtnContainer = findViewById(R.id.aurora_framelayout_menuitem_voice);
        View emojiBtnContainer = findViewById(R.id.imui_layout_emoji);
        mSendLayout = findViewById(R.id.imui_layout_send);
        mActionLayout = findViewById(R.id.imui_layout_action);
        voiceBtnContainer.setOnClickListener(onMenuItemClickListener);
        emojiBtnContainer.setOnClickListener(onMenuItemClickListener);
        mSendLayout.setOnClickListener(onMenuItemClickListener);
        mActionLayout.setOnClickListener(onMenuItemClickListener);

        mSendCountTv = (TextView) findViewById(R.id.aurora_menuitem_tv_send_count);
        mInputMarginLeft = (Space) findViewById(R.id.aurora_input_margin_left);
        mInputMarginRight = (Space) findViewById(R.id.aurora_input_margin_right);
        mChatInputContainer = (LinearLayout) findViewById(R.id.aurora_ll_input_container);
        mMenuContainer = (FrameLayout) findViewById(R.id.aurora_fl_menu_container);

        emoticonPickerView = (EmoticonPickerView) findViewById(R.id.emoticon_picker_view);
        actionLayout = (LinearLayout) findViewById(R.id.aurora_view_action_layout);

        mMenuContainer.setVisibility(GONE);

        mChatInput.addTextChangedListener(this);

        mChatVoice.setOnTouchListener(new OnChatVoiceTouch(mChatVoice));

        mImm = (InputMethodManager) context.getSystemService(Context.INPUT_METHOD_SERVICE);
        mWindow = ((Activity) context).getWindow();
        DisplayMetrics dm = getResources().getDisplayMetrics();
        mWidth = dm.widthPixels;
        mHeight = dm.heightPixels;

        mChatInput.setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (mEditTextListener != null) {
                    mEditTextListener.onTouchEditText();
                }
                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN && !mShowSoftInput) {
                    mShowSoftInput = true;
                    invisibleMenuLayout();
                    mChatInput.requestFocus();
                }
                return false;
            }
        });
    }

    private void init(Context context, AttributeSet attrs) {
        init(context);
        mStyle = ChatInputStyle.parse(context, attrs);

        mChatInput.setMaxLines(mStyle.getInputMaxLines());
        mChatInput.setHint(mStyle.getInputHint());
        mChatInput.setText(mStyle.getInputText());
        mChatInput.setTextSize(TypedValue.COMPLEX_UNIT_PX, mStyle.getInputTextSize());
        mChatInput.setTextColor(mStyle.getInputTextColor());
        mChatInput.setHintTextColor(mStyle.getInputHintColor());
        mChatInput.setBackgroundResource(mStyle.getInputEditTextBg());
        mInputMarginLeft.getLayoutParams().width = mStyle.getInputMarginLeft();
        mInputMarginRight.getLayoutParams().width = mStyle.getInputMarginRight();
        mVoiceBtn.setImageResource(mStyle.getVoiceBtnIcon());
        mVoiceBtn.setBackground(mStyle.getVoiceBtnBg());
        mEmojiBtn.setBackground(mStyle.getPhotoBtnBg());
        mEmojiBtn.setImageResource(mStyle.getPhotoBtnIcon());
        mSendBtn.setBackground(mStyle.getSendBtnBg());
        mSendBtn.setImageResource(mStyle.getSendBtnIcon());
        mSendCountTv.setBackground(mStyle.getSendCountBg());
    }

    public void addActionView(View view, int index) {
        actionLayout.addView(view, index);
    }

    private void setCursor(Drawable drawable) {
        try {
            Field f = TextView.class.getDeclaredField("mCursorDrawableRes");
            f.setAccessible(true);
            f.set(mChatInput, drawable);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    enum UpdateStatus {
        Start, Canceled, Move, Continue, Complete
    }

    class OnChatVoiceTouch implements OnTouchListener {
        final String[] text = new String[]{"按住 说话", "松开 结束", "松开 取消"};
        UpdateStatus updateStatus;

        private Button button;

        public OnChatVoiceTouch(Button button) {
            this.button = button;
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
//                    touched = true;
//                    initAudioRecord();
                onStartAudioRecord();
                updateStatus(UpdateStatus.Start);
            } else if (event.getAction() == MotionEvent.ACTION_CANCEL
                    || event.getAction() == MotionEvent.ACTION_UP) {
//                    touched = false;
                onEndAudioRecord(isCancelled(v, event));
                updateStatus(isCancelled(v, event) ? UpdateStatus.Canceled : UpdateStatus.Complete);
            } else if (event.getAction() == MotionEvent.ACTION_MOVE) {
//                    touched = true;
                cancelAudioRecord(isCancelled(v, event));
                updateStatus(isCancelled(v, event) ? UpdateStatus.Move : UpdateStatus.Continue);
            }
            return false;
        }
    }

    public void setRecordVoiceListener(RecordVoiceListener listener) {
        recordHelper.setListener(listener);
    }

    public void setMenuClickListener(OnMenuClickListener listener) {
        mListener = listener;
    }

    public void setOnClickEditTextListener(OnClickEditTextListener listener) {
        mEditTextListener = listener;
    }

    @Override
    public void beforeTextChanged(CharSequence charSequence, int start, int count, int after) {

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        mInput = s;
        this.start = start;
        this.count = count;

        if (mEditTextListener != null && count > 0) {

            final int startIndex = start <= 0 ? 0 : start;
            int endIndex = startIndex + count;
            endIndex = endIndex > s.length() ? s.length() : endIndex;
            mEditTextListener.onTextChanged(s.subSequence(startIndex, endIndex).toString());
        }
        if (s.length() >= 1 && start == 0 && before == 0) { // Starting input
            triggerSendButtonAnimation(mSendBtn, true);
        } else if (s.length() == 0 && before >= 1) { // Clear content
            triggerSendButtonAnimation(mSendBtn, false);
        }
    }

    private int start;
    private int count;

    @Override
    public void afterTextChanged(Editable s) {

        MoonUtil.replaceEmoticons(getContext(), s, start, count);

        int editEnd = mChatInput.getSelectionEnd();
        mChatInput.removeTextChangedListener(this);
        while (StringUtil.counterChars(s.toString()) > 5000 && editEnd > 0) {
            s.delete(editEnd - 1, editEnd);
            editEnd--;
        }
        mChatInput.setSelection(editEnd);
        mChatInput.addTextChangedListener(this);
    }

    public EditText getInputView() {
        return mChatInput;
    }

    private OnClickListener onMenuItemClickListener = new OnClickListener() {
        @Override
        public void onClick(View view) {

            if (view.getId() == R.id.imui_layout_send) {
                // Allow send text and photos at the same time.
                if (onSubmit()) {
                    mChatInput.setText("");
                }
                mSendLayout.setVisibility(INVISIBLE);
                mActionLayout.setVisibility(VISIBLE);
//                mSendCountTv.setVisibility(View.INVISIBLE);
                dismissMenuLayout();

            } else if (view.getId() == R.id.aurora_framelayout_menuitem_voice) {
                if (mListener != null) {
                    mListener.switchToMicrophoneMode();
                }
                showRecordVoiceLayout();

            } else {
                if (mMenuContainer.getVisibility() != VISIBLE) {
                    dismissSoftInputAndShowMenu();
                } else if (view.getId() == mLastClickId) {
                    dismissMenuAndResetSoftMode();
                    return;
                }

                if (view.getId() == R.id.imui_layout_action) {
                    if (mListener != null) {
                        mListener.switchToActionMode();
                    }
                    actionLayout.setVisibility(VISIBLE);
                    emoticonPickerView.setVisibility(GONE);

                } else if (view.getId() == R.id.imui_layout_emoji) {
                    if (mListener != null) {
                        mListener.switchToEmojiMode();
                    }
                    emoticonPickerView.setVisibility(VISIBLE);
                    emoticonPickerView.show(emoticonSelectedListener);
                    actionLayout.setVisibility(GONE);
                }

                mLastClickId = view.getId();
            }
        }
    };

    private IEmoticonSelectedListener emoticonSelectedListener = new IEmoticonSelectedListener() {

        /**
         * *************** IEmojiSelectedListener ***************
         */
        @Override
        public void onEmojiSelected(String key) {
            Editable mEditable = mChatInput.getText();
            if (key.equals("/DEL")) {
                mChatInput.dispatchKeyEvent(new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL));
            } else {
                int start = mChatInput.getSelectionStart();
                int end = mChatInput.getSelectionEnd();
                start = (start < 0 ? 0 : start);
                end = (start < 0 ? 0 : end);
                mEditable.replace(start, end, key);
            }
        }

        @Override
        public void onStickerSelected(String category, String item) {
            Log.i("InputPanel", "onStickerSelected, category =" + category + ", sticker =" + item);
        }
    };

    public void dismissMenuLayout() {
        mMenuContainer.setVisibility(GONE);
    }

    public void invisibleMenuLayout() {
        mMenuContainer.setVisibility(INVISIBLE);
    }

    public void showMenuLayout() {
        mMenuContainer.setVisibility(VISIBLE);
    }

    public void showRecordVoiceLayout() {

        if (mChatInput.getVisibility() == VISIBLE) {
            mChatInput.setVisibility(INVISIBLE);
            mChatVoice.setVisibility(VISIBLE);
            hideInputMethod();
            mVoiceBtn.setImageResource(R.drawable.nim_message_button_bottom_audio_selector);
        } else {
            mChatInput.setVisibility(VISIBLE);
            mChatVoice.setVisibility(INVISIBLE);
            showInputMethod();
            mVoiceBtn.setImageResource(R.drawable.nim_message_button_bottom_text_selector);
        }
//        mSelectPhotoView.setVisibility(GONE);
        actionLayout.setVisibility(GONE);
    }

    private void hideInputMethod() {
//        isKeyboardShowed = false;
//        uiHandler.removeCallbacks(showTextRunnable);
        mImm.hideSoftInputFromWindow(mChatInput.getWindowToken(), 0);
        mChatInput.clearFocus();
    }

    // 显示键盘布局
    private void showInputMethod() {
        mChatInput.requestFocus();
        //如果已经显示,则继续操作时不需要把光标定位到最后
//        if (!isKeyboardShowed) {
//            editTextMessage.setSelection(editTextMessage.getText().length());
//            isKeyboardShowed = true;
//        }
        mImm.showSoftInput(mChatInput, 0);
    }


    /**
     * Set menu container's height, invoke this method once the menu was initialized.
     *
     * @param height Height of menu, set same height as soft keyboard so that display to perfection.
     */
    public void setMenuContainerHeight(int height) {
        if (height > 0) {
            sMenuHeight = height;
            mMenuContainer.setLayoutParams(
                    new LinearLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, height));
        }
    }

    private boolean onSubmit() {
        return mListener != null && mListener.onSendTextMessage(mInput);
    }

    public boolean getSoftInputState() {
        return mShowSoftInput;
    }

    public void setSoftInputState(boolean state) {
        mShowSoftInput = state;
    }

    public int getMenuState() {
        return mMenuContainer.getVisibility();
    }

    /**
     * Trigger aurora_menuitem_send button animation
     *
     * @param sendBtn    aurora_menuitem_send button
     * @param hasContent EditText has content or photos have been selected
     */
    private void triggerSendButtonAnimation(final ImageButton sendBtn, final boolean hasContent) {
        float[] shrinkValues = new float[]{0.6f};
        AnimatorSet shrinkAnimatorSet = new AnimatorSet();
        shrinkAnimatorSet.playTogether(ObjectAnimator.ofFloat(sendBtn, "scaleX", shrinkValues),
                ObjectAnimator.ofFloat(sendBtn, "scaleY", shrinkValues));
        shrinkAnimatorSet.setDuration(100);

        float[] restoreValues = new float[]{1.0f};
        final AnimatorSet restoreAnimatorSet = new AnimatorSet();
        restoreAnimatorSet.playTogether(ObjectAnimator.ofFloat(sendBtn, "scaleX", restoreValues),
                ObjectAnimator.ofFloat(sendBtn, "scaleY", restoreValues));
        restoreAnimatorSet.setDuration(100);

        restoreAnimatorSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animator) {

            }

            @Override
            public void onAnimationEnd(Animator animator) {
                mSendCountTv.bringToFront();
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
                    requestLayout();
                    invalidate();
                }
                if (hasContent) {
//                    mSendCountTv.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onAnimationCancel(Animator animator) {

            }

            @Override
            public void onAnimationRepeat(Animator animator) {

            }
        });

        shrinkAnimatorSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animator) {
                if (!hasContent) {
//                    mSendCountTv.setVisibility(View.INVISIBLE);
                }
            }

            @Override
            public void onAnimationEnd(Animator animator) {
                if (hasContent) {
                    mSendLayout.setVisibility(VISIBLE);
                    mActionLayout.setVisibility(INVISIBLE);
                } else {
                    mSendLayout.setVisibility(INVISIBLE);
                    mActionLayout.setVisibility(VISIBLE);
                }
                restoreAnimatorSet.start();
            }

            @Override
            public void onAnimationCancel(Animator animator) {

            }

            @Override
            public void onAnimationRepeat(Animator animator) {

            }
        });

        shrinkAnimatorSet.start();
    }

    private long convertStrTimeToLong(String strTime) {
        String[] timeArray = strTime.split(":");
        long longTime = 0;
        if (timeArray.length == 2) { // If time format is MM:SS
            longTime = Integer.parseInt(timeArray[0]) * 60 * 1000 + Integer.parseInt(timeArray[1]) * 1000;
        }
        return SystemClock.elapsedRealtime() - longTime;
    }

    public void dismissMenuAndResetSoftMode() {
        mWindow.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN
                | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        dismissMenuLayout();
        mChatInput.requestFocus();
        mChatInput.requestLayout();
    }

    public void dismissSoftInputAndShowMenu() {
        // dismiss soft input
        mWindow.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN
                | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        showMenuLayout();
        if (mImm != null) {
            mImm.hideSoftInputFromWindow(mChatInput.getWindowToken(), 0);
        }
        setMenuContainerHeight(sMenuHeight);
        mShowSoftInput = false;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    @Override
    public void onWindowVisibilityChanged(int visibility) {
        super.onWindowVisibilityChanged(visibility);
    }

}
