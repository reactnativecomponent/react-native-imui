package cn.jiguang.imui.chatinput.listener;


/**
 * Menu items' callbacks
 */
public interface OnMenuClickListener {

    /**
     * Fires when send button is on click.
     *
     * @param input Input content
     * @return boolean
     */
    boolean onSendTextMessage(CharSequence input);

    /**
     * Fires when voice button is on click.
     */
    void switchToMicrophoneMode();

    /**
     * Fires when photo button is on click.
     */
    void switchToActionMode();

    /**
     * Fires when camera button is on click.
     */
    void switchToEmojiMode();
}