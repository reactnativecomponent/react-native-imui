//
//  IMUIRedPacketOpenMessageCell.swift
//  RCTAuroraIMUI
//
//  Created by Dowin on 2017/8/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//

//
//  IMUINotificationMessageCell.swift
//  RCTAuroraIMUI
//
//  Created by Dowin on 2017/8/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//


import UIKit

class IMUIRedPacketOpenMessageCell: IMUIBaseMessageCell {
    
    var contView = UIView()
    var titleLable = UILabel()
    var redImg = UIImageView()
    var tapRedView = UIView()
    var redGesture = UITapGestureRecognizer.init()
    let screenW = UIScreen.main.bounds.size.width
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLable.textColor = UIColor.white
        titleLable.font = UIFont.systemFont(ofSize: (screenW * 13 / 375))
        titleLable.textAlignment = NSTextAlignment.center
        self.redGesture.addTarget(self, action: #selector(self.clickTapRedView))
        tapRedView.isUserInteractionEnabled = true
        tapRedView.addGestureRecognizer(self.redGesture)
        self.redGesture.numberOfTapsRequired = 1
        redImg.image = UIImage.init(named: "packet_tip")
        contView.backgroundColor = UIColor.init(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 0.7)
        contView.layer.cornerRadius = 5
        contView.clipsToBounds = true
        contView.addSubview(redImg)
        contView.addSubview(titleLable)
        contView.addSubview(tapRedView)
        bubbleView.addSubview(contView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tapBubbleView() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func clickTapRedView() {
        self.delegate?.messageCollectionView?(didTapMessageBubbleInCell: self, model: self.message!)
    }
    
    override func presentCell(with message: IMUIMessageModelProtocol, viewCache: IMUIReuseViewCache , delegate: IMUIMessageMessageCollectionViewDelegate?) {
        super.presentCell(with: message, viewCache: viewCache, delegate: delegate)
        let layout = message.layout
        let tmpDict = message.customDict
        let strTitle = tmpDict.object(forKey: "tipMsg") as! String
        let attString = NSMutableAttributedString.init(string: strTitle)
        let tmpArr = rangesOf(searchString: "红包", inString: strTitle)

        for tmpR in tmpArr {
            
            attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(red: 216/255.0, green: 38/255.0, blue: 23/255.0, alpha: 1), range: tmpR as! NSRange)
        }
        
        self.titleLable.attributedText = attString
        let titleW = widthWithFont(font: UIFont.systemFont(ofSize: (screenW * 13 / 375)), text: strTitle, maxWidth: layout.bubbleFrame.size.width*0.9)
        let contentX = (layout.bubbleFrame.size.width - titleW - 20)*0.5
        let contentY = (layout.bubbleFrame.size.height - 24)*0.4
        redImg.frame = CGRect(origin: CGPoint(x:6, y:3), size: CGSize(width:14, height:18))
        contView.frame = CGRect(origin: CGPoint(x:contentX, y:contentY), size: CGSize(width:titleW+24, height:24))
        self.titleLable.frame = CGRect(origin: CGPoint(x:22, y:0), size: CGSize(width:titleW, height:24))
        self.tapRedView.frame.size = CGSize(width:40,height:24)
        self.tapRedView.frame.origin = CGPoint(x:titleW-16,y:0)
        self.tapRedView.backgroundColor = UIColor.clear
        
    }
    func widthWithFont(font : UIFont,  text : String, maxWidth: CGFloat) -> CGFloat {
        
        guard text.characters.count > 0  else {
            
            return 0
        }
        
        let size = CGSize(width:maxWidth, height:CGFloat(MAXFLOAT))
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context:nil)
        
        return rect.size.width+8
    }
    
    func rangesOf(searchString : String, inString : String ) -> NSMutableArray {
        let results : NSMutableArray = NSMutableArray.init()
        let nsInStr = inString as NSString
        var searchRange = NSMakeRange(0, nsInStr.length)
        while nsInStr.range(of: searchString, options: NSString.CompareOptions(rawValue: 0), range: searchRange).location != NSNotFound {
            let tmpRange = nsInStr.range(of: searchString, options: NSString.CompareOptions(rawValue: 0), range: searchRange)
            results.add(tmpRange)
            searchRange = NSMakeRange(NSMaxRange(tmpRange), nsInStr.length - NSMaxRange(tmpRange))
        }
        return results
        
    }
    
}



