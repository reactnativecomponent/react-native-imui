//
//  DWRecordButton.m
//  RNNeteaseIm
//
//  Created by Dowin on 2017/6/27.
//  Copyright © 2017年 Dowin. All rights reserved.
//

#import "DWRecordButton.h"
#import <AVFoundation/AVFoundation.h>

#define kGetColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface DWRecordButton (){
    BOOL isAuthorized;//录音权限
}

@end


@implementation DWRecordButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = kGetColor(247, 247, 247);
        
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        self.layer.cornerRadius = 5.0f;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
        
        [self addTarget:self action:@selector(recordTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(recordTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(recordTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(recordTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(recordTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(recordTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(recordTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
        
    }
    return self;
}

- (void)setTextArr:(NSArray *)textArr{
    if (textArr) {
        NSString *fristText = [textArr firstObject];
        [self setTitle:fristText forState:UIControlStateNormal];
    }
    _textArr = textArr;
}


- (void)setButtonStateWithRecording
{
    self.backgroundColor = kGetColor(214, 215, 220); //214,215,220
    NSString *strSelect = (_textArr.count>1)?_textArr[1]:@"";
    [self setTitle:strSelect forState:UIControlStateNormal];
}

- (void)setButtonStateWithNormal
{
    self.backgroundColor = kGetColor(247, 247, 247);
    NSString *strNormal = (_textArr.count>0)?[_textArr firstObject]:@"";
    self.selected = NO;
    [self setTitle:strNormal forState:UIControlStateNormal];
}

- (void)setButtonStateWithCancel
{
    self.backgroundColor = kGetColor(214, 215, 220);
//    self.selected = NO;
    NSString *strCancel = (_textArr.count>2)?_textArr[2]:@"";
    [self setTitle:strCancel forState:UIControlStateNormal];
}

//判断录音权限
- (BOOL)canRecord
{
    isAuthorized = NO;
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    switch (AVstatus) {
            //允许状态
        case AVAuthorizationStatusAuthorized:
            isAuthorized = YES;
            NSLog(@"Authorized");
            break;
            //不允许状态，可以弹出一个alertview提示用户在隐私设置中开启权限
        case AVAuthorizationStatusDenied:
            NSLog(@"Denied");
            break;
            //未知，第一次申请权限
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"not Determined");
            //此应用程序没有被授权访问,可能是家长控制权限
        case AVAuthorizationStatusRestricted:{
            NSLog(@"Restricted");
            NSString *tips = @"请在iPhone的”设置-隐私-照片“选项中，允许App访问你的麦克风";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:tips delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
        }
            break;
        default:
             NSLog(@"default");
            break;
    }
    return isAuthorized;
}


#pragma mark -- 事件方法回调
- (void)recordTouchDown
{
//    [self canRecord];
    if ([self.delegate respondsToSelector:@selector(recordTouchDownAction:)] ) {
        [self.delegate recordTouchDownAction:self];
    }
}

- (void)recordTouchUpOutside
{
    if ([self.delegate respondsToSelector:@selector(recordTouchUpOutsideAction:)]) {
        [self.delegate recordTouchUpOutsideAction:self];
    }
}

- (void)recordTouchUpInside
{
    if ([self.delegate respondsToSelector:@selector(recordTouchUpInsideAction:)] ) {
        [self.delegate recordTouchUpInsideAction:self];
    }
}

- (void)recordTouchDragEnter
{
    if ([self.delegate respondsToSelector:@selector(recordTouchDragEnterAction:)] ) {
        [self.delegate recordTouchDragEnterAction:self];
    }
}

- (void)recordTouchDragInside
{
    if ([self.delegate respondsToSelector:@selector(recordTouchDragInsideAction:)]) {
        [self.delegate recordTouchDragInsideAction:self];
    }
}

- (void)recordTouchDragOutside
{
    if ([self.delegate respondsToSelector:@selector(recordTouchDragOutsideAction:)] ) {
        [self.delegate recordTouchDragOutsideAction:self];
    }
}

- (void)recordTouchDragExit
{
    if ([self.delegate respondsToSelector:@selector(recordTouchDragExitAction:)]) {
        [self.delegate recordTouchDragExitAction:self];
    }
}


@end
