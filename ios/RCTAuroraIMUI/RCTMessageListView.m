//
//  RCTMessageListView.m
//  imuiDemo
//
//  Created by oshumini on 2017/5/26.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RCTMessageListView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <RCTAuroraIMUI/RCTAuroraIMUI-Swift.h>
#import "RCTAuroraIMUIModule.h"
#import "RNRecordTipsView.h"
#import "UIView+Extend.h"
#import "DWOrigScorllView.h"
#import "DWShowImageVC.h"
#import "DWRecoderCoveView.h"
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height



@interface RCTMessageListView ()<IMUIMessageMessageCollectionViewDelegate,UIScrollViewDelegate>{
    DWRecoderCoveView *coverView;
    RNRecordTipsView *recordView;
    BOOL isShowMenuing;
    
}
@property (assign, nonatomic) NSTimeInterval lastTime;
@property (copy, nonatomic) NSString *strLastMsgId;
@property (copy, nonatomic) NSMutableArray *tmpMessageArr;
@property (copy, nonatomic) NSMutableArray *imageArr;

@end

@implementation RCTMessageListView

- (void)setInitalData:(NSArray *)initalData{
    if (initalData.count) {
        NSMutableArray *modeArr = [NSMutableArray array];
        for (NSMutableDictionary *message in initalData) {
            NSTimeInterval msgTime = [[message objectForKey:@"timeString"] doubleValue];
            if ((!_lastTime)||(fabs(_lastTime-msgTime) > 180)) {
                _lastTime = msgTime;
                _strLastMsgId = [message objectForKey:@"msgId"];
                [message setObject:[NSNumber numberWithBool:YES] forKey:@"isShowTime"];
            }else{
                [message setObject:[NSNumber numberWithBool:NO] forKey:@"isShowTime"];
            }
            RCTMessageModel * messageModel = [self convertMessageDicToModel:message];
            [modeArr addObject:messageModel];
            [self appendImageMessage:message];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageList fristAppendMessagesWith:modeArr];
        });
    }
}

- (NSMutableArray *)tmpMessageArr{
    if (_tmpMessageArr == nil) {
        _tmpMessageArr = [NSMutableArray array];
    }
    return _tmpMessageArr;
}

- (NSMutableArray *)imageArr{
    if (_imageArr == nil) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}


- (instancetype)init {
  self = [super init];
  return self;
}

- (RCTMessageModel *)convertMessageDicToModel:(NSMutableDictionary *)message {
  return [[RCTMessageModel alloc] initWithMessageDic: message];
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame: frame];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.frame = CGRectMake(0, 0, screenW, screenH-60-50);//60为导航栏高度，50为输入栏默认高度
      self.autoresizingMask = UIViewAutoresizingNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appendMessages:)
                                                 name:kAppendMessages object:nil];

      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(deleteMessage:)
                                                   name:kDeleteMessage object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(cleanAllMessages)
                                                   name:kCleanAllMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(insertMessagesToTop:)
                                                 name:kInsertMessagesToTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMessage:)
                                                 name:kUpdateMessge object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollToBottom:)
                                                 name:kScrollToBottom object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickLongTouchShowMenu:) name:kClickLongTouchShowMenu object:nil];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickRecordNotification:) name:RecordChangeNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickRecordLevelNotification:) name:kRecordLevelNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickRecordLongTimeNotification:) name:kRecordLongNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickChangeHeight:) name:@"ChangeMessageListHeightNotification" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickShowOrigImgView:) name:kShowOrigImageNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickScanOrigImgView:) name:@"DWOrigImageViewScanNotificatiom" object:nil];
      
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
////    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//      [_messageList.messageCollectionView addSubview:refreshControl];
//      _messageList.messageCollectionView.alwaysBounceVertical = YES;
//    });
      [self addCoverView];
      
  }
  return self;
}


