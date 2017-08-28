//
//  IMUIBaseMessageCell.swift
//  IMUIChat
//
//  Created by oshumini on 2017/3/2.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit


enum IMUIMessageCellType {
  case incoming
  case outgoing
}

open class IMUIBaseMessageCell: UICollectionViewCell, IMUIMessageCellProtocal,MenuPopOverViewDelegate {
  var bubbleView: IMUIMessageBubbleView
  lazy var avatarImage = MyCacheImageView()
  lazy var timeLabel = UILabel()
  lazy var nameLabel = UILabel()
    lazy var durationLabel = UILabel()
    lazy var isPlayedView = UIView() //录音是否播放过
  weak var statusView: UIView?
  
  weak var delegate: IMUIMessageMessageCollectionViewDelegate?
  var message: IMUIMessageModelProtocol?
    var cellGesture = UITapGestureRecognizer.init()
   var bubbleGesture = UITapGestureRecognizer.init()
   var longPress = UILongPressGestureRecognizer.init()
  override init(frame: CGRect) {

    bubbleView = IMUIMessageBubbleView(frame: CGRect.zero)
    super.init(frame: frame)
    
    self.contentView.addSubview(self.bubbleView)
    self.contentView.addSubview(self.avatarImage)
    self.contentView.addSubview(self.timeLabel)
    self.contentView.addSubview(self.nameLabel)
    self.contentView.addSubview(self.durationLabel)
    self.contentView.addSubview(self.isPlayedView)
//    self.bubbleGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBubbleView))
//    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longTapBubbleView(sender:)))
    self.cellGesture.addTarget(self, action: #selector(self.tapCellView))
    self.bubbleGesture.addTarget(self, action: #selector(self.tapBubbleView))
    self.longPress.addTarget(self, action: #selector(self.longTapBubbleView(sender:)))
    self.bubbleView.isUserInteractionEnabled = true
    self.bubbleView.addGestureRecognizer(self.bubbleGesture)
    self.bubbleView.addGestureRecognizer(self.longPress)
    self.bubbleGesture.numberOfTapsRequired = 1
    self.addGestureRecognizer(self.cellGesture)
    
    let avatarGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapHeaderImage))
    avatarGesture.numberOfTapsRequired = 1
    avatarImage.isUserInteractionEnabled = true
    avatarImage.addGestureRecognizer(avatarGesture)
    
    nameLabel.font = IMUIMessageCellLayout.nameLabelTextFont
    durationLabel.font = UIFont.systemFont(ofSize: 14)
    durationLabel.textColor = UIColor.init(red: 157/255.0, green: 157/255.0, blue: 158/255.0, alpha: 1)
    
    isPlayedView.backgroundColor = UIColor.init(red: 216/255.0, green: 38/255.0, blue: 23/255.0, alpha: 1)
    isPlayedView.clipsToBounds = true
    isPlayedView.layer.cornerRadius = 3
    
    self.setupSubViews()
    NotificationCenter.default.addObserver(self, selector: #selector(clickLinkTouch), name: NSNotification.Name(rawValue: "ClickTouchLinkNotification"), object: nil)

  }
  
  fileprivate func setupSubViews() {
    timeLabel.textAlignment = .center
    timeLabel.textColor = UIColor.white
    timeLabel.font = IMUIMessageCellLayout.timeStringFont
    timeLabel.backgroundColor = UIColor.init(red: 206/255.0, green: 206/255.0, blue: 206/255.0, alpha: 1)
    timeLabel.layer.cornerRadius = 5
    timeLabel.clipsToBounds = true
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func layoutCell(with layout: IMUIMessageCellLayoutProtocal, viewCache: IMUIReuseViewCache) {
    self.timeLabel.frame = layout.timeLabelFrame
    self.avatarImage.frame = layout.avatarFrame
    self.avatarImage.layer.cornerRadius = 5.0;
    self.avatarImage.layer.masksToBounds = true;
    self.bubbleView.frame = layout.bubbleFrame
    self.nameLabel.frame = layout.nameLabelFrame
    self.durationLabel.frame = layout.durationLabelFrame
    self.isPlayedView.frame = layout.isPlayedFrame
    self.removeStatusView(viewCache: viewCache)
    
    self.statusView = viewCache.statusViewCache.dequeue(layout: layout ) as? UIView
    self.contentView.addSubview(self.statusView!)
    self.addGestureForStatusView()
    self.nameLabel.textColor = UIColor.init(red: 157/255.0, green: 157/255.0, blue: 158/255.0, alpha: 1)
    self.statusView!.frame = layout.statusViewFrame
  }
  
  func addGestureForStatusView() {
    for recognizer in self.statusView?.gestureRecognizers ?? [] {
      self.statusView?.removeGestureRecognizer(recognizer)
    }
    
    let statusViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapSatusView))
    statusViewGesture.numberOfTapsRequired = 1
    self.statusView?.isUserInteractionEnabled = true
    self.statusView?.addGestureRecognizer(statusViewGesture)
  }
  
  func removeStatusView(viewCache: IMUIReuseViewCache) {
    if let view = self.statusView {
      viewCache.statusViewCache.switchStatusViewToNotInUse(statusView: self.statusView as! IMUIMessageStatusViewProtocal)
      view.removeFromSuperview()
    } else {
      for view in self.contentView.subviews {
        if let _ = view as? IMUIMessageStatusViewProtocal {
          viewCache.statusViewCache.switchStatusViewToNotInUse(statusView: view as! IMUIMessageStatusViewProtocal)
          view.removeFromSuperview()
        }
      }
    }
  }
  
  func setupData(with message: IMUIMessageModelProtocol) {
//    self.avatarImage.image = message.fromUser.Avatar()
    self.avatarImage.setImageURL(message.fromUser.Avatar())
    self.bubbleView.backgroundColor = UIColor.init(netHex: 0xE7EBEF)
    self.timeLabel.text = message.timeString
    let timeW = widthWithFont(font: IMUIMessageCellLayout.timeStringFont, text: message.timeString)
    let timeX = (UIScreen.main.bounds.size.width - timeW)*0.5
    var timeRect = self.timeLabel.frame;
    timeRect.size.width = timeW
    timeRect.origin.x = timeX
    self.timeLabel.frame = timeRect
    self.nameLabel.text = message.fromUser.displayName()
    
    self.message = message
    if message.type == .notification || message.type == .redpacketOpen{
        self.bubbleView.backgroundColor = UIColor.clear
    }else{
        self.bubbleView.setupBubbleImage(resizeBubbleImage: message.resizableBubbleImage)
    }

    self.durationLabel.isHidden = true
    self.isPlayedView.isHidden = true
    
    let statusView = self.statusView as! IMUIMessageStatusViewProtocal
    self.statusView?.isHidden = false
    switch message.messageStatus {
      case .sending:
        statusView.layoutSendingStatus()
        break
      case .failed:
        statusView.layoutFailedStatus()
        break
      case .success:
        statusView.layoutSuccessStatus()
        self.statusView?.isHidden = true
        if message.type == .voice{//录音
            self.durationLabel.isHidden = false
            let tmpDict = message.customDict
            let strDuration = tmpDict.object(forKey: "duration") as! String
            self.durationLabel.text = strDuration+"\""
            if message.isOutGoing {
                self.durationLabel.textAlignment = .right
            } else {
                self.durationLabel.textAlignment = .left
                let isPlayed = tmpDict.object(forKey: "isPlayed") as! Bool
                self.isPlayedView.isHidden = isPlayed
            }
        }
        break
      case .mediaDownloading:
        statusView.layoutMediaDownloading()
        break
      case .mediaDownloadFail:
        statusView.layoutMediaDownloadFail()
    }
    
    if message.isOutGoing {
      self.nameLabel.textAlignment = .right
    } else {
      self.nameLabel.textAlignment = .left
    }
  }
  
    func widthWithFont(font : UIFont,  text : String) -> CGFloat {
        
        guard text.characters.count > 0  else {
            
            return 0
        }
        let size = CGSize(width:CGFloat(MAXFLOAT), height:CGFloat(MAXFLOAT))
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context:nil)
        
        return rect.size.width+10
    }
    
