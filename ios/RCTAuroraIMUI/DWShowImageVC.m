//
//  DWShowImageVC.m
//  RCTAuroraIMUI
//
//  Created by Dowin on 2017/9/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//

#import "DWShowImageVC.h"
#import "DWOrigScorllView.h"
#import "UIView+Extend.h"

@interface DWShowImageVC ()<DWOrigImageViewDelegate>
@property (strong, nonatomic) DWOrigScorllView *scroll;
@end

@implementation DWShowImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _scroll = [DWOrigScorllView scrollViewWithDataArr:_imageArr andIndex:(_index-1) showDownBtnTime:0.3];
    _scroll.delegate = self;
    _scroll.frame = CGRectMake(0, 0, screenW, screenH);
    [[UIApplication sharedApplication].keyWindow addSubview:_scroll];
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=[NSNumber numberWithFloat:0.3];
    animation.toValue=[NSNumber numberWithFloat:1.0];
    animation.duration=0.2;
    animation.autoreverses=NO;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    [_scroll.layer addAnimation:animation forKey:@"zoom"];

}

- (BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark orgDelegate
- (void)origImageViewClickTap{
    [self dismissViewControllerAnimated:NO completion:nil];
    [UIView animateWithDuration:0.3 animations:^{
        _scroll.alpha -= 1.0;
    } completion:^(BOOL finished) {
        [_scroll removeFromSuperview];
    }];
}

- (void)origImageViewClickScannedImg:(NSString *)strScan{
    [self dismissViewControllerAnimated:NO completion:^{
        [_scroll removeFromSuperview];
         [[NSNotificationCenter defaultCenter]postNotificationName:@"DWOrigImageViewScanNotificatiom" object:strScan];
    }];
   
    
}

@end
