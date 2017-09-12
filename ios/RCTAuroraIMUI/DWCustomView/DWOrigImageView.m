//
//  DWOrigImageView.m
//  RCTAuroraIMUI
//
//  Created by Dowin on 2017/9/8.
//  Copyright © 2017年 HXHG. All rights reserved.
//



#import "DWOrigImageView.h"
#import "UIView+Extend.h"



@interface DWOrigImageView (){
    UIScrollView *contentScrollView;
    
    UIPinchGestureRecognizer *pinchGest;

    CGRect orginFrame;
    
    
}

@end

@implementation DWOrigImageView

- (void)dealloc{
    [self.imgView removeGestureRecognizer:pinchGest];

}

+ (instancetype)origImgViewWithDict:(NSDictionary *)dict{
    DWOrigImageView *orgView = [[DWOrigImageView alloc]init];
    [orgView setupImgViewWithDict:dict];
    return orgView;
}


- (void)setupImgViewWithDict:(NSDictionary *)dict{
    NSString *thumbPath = [dict objectForKey:@"thumbPath"];
    NSString *strUrl = [dict objectForKey:@"url"];
    UIImage *placeImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:thumbPath]];
    [self.imgView setImageURL:strUrl placeImage:placeImg];
//    imgView.image = [UIImage imageNamed:strUrl];
    NSNumber *numW = [dict objectForKey:@"imageWidth"];
    NSNumber *numH = [dict objectForKey:@"imageHeight"];
    CGFloat multiple = numW.floatValue / numH.floatValue;
    CGFloat imgW = screenW;
    CGFloat imgH = imgW / multiple;
    CGFloat imgY = 0;
    if (imgH < screenH) {
        imgY = (screenH-imgH)*0.5;
    }
    self.imgView.frame = CGRectMake(0, imgY, imgW, imgH);
    contentScrollView.contentSize = CGSizeMake(imgW, imgH);
    orginFrame = self.imgView.frame;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    
    contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:contentScrollView];
    self.imgView = [[MyCacheImageView alloc]init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.userInteractionEnabled = YES;
    self.imgView.multipleTouchEnabled = YES;
    [contentScrollView addSubview:self.imgView];
    pinchGest = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(clickPinchView:)];
    [self.imgView addGestureRecognizer:pinchGest];
}

- (void)saveImage{
    UIImageWriteToSavedPhotosAlbum(self.imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}


- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}



- (void)restoreView{
    self.imgView.frame = orginFrame;
    contentScrollView.contentSize = CGSizeMake(screenW, orginFrame.size.height);
}


- (void)clickPinchView:(UIPinchGestureRecognizer *)gest{
    UIView *view = gest.view;
    if (gest.state == UIGestureRecognizerStateBegan || gest.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, gest.scale, gest.scale);
        gest.scale = 1;
    }
    if (gest.state == UIGestureRecognizerStateEnded) {
        if (view.frame.size.width < screenW) {
            CGFloat tmpW = screenW - view.width;
            CGFloat tmpH = orginFrame.size.height - view.height;
            [UIView animateWithDuration:0.3 animations:^{
                view.width += tmpW;
                view.height += tmpH;
                view.x -= tmpW*0.5;
                view.y -= tmpH*0.5;
                
            } completion:^(BOOL finished) {
                view.frame = orginFrame;
                if (contentScrollView.contentSize.width != screenW) {
                    contentScrollView.contentSize = CGSizeMake(screenW, orginFrame.size.height);
                }
            }];
            
            
        }else if (view.width > 1.5 * screenW) {
            CGFloat maxH = view.height - orginFrame.size.height*1.5;
            CGFloat maxW = view.width - screenW*1.5;
            [UIView animateWithDuration:0.3 animations:^{
                view.width -= maxW;
                view.height -= maxH;
                view.x += maxW*0.5;
                view.y += maxH*0.5;
            }completion:^(BOOL finished) {
                if (contentScrollView.contentSize.width != orginFrame.size.width*1.5) {
                    
                    if (orginFrame.size.height*1.5>screenH) {
                        contentScrollView.contentSize = CGSizeMake(orginFrame.size.width*1.5, orginFrame.size.height*1.5);
                        contentScrollView.contentOffset = CGPointMake(-view.x, -view.y);
                        view.x = 0;
                        view.y = 0;
                    }else{
                        contentScrollView.contentSize = CGSizeMake(orginFrame.size.width*1.5, screenH);
                        contentScrollView.contentOffset = CGPointMake(-view.x, contentScrollView.contentOffset.y);
                        view.x = 0;
                    }
                }
            }];
            
            
        }else{
            if (contentScrollView.contentSize.width != view.width) {
                if (view.height>screenH) {
                    contentScrollView.contentSize = CGSizeMake(view.width, view.height);
                    contentScrollView.contentOffset = CGPointMake(-view.x, -view.y);
                    view.x = 0;
                    view.y = 0;
                }else{
                    contentScrollView.contentSize = CGSizeMake(view.width, screenH);
                    contentScrollView.contentOffset = CGPointMake(-view.x, contentScrollView.contentOffset.y);
                    view.x = 0;
                }
            }
        }
    }
}


@end