- (void)addCoverView{
    for (UIView *tmpView in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([tmpView isKindOfClass:[DWRecoderCoveView class]]) {
            [tmpView removeFromSuperview];
        }
    }
    coverView = [[DWRecoderCoveView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH-50)];
    coverView.backgroundColor = [UIColor clearColor];
    
    CGFloat recordWH = 150;
    CGFloat recordX = (screenW - recordWH)*0.5;
    CGFloat recordY = (screenH - recordWH )*0.4;
    recordView = [[RNRecordTipsView alloc]initWithFrame:CGRectMake(recordX, recordY, recordWH, recordWH)];
    recordView.numFontSize = @"60";
    recordView.status = UIRecordSoundStatusRecoding;
    [coverView addSubview:recordView];
    coverView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
//    NSLog(@"keyWindow:%zd",[UIApplication sharedApplication].keyWindow.subviews.count);
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!topVC.presentedViewController) {
        if (object == self && [keyPath isEqualToString:@"bounds"]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.messageList scrollToBottomWith: NO];
            });
        }
    }
}


- (void)deleteMessage:(NSNotification *)notification{
    NSArray *messages = [[notification object] copy];
    for (NSMutableDictionary *message in messages) {
        NSString *strMsgId = [message objectForKey:@"msgId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageList deleteMessageWith:strMsgId];
        });
    }
}

- (void)cleanAllMessages{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageList cleanAllMessages];
    });
}

- (void)appendMessages:(NSNotification *) notification {
  NSArray *messages = [[notification object] copy];
  
  for (NSMutableDictionary *message in messages) {
      NSTimeInterval msgTime = [[message objectForKey:@"timeString"] doubleValue] ;
      if ((!_lastTime)||(fabs(_lastTime-msgTime) > 180)) {
          _lastTime = msgTime;
          _strLastMsgId = [message objectForKey:@"msgId"];
          [message setObject:[NSNumber numberWithBool:YES] forKey:@"isShowTime"];
      }else{
          [message setObject:[NSNumber numberWithBool:NO] forKey:@"isShowTime"];
      }
      [self appendImageMessage:message];
    RCTMessageModel * messageModel = [self convertMessageDicToModel:message];
      if (isShowMenuing) {
          [self.tmpMessageArr addObject:messageModel];
      }else{
          dispatch_async(dispatch_get_main_queue(), ^{
              [self.messageList appendMessageWith: messageModel];
          });
      }
  }
}

- (void)insertMessagesToTop:(NSNotification *) notification {
    NSArray *messages = [[notification object] copy];
    NSMutableArray *messageModels = [NSMutableArray array];
    NSTimeInterval insertTime = 0;
    NSMutableArray *tmpIMGArr = [NSMutableArray array];
    for (NSMutableDictionary *message in messages) {
        NSTimeInterval msgTime = [[message objectForKey:@"timeString"] doubleValue];
        if ((!insertTime)||(fabs(insertTime - msgTime) >180)) {
            insertTime = msgTime;
            [message setObject:[NSNumber numberWithBool:YES] forKey:@"isShowTime"];
        }else{
            [message setObject:[NSNumber numberWithBool:NO] forKey:@"isShowTime"];
        }
        NSString *strType = [message objectForKey:@"msgType"];
        if ([strType isEqualToString: @"image"]) {
            NSMutableDictionary *imgDict = [message objectForKey:@"extend"];
            [imgDict setObject:[message objectForKey:@"msgId"] forKey:@"msgId"];
            [tmpIMGArr insertObject:imgDict atIndex:0];
        }
        RCTMessageModel * messageModel = [self convertMessageDicToModel: message];
        [messageModels insertObject:messageModel atIndex:0];
    }
    for (NSMutableDictionary *imgD in tmpIMGArr) {
        [self.imageArr insertObject:imgD atIndex:0];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageList insertMessagesWith: messageModels];
    });
}
//添加图片message到数组
- (void)appendImageMessage:(NSMutableDictionary *)message{
    NSString *strType = [message objectForKey:@"msgType"];
    if ([strType isEqualToString: @"image"]) {
        NSString *strID = [message objectForKey:@"msgId"];
        NSMutableDictionary *imgDict = [message objectForKey:@"extend"];
        [imgDict setObject:strID forKey:@"msgId"];
        for (NSMutableDictionary *tmpDict in self.imageArr) {
            if ([[tmpDict objectForKey:@"msgId"] isEqualToString:strID]) {
                return;
            }
        }
        [self.imageArr addObject:imgDict];
    }
}



