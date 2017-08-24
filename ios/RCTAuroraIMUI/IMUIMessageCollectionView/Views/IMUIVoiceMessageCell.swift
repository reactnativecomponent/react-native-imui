//
//  IMUIVoiceMessageCell.swift
//  IMUIChat
//
//  Created by oshumini on 2017/4/1.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

class IMUIVoiceMessageCell: IMUIBaseMessageCell {

  fileprivate var voiceImg = UIImageView()
    var cellMsgID = ""
    var mediaFilePath = ""
    var isOutGoing:Bool = true
  fileprivate var isMediaActivity = false {
    didSet {
      
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    NotificationCenter.default.addObserver(self, selector: #selector(clickTapVoiceView(notification:)), name: NSNotification.Name(rawValue: "tapVoiceBubbleViewNotification"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(clickStopVoice(notification:)), name: NSNotification.Name(rawValue: "kStopPlayVoice"), object: nil)
    bubbleView.addSubview(voiceImg)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
   func clickPlayVoice() {
        if isMediaActivity {
          do {
            self.isMediaActivity = false
            IMUIAudioPlayerHelper.sharedInstance.stopAudio()
            let voiceData = try Data(contentsOf: URL(fileURLWithPath: (self.mediaFilePath)))
            var imgTime = 0.0
            var imgIndex = 0
            IMUIAudioPlayerHelper.sharedInstance.playAudioWithData(voiceData, progressCallback: { (currendTime, duration) in
                if (currendTime - imgTime) > 0.3 {
                    imgTime = currendTime
                    imgIndex = imgIndex + 1
                    if imgIndex > 3 {
                        imgIndex = 1
                    }
                    let strImg = self.isOutGoing ? "outgoing_voice_\(imgIndex)" : "incoming_voice_\(imgIndex)"
                    self.voiceImg.image = UIImage.imuiImage(with: strImg)
                }
                
            },finishCallBack: {
                self.isMediaActivity = true
                self.layoutToVoice(isOutGoing:self.isOutGoing)
            })
          } catch {
                print("load voice file fail")
          }
          
        } else {
           IMUIAudioPlayerHelper.sharedInstance.stopAudio()
            self.isMediaActivity = true
            self.layoutToVoice(isOutGoing:isOutGoing)
        }
  }
    
    func clickStopVoice(notification: NSNotification){
        IMUIAudioPlayerHelper.sharedInstance.stopAudio()
    }
  
  override func presentCell(with message: IMUIMessageModelProtocol, viewCache: IMUIReuseViewCache, delegate: IMUIMessageMessageCollectionViewDelegate?) {
    super.presentCell(with: message, viewCache: viewCache, delegate: delegate)
    self.isMediaActivity = true // TODO: add playRecording
    self.layoutToVoice(isOutGoing: message.isOutGoing)
    isOutGoing = message.isOutGoing
    self.cellMsgID = message.msgId
    mediaFilePath = message.mediaFilePath()
  }
    
    func clickTapVoiceView(notification: NSNotification)  {
        DispatchQueue.main.sync {
            let notiMsgID:String = notification.object as! String
            if  self.cellMsgID == notiMsgID {
                self.isPlayedView.isHidden = true
                self.message?.customDict.setValue(true, forKey: "isPlayed");
                self.clickPlayVoice()
            }else{
                self.isMediaActivity = true
                self.layoutToVoice(isOutGoing:isOutGoing)
            }
        }
    }
    
  func layoutToVoice(isOutGoing: Bool) {
    
    if isOutGoing {
      self.voiceImg.image = UIImage.imuiImage(with: "outgoing_voice_3")
      self.voiceImg.frame = CGRect(x: 0, y: 0, width: 12, height: 16)
      self.voiceImg.center = CGPoint(x: bubbleView.frame.width - 20, y: bubbleView.frame.height/2)
    } else {
      self.voiceImg.image = UIImage.imuiImage(with: "incoming_voice_3")
      self.voiceImg.frame = CGRect(x: 0, y: 0, width: 12, height: 16)
      self.voiceImg.center = CGPoint(x: 20, y: bubbleView.frame.height/2)
    }
  }
  
}
