package cn.jiguang.imui.messagelist;


import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;

import com.bumptech.glide.DrawableTypeRequest;
import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;
import com.bumptech.glide.request.target.Target;
import com.dialog.CustomAlertDialog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.popupmenu.NIMPopupMenu;
import com.popupmenu.PopupMenuItem;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cn.jiguang.imui.commons.ImageLoader;
import cn.jiguang.imui.messagelist.module.RCTMessage;
import cn.jiguang.imui.messages.MessageList;
import cn.jiguang.imui.messages.MsgListAdapter;
import cn.jiguang.imui.utils.SessorUtil;

import static cn.jiguang.imui.messagelist.MessageUtil.configMessage;
import static com.bumptech.glide.Glide.with;

/**
 * Created by caiyaoguan on 2017/5/22.
 */

public class ReactMsgListManager extends ViewGroupManager<MessageList> {

    private static final String REACT_MESSAGE_LIST = "RCTMessageList";
    private static final String TAG = "RCTMessageList";
    public static final String SEND_MESSAGE = "send_message";
    private static final String RECEIVE_MESSAGE = "receive_message";
    private static final String LOAD_HISTORY = "load_history_message";
    private static final String UPDATE_MESSAGE = "update_message";

    private static final String ON_LINK_CLICK_EVENT = "onLinkClick";
    private static final String ON_AVATAR_CLICK_EVENT = "onAvatarClick";
    private static final String ON_MSG_CLICK_EVENT = "onMsgClick";
    private static final String ON_MSG_LONG_CLICK_EVENT = "onMsgLongClick";
    private static final String ON_STATUS_VIEW_CLICK_EVENT = "onStatusViewClick";
    private static final String ON_TOUCH_MSG_LIST_EVENT = "onTouchMsgList";
    private static final String ON_PULL_TO_REFRESH_EVENT = "onPullToRefresh";

    public static final String RCT_APPEND_MESSAGES_ACTION = "cn.jiguang.imui.messagelist.intent.appendMessages";
    public static final String RCT_UPDATE_MESSAGE_ACTION = "cn.jiguang.imui.messagelist.intent.updateMessage";
    public static final String RCT_INSERT_MESSAGES_ACTION = "cn.jiguang.imui.messagelist.intent.insertMessages";
    public static final String RCT_SCROLL_TO_BOTTOM_ACTION = "cn.jiguang.imui.messagelist.intent.scrollToBottom";

    private MsgListAdapter mAdapter;
    private ReactContext mContext;
    private MessageList msgList;

    @Override
    public String getName() {
        return REACT_MESSAGE_LIST;
    }

    @SuppressLint("ClickableViewAccessibility")
    @SuppressWarnings("unchecked")
    @Override
    protected MessageList createViewInstance(final ThemedReactContext reactContext) {
        Log.w(TAG, "createViewInstance");
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(RCT_APPEND_MESSAGES_ACTION);
        intentFilter.addAction(RCT_UPDATE_MESSAGE_ACTION);
        intentFilter.addAction(RCT_INSERT_MESSAGES_ACTION);
        intentFilter.addAction(RCT_SCROLL_TO_BOTTOM_ACTION);

        mContext = reactContext;
        SessorUtil.getInstance(reactContext).register(true);
        mContext.registerReceiver(RCTMsgListReceiver, intentFilter);

        msgList = new MessageList(reactContext, null);
        // Use default layout
        MsgListAdapter.HoldersConfig holdersConfig = new MsgListAdapter.HoldersConfig();
        ImageLoader imageLoader = new ImageLoader() {
            @Override
            public void loadAvatarImage(ImageView avatarImageView, String string) {
                int resId = IdHelper.getDrawable(reactContext, string);
                if (resId != 0) {
                    Log.d("ReactMsgListManager", "Set drawable name: " + string);
                    avatarImageView.setImageResource(resId);
                } else {
                    with(reactContext)
                            .load(string)
                            .placeholder(IdHelper.getDrawable(reactContext, "aurora_headicon_default"))
                            .into(avatarImageView);
                }
            }

            @Override
            public void loadImage(ImageView imageView, String string) {
                // You can use other image load libraries.


                if (string != null) {
                    RequestManager m = Glide.with(reactContext);
                    DrawableTypeRequest request;

                    if (string.startsWith("http://")) {
                        request = m.load(string);
                    } else {
                        request = m.load(new File(string));
                    }
                    request.fitCenter()
                            .placeholder(IdHelper.getDrawable(reactContext, "aurora_picture_not_found"))
                            .override(400, Target.SIZE_ORIGINAL)
                            .into(imageView);
                }


            }
        };
        mAdapter = new MsgListAdapter<>("0", holdersConfig, imageLoader);
        mAdapter.setActivity(mContext.getCurrentActivity());
        msgList.setAdapter(mAdapter);
        mAdapter.setOnMsgClickListener(new MsgListAdapter.OnMsgClickListener<RCTMessage>() {
            @Override
            public void onMessageClick(RCTMessage message) {
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_MSG_CLICK_EVENT, event);
            }
        });