  func presentCell(with message: IMUIMessageModelProtocol, viewCache: IMUIReuseViewCache, delegate: IMUIMessageMessageCollectionViewDelegate?) {
    self.layoutCell(with: message.layout, viewCache: viewCache)
    self.setupData(with: message)
    self.delegate = delegate
  }
  
  func tapBubbleView() {
    if self.message?.type == .text {
        self.delegate?.messageCollectionView?(tapCellView: self)
    }else{
        self.delegate?.messageCollectionView?(didTapMessageBubbleInCell: self, model: self.message!)
    }
  }
    
    func tapCellView(){//点击整个cell，隐藏键盘
        self.delegate?.messageCollectionView?(tapCellView: self)
    }
    
  func longTapBubbleView(sender : UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizerState.began{
        if self.message?.type == .notification || self.message?.type == .redpacketOpen {
            return
        }
        let items = NSMutableArray.init()
        if self.message?.type == .text {
            items.add("复制")
        }
        items.add("删除")
        let strTime:String = (self.message?.timeStamp)!
        let tmpStamp = (strTime as NSString).integerValue
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let nowTimeStamp = Int(timeInterval)
        if ((nowTimeStamp - tmpStamp < 120) && (self.message?.isOutGoing)!){
            items.add("撤回")
        }
        let popOver = MenuPopOverView()
        popOver.delegate = self as MenuPopOverViewDelegate
        popOver.presentPopover(from: self.bubbleView.bounds, in: self.bubbleView, withStrings: items as! [Any])
        let obj = "showMenu" as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClickLongTouchShowMenuNotification"), object: obj)
    }
  }
    
    public func popoverView(_ popoverView: MenuPopOverView!, didSelectItem strIndex: String!) {
        self.delegate?.messageCollectionView?(didShowMenuStr:strIndex, model: self.message!)
    }
    
    public func popoverViewDidDismiss(_ popoverView: MenuPopOverView!) {
        let obj = "dismissMenu" as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClickLongTouchShowMenuNotification"), object: obj)
    }
    
  func tapHeaderImage() {
    self.delegate?.messageCollectionView?(didTapHeaderImageInCell: self, model: self.message!)
  }
  
  func tapSatusView() {
        self.delegate?.messageCollectionView?(didTapStatusViewInCell: self, model: self.message!)
    
  }
  
  func didDisAppearCell() {
  }

    func clickLinkTouch(notifi: Notification){
        let strTouch: String = notifi.object as! String
        if strTouch == "begin" {
            self.bubbleView.removeGestureRecognizer(self.bubbleGesture)
            self.bubbleView.removeGestureRecognizer(self.longPress)
            self.removeGestureRecognizer(self.cellGesture)
        }else{
            self.bubbleView.addGestureRecognizer(bubbleGesture)
            self.bubbleView.addGestureRecognizer(longPress)
            self.addGestureRecognizer(self.cellGesture)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.bubbleView.removeGestureRecognizer(self.bubbleGesture)
        self.bubbleView.removeGestureRecognizer(self.longPress)
        self.removeGestureRecognizer(self.cellGesture)
    }
    

}
