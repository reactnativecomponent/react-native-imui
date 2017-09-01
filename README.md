# ReactNative IMUI
项目fork自 jpush 的 [Aurora IMUI](https://github.com/jpush/aurora-imui/tree/master/ReactNative)

## 使用
参考[demo](https://github.com/reactnativecomponent/react-native-chat-demo)
## 安装

```
npm install react-native-imui --save
```
 `settings.gradle` 中的引用路径：
```
include ':app', ':react-native-imui'
project(':react-native-imui').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-imui/android')
include ':react-native-imui:chatinput'
include ':react-native-imui:messagelist'
include ':react-native-imui:popuptool'
include ':react-native-imui:emoji'
include ':react-native-imui:photoViewPagerview'
include ':react-native-imui:photoViewPagerview:photodraweeview'
```

然后在 app 的 `build.gradle`中引用：

```
dependencies {
    compile project(':react-native-imui')
}
```

**注意事项（Android）：我们使用了 support v4, v7 25.3.1 版本，因此需要将你的 build.gradle 中 buildToolsVersion 及 compiledSdkVersion 改为 25 以上。可以参考 demo 的配置。**

## 配置

- ### Android

  - 引入 Package:

  > MainApplication.java

  ```
  import cn.jiguang.imui.messagelist.ReactIMUIPackage;
  ...

  @Override
  protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          new ReactIMUIPackage()
      );
  }
  ```



- ### iOS
  - Find PROJECT -> TARGETS -> General -> Embedded Binaries  and add RCTAuroraIMUI.framework
  - 把 `iOSResourcePacket` 目录`NIMKitEmoticon.bundle`拖到Xcode`Resources`目录下
  - 把 `iOSResourcePacket` 目录`IMGS`拖到Xcode`Images.xcassets`下

## 数据格式

使用 MessageList，你需要定义 `message` 对象和 `fromUser` 对象。

- `message` 对象格式:

**status 必须为以下四个值之一: "send_succeed", "send_failed", "send_going", "download_failed"，如果没有定义这个属性， 默认值是 "send_succeed".**

 ```
  message = {  // text message
    msgId: "msgid",
    status: "send_going",
    msgType: "text",
    isOutgoing: true,
    text: "text"
    fromUser: {}
}

message = {  // image message
    msgId: "msgid",
    msgType: "image",
    isOutGoing: true,
    progress: "progress string"
    mediaPath: "image path"
    fromUser: {}
}


message = {  // voice message
    msgId: "msgid",
    msgType: "voice",
    isOutGoing: true,
    duration: number, // 注意这个值有用户自己设置时长，单位秒
    mediaPath: "voice path"
    fromUser: {}
}

message = {  // video message
    msgId: "msgid",
    status: "send_failed",
    msgType: "video",
    isOutGoing: true,
    druation: number
    mediaPath: "voice path"
    fromUser: {}
}

message = {  // event message
    msgId: "msgid",
    msgType: "event",
    text: "the event text"
}
 ```

-    `fromUser` 对象格式:

  ```
  fromUser = {
    userId: ""
    displayName: ""
    avatarPath: "avatar image path"
  }
  ```