        mAdapter.setMsgLongClickListener(new MsgListAdapter.OnMsgLongClickListener<RCTMessage>() {
            @Override
            public void onMessageLongClick(RCTMessage message) {
                showMenu(reactContext, message);
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_MSG_LONG_CLICK_EVENT, event);
            }
        });

        mAdapter.setOnAvatarClickListener(new MsgListAdapter.OnAvatarClickListener<RCTMessage>() {
            @Override
            public void onAvatarClick(View view, RCTMessage message) {
//                initPopuptWindow(reactContext.getCurrentActivity(), view, "", 1);
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_AVATAR_CLICK_EVENT, event);
            }
        });

        mAdapter.setOnLinkClickListener(new MsgListAdapter.OnLinkClickListener() {
            @Override
            public void onLinkClick(View view, String o) {
                WritableMap event = Arguments.createMap();
                event.putString("message", o);
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_LINK_CLICK_EVENT, event);
            }
        });
        mAdapter.setMsgResendListener(new MsgListAdapter.OnMsgResendListener<RCTMessage>() {
            @Override
            public void onMessageResend(RCTMessage message) {
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                event.putString("opt", "resend");
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_STATUS_VIEW_CLICK_EVENT, event);
            }
        });

        msgList.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(), ON_TOUCH_MSG_LIST_EVENT, null);
                        if (reactContext.getCurrentActivity() != null) {
                            InputMethodManager imm = (InputMethodManager) reactContext.getCurrentActivity()
                                    .getSystemService(Context.INPUT_METHOD_SERVICE);
                            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                            Window window = reactContext.getCurrentActivity().getWindow();
                            window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN
                                    | WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
                        }
                        break;
                    case MotionEvent.ACTION_UP:
                        v.performClick();
                        break;
                }
                return false;
            }
        });
        mAdapter.setOnLoadMoreListener(new MsgListAdapter.OnLoadMoreListener() {
            @Override
            public void onLoadMore(int i, int i1) {
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(),
                        ON_PULL_TO_REFRESH_EVENT, null);
            }
        });
        return msgList;
    }

    void showMenu(final ReactContext reactContext, final RCTMessage message) {
        CustomAlertDialog dialog = new CustomAlertDialog(reactContext.getCurrentActivity());
        dialog.addItem("复制", new CustomAlertDialog.onSeparateItemClickListener() {
            @Override
            public void onClick() {
                ClipboardManager cm = (ClipboardManager) reactContext.getSystemService(Context.CLIPBOARD_SERVICE);
                cm.setText(message.getText());
            }
        });
        dialog.addItem("删除", new CustomAlertDialog.onSeparateItemClickListener() {
            @Override
            public void onClick() {
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                event.putString("opt", "delete");
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(),
                        ON_STATUS_VIEW_CLICK_EVENT, null);
            }
        });
        dialog.addItem("撤回", new CustomAlertDialog.onSeparateItemClickListener() {
            @Override
            public void onClick() {
                WritableMap event = Arguments.createMap();
                event.putMap("message", message.toWritableMap());
                event.putString("opt", "revoke");
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(msgList.getId(),
                        ON_STATUS_VIEW_CLICK_EVENT, null);
            }
        });
        dialog.show();
    }

    private static NIMPopupMenu.MenuItemClickListener listener = new NIMPopupMenu.MenuItemClickListener() {
        @Override
        public void onItemClick(final PopupMenuItem item) {
            switch (item.getTag()) {
                case 1:
                    break;
                case 2:
                    break;
                case 3:

                    break;
            }
        }
    };
    private static NIMPopupMenu popupMenu;
    private static List<PopupMenuItem> menuItemList;

    private static void initPopuptWindow(Context context, View view, String sessionId, int sessionTypeEnum) {
        if (popupMenu == null) {
            menuItemList = new ArrayList<>();
            popupMenu = new NIMPopupMenu(context, menuItemList, listener);
        }
        menuItemList.clear();
        menuItemList.addAll(getMoreMenuItems(context, sessionId, sessionTypeEnum));
        popupMenu.notifyData();
        popupMenu.show(view);
    }

    private static List<PopupMenuItem> getMoreMenuItems(Context context, String sessionId, int sessionTypeEnum) {
        List<PopupMenuItem> moreMenuItems = new ArrayList<PopupMenuItem>();
        moreMenuItems.add(new PopupMenuItem(1, R.drawable.nim_picker_image_selected, "云消息记录"));
        moreMenuItems.add(new PopupMenuItem(2, R.drawable.nim_picker_image_selected, "云消息记录"));
        moreMenuItems.add(new PopupMenuItem(3, R.drawable.nim_picker_image_selected, "云消息记录"));
        return moreMenuItems;
    }

    @ReactProp(name = "initList")
    public void setInitList(MessageList messageList, ReadableArray messages){
        if(messages!=null&&messages.size()>0) {
            final List<RCTMessage> list = new ArrayList<>();
            for (int i = 0; i < messages.size(); i++) {
                RCTMessage rctMessage = configMessage(messages.getMap(i));
                list.add(rctMessage);
            }
            mAdapter.addToStart(list,true);
        }
    }
    @ReactProp(name = "sendBubble")
    public void setSendBubble(MessageList messageList, ReadableMap map) {
        int resId = mContext.getResources().getIdentifier(map.getString("imageName"), "drawable", mContext.getPackageName());
        if (resId != 0) {
            messageList.setSendBubbleDrawable(resId);
        }
    }

    @ReactProp(name = "receiveBubble")
    public void setReceiveBubble(MessageList messageList, ReadableMap map) {
        int resId = mContext.getResources().getIdentifier(map.getString("imageName"), "drawable", mContext.getPackageName());
        if (resId != 0) {
            messageList.setReceiveBubbleDrawable(resId);
        }
    }

    @ReactProp(name = "sendBubbleTextColor")
    public void setSendBubbleTextColor(MessageList messageList, String color) {
        int colorRes = Color.parseColor(color);
        messageList.setSendBubbleTextColor(colorRes);
    }

    @ReactProp(name = "receiveBubbleTextColor")
    public void setReceiveBubbleTextColor(MessageList messageList, String color) {
        int colorRes = Color.parseColor(color);
        messageList.setReceiveBubbleTextColor(colorRes);
    }

    @ReactProp(name = "sendBubbleTextSize")
    public void setSendBubbleTextSize(MessageList messageList, int size) {
        messageList.setSendBubbleTextSize(size);
    }

    @ReactProp(name = "receiveBubbleTextSize")
    public void setReceiveBubbleTextSize(MessageList messageList, int size) {
        messageList.setReceiveBubbleTextSize(size);
    }

    @ReactProp(name = "sendBubblePadding")
    public void setSendBubblePadding(MessageList messageList, ReadableMap map) {
        messageList.setSendBubblePaddingLeft(map.getInt("left"));
        messageList.setSendBubblePaddingTop(map.getInt("top"));
        messageList.setSendBubblePaddingRight(map.getInt("right"));
        messageList.setSendBubblePaddingBottom(map.getInt("bottom"));
    }

    @ReactProp(name = "receiveBubblePadding")
    public void setReceiveBubblePaddingLeft(MessageList messageList, ReadableMap map) {
        messageList.setReceiveBubblePaddingLeft(map.getInt("left"));
        messageList.setReceiveBubblePaddingTop(map.getInt("top"));
        messageList.setReceiveBubblePaddingRight(map.getInt("right"));
        messageList.setReceiveBubblePaddingBottom(map.getInt("bottom"));
    }

    @ReactProp(name = "dateTextSize")
    public void setDateTextSize(MessageList messageList, int size) {
        messageList.setDateTextSize(size);
    }

    @ReactProp(name = "dateTextColor")
    public void setDateTextColor(MessageList messageList, String color) {
        int colorRes = Color.parseColor(color);
        messageList.setDateTextColor(colorRes);
    }

    @ReactProp(name = "datePadding")
    public void setDatePadding(MessageList messageList, int padding) {
        messageList.setDatePadding(padding);
    }

    @ReactProp(name = "avatarSize")
    public void setAvatarWidth(MessageList messageList, ReadableMap map) {
        messageList.setAvatarWidth(map.getInt("width"));
        messageList.setAvatarHeight(map.getInt("height"));
    }

    /**
     * if showDisplayName equals 1, then show display name.
     *
     * @param messageList       MessageList
     * @param isShowDisplayName boolean
     */
    @ReactProp(name = "isShowDisplayName")
    public void setShowDisplayName(MessageList messageList, boolean isShowDisplayName) {
        if (isShowDisplayName) {
            messageList.setShowDisplayName(1);
        }
    }

    @SuppressWarnings("unchecked")
    private BroadcastReceiver RCTMsgListReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Activity activity = mContext.getCurrentActivity();
            Gson gson = new GsonBuilder().registerTypeAdapter(RCTMessage.class, new RCTMessageDeserializer())
                    .create();
            if (intent.getAction().equals(RCT_APPEND_MESSAGES_ACTION)) {
                String[] messages = intent.getStringArrayExtra("messages");
                final List<RCTMessage> list = new ArrayList<>();
                for (String rctMsgStr : messages) {
                    final RCTMessage rctMessage = gson.fromJson(rctMsgStr, RCTMessage.class);
                    Log.d("RCTMessageListManager", "Add message to start, message: " + rctMsgStr);
                    Log.d("RCTMessageListManager", "RCTMessage: " + rctMessage);

                    list.add(rctMessage);

                }
                if (activity != null) {
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mAdapter.addToStart(list, true);
                        }
                    });
                }
            } else if (intent.getAction().equals(RCT_UPDATE_MESSAGE_ACTION)) {
                String message = intent.getStringExtra("message");
                final RCTMessage rctMessage = gson.fromJson(message, RCTMessage.class);
                Log.d("RCTMessageListManager", "updating message, message: " + rctMessage);
                if (activity != null) {
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mAdapter.updateMessage(rctMessage.getMsgId(), rctMessage);
                        }
                    });
                }
            } else if (intent.getAction().equals(RCT_INSERT_MESSAGES_ACTION)) {
                String[] messages = intent.getStringArrayExtra("messages");
                List<RCTMessage> list = new ArrayList<>();
//                for (int i = messages.length - 1; i > -1; i--) {
                for (int i = 0; i < messages.length; i++) {
                    final RCTMessage rctMessage = gson.fromJson(messages[i], RCTMessage.class);
                    list.add(rctMessage);
                }
                Log.d("RCTMessageListManager", "Add send message to top, messages: " + list.toString());
                mAdapter.addToEnd(list);
            } else if (intent.getAction().equals(RCT_SCROLL_TO_BOTTOM_ACTION)) {
                Log.i("RCTMessageListManager", "Scroll to bottom");
                mAdapter.getLayoutManager().scrollToPosition(0);
                mAdapter.getLayoutManager().requestLayout();
            }
        }
    };

    @Override
    public Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.<String, Object>builder()
                .put(ON_AVATAR_CLICK_EVENT, MapBuilder.of("registrationName", ON_AVATAR_CLICK_EVENT))
                .put(ON_MSG_CLICK_EVENT, MapBuilder.of("registrationName", ON_MSG_CLICK_EVENT))
                .put(ON_MSG_LONG_CLICK_EVENT, MapBuilder.of("registrationName", ON_MSG_LONG_CLICK_EVENT))
                .put(ON_STATUS_VIEW_CLICK_EVENT, MapBuilder.of("registrationName", ON_STATUS_VIEW_CLICK_EVENT))
                .put(ON_LINK_CLICK_EVENT, MapBuilder.of("registrationName", ON_LINK_CLICK_EVENT))
                .put(ON_TOUCH_MSG_LIST_EVENT, MapBuilder.of("registrationName", ON_TOUCH_MSG_LIST_EVENT))
                .put(ON_PULL_TO_REFRESH_EVENT, MapBuilder.of("registrationName", ON_PULL_TO_REFRESH_EVENT))
                .build();
    }

    @Override
    public void onDropViewInstance(MessageList view) {
        super.onDropViewInstance(view);
        Log.w(TAG, "onDropViewInstance");
        try {
            SessorUtil.getInstance(mContext).register(false);
            mContext.unregisterReceiver(RCTMsgListReceiver);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCatalystInstanceDestroy() {
        super.onCatalystInstanceDestroy();
        Log.w(TAG, "onCatalystInstanceDestroy");

    }
}
