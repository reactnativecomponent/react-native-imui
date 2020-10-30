# ReactNative IMUI
项目fork自 jpush 的 [Aurora IMUI](https://github.com/jpush/aurora-imui/tree/master/ReactNative)

## 使用
参考[demo](https://github.com/reactnativecomponent/react-native-chat-demo)
## 安装

```
npm install react-native-imui --save 或者 yarn add react-native-imui
```

## 配置

- ### iOS
  - 当前版本支持RN>=0.60
  - RCTAuroraIMUI.framework依赖于SDWebImage，请在项目的Podfile文件中添加pod 'SDWebImage'
  -现已将代码打包成RCTAuroraIMUI.framework放在react-native-imui/iOSResourcePacket/Framework/目录下，其中分别有支持模拟器+真机的（测试的时候用），也有仅支持真机的（打包上架appstore的时候用）。
  ##### 方式一、最简单的使用方式
  - 把`react-native-imui/iOSResourcePacket/Framework/`目录下，你所需要用到的`RCTAuroraIMUI.framework`文件拖拽到Xcode项目的`Framework`目录里面。
  - 把`react-native-imui/iOSResourcePacket/AuroraIMUI.bundle`拖拽到Xcode项目的`Resources`目录里面。
  - 
  - 把 PROJECT -> TARGETS -> General -> Frameworks,Libraries,and Embedded Content中的`RCTAuroraIMUI.framework`的Embed改成`Embed & Sign`。
  ##### 方式二、导入项目的方式
  - 把`react-native-imui/iOSResourcePacket/AuroraIMUI.bundle`拖拽到Xcode项目的`Resources`目录里面。
  - 在项目的Podfile文件的最下面中添加：
  target 'RCTAuroraIMUI' do
    project '../node_modules/react-native-imui/ios/RCTAuroraIMUI'
  end
  - 注意project路径是否正确
  - 在终端cd到Podfile文件夹下，pod install后，重新打开项目便会多了一个RCTAuroraIMUI的project在项目里面，编译它之后，可以在你原来的项目的PROJECT -> TARGETS -> General -> Frameworks,Libraries,and Embedded Content中添加`RCTAuroraIMUI.framework`


## 数据格式

使用 MessageList，你需要定义 `message` 对象和 `fromUser` 对象。

- `message` 对象格式:

**status 必须为以下四个值之一: "send_succeed", "send_failed", "send_going", "download_failed"，如果没有定义这个属性， 默认值是 "send_succeed".**

 ```
  message = {  // 文本
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
    fromUser: {},
    extend:{
      displayName:"图片发送于2017-12-07 10:07",
      imageHeight:"2848.000000",
      imageWidth:"4288.000000",
      thumbPath:"",
      url:""
    }
}

message = {  // 语音
    msgId: "msgid",
    msgType: "voice",
    isOutGoing: true,
    duration: number, // 注意这个值有用户自己设置时长，单位秒
    mediaPath: "voice path"
    fromUser: {},
    extend:{
      duration:"3"
      isPlayed:false
      url:""
    }   
}

message = {  //红包消息
    msgId: "msgid",
    status: "",
    msgType: "redpacket",
    isOutGoing: true,
    extend: {
      comments:"",//祝福语
      serialNo:"",//
      type:""//红包类型
    },
    fromUser: {}
}
message = {  //红包领取消息
    msgId: "msgid",
    status: "",
    msgType: "redpacketOpen",
    isOutGoing: true,
    extend: {
     serialNo:""
     tipMsg:""//红包通知
    },
    fromUser: {}
}

message = {  //转账消息
    msgId: "msgid",
    status: "",
    msgType: "transfer",
    isOutGoing: true,
    extend: {
     amount:"1"
     comments:""
     serialNo:""
    },
    fromUser: {}
}

message = {  //名片消息
    msgId: "msgid",
    status: "",
    msgType: "card",
    isOutGoing: true,
    extend: {
     imgPath:""//头像
     name:""//昵称
     sessionId:""//userId
     type:""
    },
    fromUser: {}
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

