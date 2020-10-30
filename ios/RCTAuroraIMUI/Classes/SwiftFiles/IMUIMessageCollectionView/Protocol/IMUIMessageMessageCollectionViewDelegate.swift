//
//  IMUIMessageMessageCollectionViewDelegate.swift
//  IMUIChat
//
//  Created by oshumini on 2017/4/13.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import Foundation
import UIKit

/**
 *  The `IMUIMessageMessageCollectionViewDelegate` protocol defines the even callback delegate
 */
@objc public protocol IMUIMessageMessageCollectionViewDelegate: NSObjectProtocol {
  /**
   *  Tells the delegate that user tap message cell
   */
  @objc optional func messageCollectionView(_: UICollectionView, forItemAt: IndexPath, model: IMUIMessageModelProtocol)
  
  /**
   *  Tells the delegate that user tap message bubble
   */
  @objc optional func messageCollectionView(didTapMessageBubbleInCell: UICollectionViewCell, model: IMUIMessageModelProtocol)
    
    
    @objc optional func messageCollectionView(didShowMenuStr: String, model: IMUIMessageModelProtocol)
    @objc optional func messageCollectionView(openMessageBubbleUrl: String)
    @objc optional func messageCollectionView(reloadMoreData:String)
    @objc optional func messageCollectionView(tapCellView:String)
    @objc optional func messageCollectionView(longTapCellViewModel:IMUIMessageModelProtocol)
    @objc optional func messageCollectionView(longTapAvatarPressWithModel:IMUIMessageModelProtocol)
    @objc optional func messageCollectionView(changeAutoScroll:Bool)
//    @objc optional func messageCollectionView(didTapImageMessageBubbleInCell: CGRect, model: IMUIMessageModelProtocol)
    
    
  
  /**
   *  Tells the delegate that user tap header image in message cell
   */
  @objc optional func messageCollectionView(didTapHeaderImageInCell: UICollectionViewCell, model: IMUIMessageModelProtocol)
  
  /**
   *  Tells the delegate that user tap statusView in message cell
   */
  @objc optional func messageCollectionView(didTapStatusViewInCell: UICollectionViewCell, model: IMUIMessageModelProtocol)
    
    @objc optional func messageCollectionView(didTapValidationWithModel: IMUIMessageModelProtocol)
    
  
  /**
   *  Tells the delegate that the message cell will show in screen
   */
  @objc optional func messageCollectionView(_: UICollectionView, willDisplayMessageCell: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageModelProtocol)
  
  /**
   *  Tells the delegate that message cell end displaying
   */
  @objc optional func messageCollectionView(_: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageModelProtocol)
  
  /**
   *  Tells the delegate when messageCollection beginDragging
   */
  @objc optional func messageCollectionView(_ willBeginDragging: UICollectionView)
    
    @objc optional func messageCollectionView(didScroll: UICollectionView)
    
    
}

//public extension IMUIMessageMessageCollectionViewDelegate {
//  
//  func messageCollectionView(_: UICollectionView, forItemAt: IndexPath, model: IMUIMessageModelProtocol) {}
//  
//  
//  func messageCollectionView(didTapMessageBubbleInCell: UICollectionViewCell, model: IMUIMessageModelProtocol) {}
//  
//  func messageCollectionView(didTapHeaderImageInCell: UICollectionViewCell, model: IMUIMessageModelProtocol) {}
//
//  func messageCollectionView(didTapStatusViewInCell: UICollectionViewCell, model: IMUIMessageModelProtocol) {}
//  
//  func messageCollectionView(_: UICollectionView, willDisplayMessageCell: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageModelProtocol) {}
//  
//  func messageCollectionView(_: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageModelProtocol) {}
//  
//  func messageCollectionView(_ willBeginDragging: UICollectionView){}
//}
