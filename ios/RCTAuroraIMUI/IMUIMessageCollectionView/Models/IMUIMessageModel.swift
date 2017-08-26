//
//  MessageModel.swift
//  IMUIChat
//
//  Created by oshumini on 2017/2/24.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit


@objc public enum IMUIMessageType: Int {
  case text
  case image
  case voice
  case video
  case location
  case notification
  case redpacket
  case transfer
  case url
  case account_notice
  case redpacketOpen
  case custom
}


@objc public enum IMUIMessageStatus: UInt {
  // Sending message status
  case failed
  case sending
  case success
  
  // received message status
  case mediaDownloading
  case mediaDownloadFail
}

//
//public enum IMUIMessageReceiveStatus {
//  case failed
//  case sending
//  case success
//}


public protocol IMUIMessageDataSource {
  func messageArray(with offset:NSNumber, limit:NSNumber) -> [IMUIMessageModelProtocol]
  
}


// MARK: - IMUIMessageModelProtocol

/**
 *  The class `IMUIMessageModel` is a concrete class for message model objects that represent a single user message
 *  The message can be text \ voice \ image \ video \ message
 *  It implements `IMUIMessageModelProtocol` protocal
 *
 */
open class IMUIMessageModel: NSObject, IMUIMessageModelProtocol {
  
  @objc public var duration: CGFloat
    let screenW = UIScreen.main.bounds.size.width
  
  open var msgId = {
    return ""
  }()

  open var messageStatus: IMUIMessageStatus
  
  open var fromUser: IMUIUserProtocol
    
    open var customDict:NSMutableDictionary
  
  open var isOutGoing: Bool = true
  open var isShowAvatar: Bool = true
  open var time: String
    open var tStamp: String
  
  open var timeString: String {
    return time
  }
  
    open var timeStamp: String {
        return tStamp
    }
    
    
  open var isNeedShowTime: Bool  {
    if timeString != "" {
      return true
    } else {
      return false
    }
  }
  
  open var status: IMUIMessageStatus
  open var type: IMUIMessageType
  
  open var layout: IMUIMessageCellLayoutProtocal {
    return cellLayout!
  }
  open var cellLayout: IMUIMessageCellLayoutProtocal?
  
  open func text() -> String {
    return ""
  }
  
  open func mediaFilePath() -> String {
    return ""
  }
  
  open func calculateBubbleContentSize() -> CGSize {
    var bubbleContentSize: CGSize!
    
    switch type {
    case .image:
        let imgWidth = screenW * 0.6;
        let imgW = self.customDict.object(forKey: "imageWidth") as! NSString
        let imgH = self.customDict.object(forKey: "imageHeight") as! NSString
        let imgPercent:CGFloat = CGFloat(imgH.floatValue / imgW.floatValue)
        let imgHeight = imgWidth * imgPercent
        bubbleContentSize = CGSize(width: imgWidth, height: imgHeight)
        break
    case .text:
        let tmpLabel = M80AttributedLabel()
        tmpLabel.nim_setText(self.text())
        tmpLabel.font = IMUITextMessageCell.inComingTextFont
        bubbleContentSize = tmpLabel.getTheLabel(CGSize(width: IMUIMessageCellLayout.bubbleMaxWidth, height: CGFloat(MAXFLOAT)))
        
        
//      if isOutGoing {
//        bubbleContentSize = self.text().sizeWithConstrainedWidth(with: IMUIMessageCellLayout.bubbleMaxWidth, font: IMUITextMessageCell.outGoingTextFont)
//      } else {
//        bubbleContentSize = self.text().sizeWithConstrainedWidth(with: IMUIMessageCellLayout.bubbleMaxWidth, font: IMUITextMessageCell.inComingTextFont)
//      }
      break
    case .voice:
      bubbleContentSize = CGSize(width: 80, height: 32)
      break
    case .video:
      bubbleContentSize = CGSize(width: 120, height: 160)
      break
    case .location:
        let locationW = UIScreen.main.bounds.width*0.625
        let strTitle = self.customDict.object(forKey: "title") as! String
        let tmpSize = heightWithFont(font: UIFont.systemFont(ofSize: (screenW * 13 / 375)), fixedWidth: (locationW-15), text: strTitle)
      bubbleContentSize = CGSize(width: locationW, height: UIScreen.main.bounds.width*0.625*0.5+tmpSize.height+15 )
      break
    case .notification:
        bubbleContentSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        isShowAvatar = false
        break
    case .redpacket:
        bubbleContentSize = CGSize(width: UIScreen.main.bounds.width*0.62, height: UIScreen.main.bounds.width*0.62*0.35)
        break
    case .transfer:
        bubbleContentSize = CGSize(width: UIScreen.main.bounds.width*0.62, height: UIScreen.main.bounds.width*0.62*0.35)
        break
    case .url:
        bubbleContentSize = CGSize(width: 100, height: 100)
        break
    case .account_notice:
        bubbleContentSize = CGSize(width: 200, height: 30)
        break
    case .redpacketOpen:
        bubbleContentSize = CGSize(width: UIScreen.main.bounds.width, height: 40)
        isShowAvatar = false
        break
        
    default:
      break
    }
    return bubbleContentSize
  }
    func heightWithFont(font : UIFont, fixedWidth : CGFloat, text : String) -> CGSize {
        
        guard text.characters.count > 0 && fixedWidth > 0 else {
            
            return CGSize.zero
        }
        
        let size = CGSize(width:fixedWidth, height:CGFloat(MAXFLOAT))
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context:nil)
        
        return rect.size
    }
  
  public init(msgId: String, messageStatus: IMUIMessageStatus, fromUser: IMUIUserProtocol, isOutGoing: Bool, time: String, status: IMUIMessageStatus, type: IMUIMessageType, cellLayout: IMUIMessageCellLayoutProtocal? ,customDict: NSMutableDictionary, timeStamp: String) {
    self.msgId = msgId
    self.fromUser = fromUser
    self.isOutGoing = isOutGoing
    self.time = time
    self.status = status
    self.type = type
    self.messageStatus = messageStatus
    self.customDict = customDict
    self.duration = 0.0
    self.tStamp = timeStamp
    
    super.init()
    
    if let layout = cellLayout {
      self.cellLayout = layout
    } else {
      let bubbleSize = self.calculateBubbleContentSize()
        self.cellLayout = IMUIMessageCellLayout(isOutGoingMessage: isOutGoing, isNeedShowTime: isNeedShowTime, bubbleContentSize: bubbleSize, bubbleContentInsets: UIEdgeInsets.zero, showAvatar:isShowAvatar)
    }
  }
  
  open var resizableBubbleImage: UIImage {
    var bubbleImg: UIImage?
    if isOutGoing {
      bubbleImg = UIImage.imuiImage(with: "outGoing_bubble")
      bubbleImg = bubbleImg?.resizableImage(withCapInsets: UIEdgeInsetsMake(24, 10, 9, 15), resizingMode: .tile)
    } else {
      bubbleImg = UIImage.imuiImage(with: "inComing_bubble")
      bubbleImg = bubbleImg?.resizableImage(withCapInsets: UIEdgeInsetsMake(24, 15, 9, 10), resizingMode: .tile)
    }
    
    return bubbleImg!
  }
  
}