- (void)updateMessage:(NSNotification *) notification {
    NSMutableDictionary *message = [notification object];
    NSString *tmpId = [message objectForKey:@"msgId"];
    if ( [tmpId isEqualToString:_strLastMsgId]) {
        [message setObject:[NSNumber numberWithBool:YES] forKey:@"isShowTime"];
    }else{
        [message setObject:[NSNumber numberWithBool:NO] forKey:@"isShowTime"];
    }
      RCTMessageModel * messageModel = [self convertMessageDicToModel: message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageList updateMessageWith: messageModel];
    });
}

- (void)scrollToBottom:(NSNotification *) notification {
  BOOL animate = [[notification object] copy];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.messageList scrollToBottomWith:animate];
  });
}

- (void)clickRecordNotification:(NSNotification *)notification{
    NSString *strStatus = [[notification object] copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([strStatus isEqualToString:@"Start"]) {
            coverView.hidden = NO;
            recordView.time = @"60";
            recordView.status = UIRecordSoundStatusRecoding;
        }else if ([strStatus isEqualToString:@"Complete"]) {
            coverView.hidden = YES;
        }else if ([strStatus isEqualToString:@"Canceled"]) {
            coverView.hidden = YES;
        }else if ([strStatus isEqualToString:@"Continue"]) {
            recordView.status = UIRecordSoundStatusRecoding;
        }else if ([strStatus isEqualToString:@"Move"]) {
            recordView.status = UIRecordSoundStatusCancleSending;
        }else if ([strStatus isEqualToString:@"Short"]) {
            recordView.status = UIRecordSoundStatusRecordingShort;
//            sleep(1);
//            coverView.hidden = YES;
        }
    });
}

- (void)clickRecordLevelNotification:(NSNotification *)notification{
    NSDictionary *recordDict = [notification object];
    NSNumber *lowNum = [recordDict objectForKey:@"power"];
    CGFloat lowF = lowNum.floatValue;
    dispatch_async(dispatch_get_main_queue(), ^{
        recordView.level = lowF;
    });
    
}
                   
- (void)clickRecordLongTimeNotification:(NSNotification *)notification{
    NSNumber *longTime = [notification object];
    
    NSString *strTime = [NSString stringWithFormat:@"%zd",longTime.intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        recordView.time = strTime;
    });
}

- (void)clickChangeHeight:(NSNotification *)noti{
    NSDictionary *dict = noti.object;
    CGFloat height = [[dict objectForKey:@"listViewHeight"] floatValue] ;
    CGFloat tmpH = height - self.height;
    [UIView animateWithDuration:3 animations:^{
        self.height += tmpH;
    } completion:^(BOOL finished) {
         self.height = height;
    }];
    
   
}

- (void)clickLongTouchShowMenu:(NSNotification *)noti{
    NSString *isShowMenu = noti.object;
    if ([isShowMenu isEqualToString:@"showMenu"]) {
        isShowMenuing = YES;
    }else{
        isShowMenuing = NO;
        for (RCTMessageModel *model in _tmpMessageArr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messageList appendMessageWith: model];
            });
        }
        [_tmpMessageArr removeAllObjects];
    }
}


- (void)clickShowOrigImgView:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *strID = noti.object;
        if (_imageArr.count) {
            NSInteger index = 0;
            for (NSMutableDictionary *imgDict in _imageArr) {
                NSString *msgID = [imgDict objectForKey:@"msgId"];
                index ++;
                if ([strID isEqualToString:msgID]) {
                    break;
                }
            }
            if (index > 0) {
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                UIViewController *rootVC = win.rootViewController;
                DWShowImageVC *vc = [[DWShowImageVC alloc]init];
                vc.imageArr = _imageArr;
                vc.index = index;
                [rootVC presentViewController:vc animated:NO completion:nil];
            }
        }
    });
}

- (void)clickScanOrigImgView:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *strResult = noti.object;
        if (_delegate != nil) {
            [_delegate onClickScanImageView:strResult];
        }
    });

}


- (void)awakeFromNib {
  [super awakeFromNib];

}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  [self removeObserver:self forKeyPath:@"bounds"];

}


@end
