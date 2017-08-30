//
//  IMUINotificationMessageCell.swift
//  RCTAuroraIMUI
//
//  Created by Dowin on 2017/8/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//


import UIKit

class IMUINotificationMessageCell: IMUIBaseMessageCell {
    
    var titleLable = UILabel()
    let screenW = UIScreen.main.bounds.size.width
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLable.textColor = UIColor.white
        titleLable.font = UIFont.systemFont(ofSize: 12)
        titleLable.textAlignment = NSTextAlignment.center
        titleLable.backgroundColor = UIColor.init(red: 206/255.0, green: 206/255.0, blue: 206/255.0, alpha: 1)
        titleLable.layer.cornerRadius = 5
        titleLable.clipsToBounds = true
        bubbleView.addSubview(titleLable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func presentCell(with message: IMUIMessageModelProtocol, viewCache: IMUIReuseViewCache , delegate: IMUIMessageMessageCollectionViewDelegate?) {
        super.presentCell(with: message, viewCache: viewCache, delegate: delegate)
        let layout = message.layout
        let tmpDict = message.customDict
        let strTitle = tmpDict.object(forKey: "tipMsg") as! String
        self.titleLable.text = strTitle
        let titleSize = sizeWithFont(font: UIFont.systemFont(ofSize: 12), text: strTitle, maxWidth: layout.bubbleFrame.size.width*0.8)
        let titleX = (layout.bubbleFrame.size.width - titleSize.width - 10) * 0.5
        let titleY = (layout.bubbleFrame.size.height - titleSize.height - 10) * 0.3
        self.titleLable.frame = CGRect(origin: CGPoint(x:titleX, y:titleY), size: CGSize(width:titleSize.width+10, height:titleSize.height+10))

    }
    func sizeWithFont(font : UIFont,  text : String, maxWidth: CGFloat) -> CGSize {
        
        guard text.characters.count > 0  else {
            
            return CGSize.zero
        }
        
        let size = CGSize(width:maxWidth, height:CGFloat(MAXFLOAT))
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context:nil)
        
        return rect.size
    }
}


