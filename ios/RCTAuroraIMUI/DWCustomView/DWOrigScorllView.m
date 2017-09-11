//
//  DWOrigScorllView.m
//  DWTestProject
//
//  Created by Dowin on 2017/9/8.
//  Copyright © 2017年 Dowin. All rights reserved.
//

#import "DWOrigScorllView.h"
#import "DWOrigImageView.h"

#define margin 20

@interface DWOrigScorllView()<UIScrollViewDelegate>{
    NSInteger count;
    NSInteger showIndex;
    CGFloat fristContentX;
    UIButton *downBtn;
    UITapGestureRecognizer *tapGest;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (copy, nonatomic) NSMutableArray *imgArr;
@property (strong, nonatomic) DWOrigImageView *firstImageView;
@property (strong, nonatomic) DWOrigImageView *midImageView;
@property (strong, nonatomic) DWOrigImageView *lastImageView;

@end

@implementation DWOrigScorllView

- (void)dealloc{
     [self removeGestureRecognizer:tapGest];
}

+ (instancetype)scrollViewWithDataArr:(NSArray *)dataArr andIndex:(NSInteger )index{
    DWOrigScorllView *scroll = [[DWOrigScorllView alloc]init];
    [scroll setupWithDataArr:dataArr andIndex:index];
    return scroll;
}

- (void)setupWithDataArr:(NSArray *)arr andIndex:(NSInteger )index{
    _imgArr = [arr copy];
    count = _imgArr.count;
    if (_imgArr.count == 1) {
        _scrollView.contentSize = CGSizeMake(screenW, [UIScreen mainScreen].bounds.size.height);
        _firstImageView = [DWOrigImageView origImgViewWithDict:_imgArr[0]];
        _firstImageView.frame = CGRectMake(0, 0, screenW, screenH);
        [_scrollView addSubview:_firstImageView];
    }else if (_imgArr.count == 2){
        if (index == 0) {
            fristContentX = 0;
        }else{
            fristContentX = screenW+margin;
        }
        _scrollView.contentSize = CGSizeMake(screenW*2+margin, [UIScreen mainScreen].bounds.size.height);
        _firstImageView = [DWOrigImageView origImgViewWithDict:_imgArr[0]];
        _firstImageView.frame = CGRectMake(0, 0, screenW, screenH);
        [_scrollView addSubview:_firstImageView];
        
        _midImageView = [DWOrigImageView origImgViewWithDict:_imgArr[1]];
        _midImageView.frame = CGRectMake(screenW+margin, 0, screenW, screenH);
        [_scrollView addSubview:_midImageView];
        _scrollView.contentOffset = CGPointMake(fristContentX, 0);
        
    }else if (_imgArr.count > 2){
        _scrollView.contentSize = CGSizeMake((screenW+margin)*2+screenW, [UIScreen mainScreen].bounds.size.height);
        NSInteger fristIndex = 0;
        NSInteger midIndex = 1;
        NSInteger lastIndex = 2;
        if (index == 0) {
            fristContentX = 0;
        }else if(index == (_imgArr.count-1)){
            fristIndex = count - 3;
            midIndex = count - 2;
            lastIndex = count - 1;
            fristContentX = (screenW+margin)*2;
        }else{
            fristIndex = index - 1;
            midIndex = index;
            lastIndex = index + 1;
            fristContentX = screenW+margin;
        }
        
        _firstImageView = [DWOrigImageView origImgViewWithDict:_imgArr[fristIndex]];
        _firstImageView.frame = CGRectMake(0, 0, screenW, screenH);
        [_scrollView addSubview:_firstImageView];
        _midImageView = [DWOrigImageView origImgViewWithDict:_imgArr[midIndex]];
        _midImageView.frame = CGRectMake(screenW+margin, 0, screenW, screenH);
        [_scrollView addSubview:_midImageView];
        
        _lastImageView = [DWOrigImageView origImgViewWithDict:_imgArr[lastIndex]];
        _lastImageView.frame = CGRectMake((screenW+margin)*2, 0, screenW, screenH);
        [_scrollView addSubview:_lastImageView];
        
        showIndex = index;
        _scrollView.contentOffset = CGPointMake(fristContentX, 0);
    }
}


- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenW, screenH)];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGest)];
    [self addGestureRecognizer:tapGest];
    
    CGFloat btnWH = 35;
    CGFloat btnX = screenW - btnWH - 20;
    CGFloat btnY = screenH - btnWH - 20;
    downBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
    [downBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(clickDownLoadBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downBtn];
    [self performSelector:@selector(delayMethod) withObject:nil  afterDelay:3.0];
}


- (void)clickTapGest{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RemoveDWOrigImgView" object:nil];
    [self removeFromSuperview];
}


- (void)delayMethod{
    [UIView animateWithDuration:0.5 animations:^{
        downBtn.alpha -= 1;
    } completion:^(BOOL finished) {
        downBtn.hidden = YES;
        downBtn.alpha = 1;
    }];
}

- (void)clickDownLoadBtn{//保存图片
    if (_scrollView.contentOffset.x == screenW+margin){//中间
        [_midImageView saveImage];
    }else if (_scrollView.contentOffset.x == 0){
        [_firstImageView saveImage];
    }else if(_scrollView.contentOffset.x == (screenW+margin)*2){
        [_lastImageView saveImage];
    }
}


#pragma mark -- scrollviewDelgate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (scrollView.contentOffset.x < screenW*0.5) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if ((scrollView.contentOffset.x < screenW+margin+screenW*0.5)&&(scrollView.contentOffset.x > screenW*0.5 )) {
        [scrollView setContentOffset:CGPointMake(screenW+margin, 0) animated:YES];
    }else{
        [scrollView setContentOffset:CGPointMake((screenW+margin)*2, 0) animated:YES];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x < screenW*0.5) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if ((scrollView.contentOffset.x < screenW+margin+screenW*0.5)&&(scrollView.contentOffset.x > screenW*0.5 )) {
        [scrollView setContentOffset:CGPointMake(screenW+margin, 0) animated:YES];
    }else{
        [scrollView setContentOffset:CGPointMake((screenW+margin)*2, 0) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (count > 3) {
        if ((scrollView.contentOffset.x == screenW+margin) && (fristContentX != scrollView.contentOffset.x)){//中间
            if (showIndex == 0) {
                showIndex += 1;
                [_firstImageView restoreView];
            }else{
                showIndex -= 1;
                [_lastImageView restoreView];
            }
            fristContentX = scrollView.contentOffset.x;
            
        }else if ((scrollView.contentOffset.x == 0) && (fristContentX != scrollView.contentOffset.x)){
            showIndex -= 1;
            if (showIndex != 0) {
                [_midImageView setupImgViewWithDict:_imgArr[showIndex]];
                [scrollView setContentOffset:CGPointMake(screenW+margin, 0) animated:NO];
                [_firstImageView setupImgViewWithDict:_imgArr[showIndex-1]];
                [_lastImageView setupImgViewWithDict:_imgArr[showIndex+1]];
            }
            fristContentX = scrollView.contentOffset.x;
            [_midImageView restoreView];
        }else if((scrollView.contentOffset.x == (screenW+margin)*2) && (fristContentX != scrollView.contentOffset.x)){
            
            showIndex += 1;
            if (showIndex != (_imgArr.count-1)) {
                [_midImageView setupImgViewWithDict:_imgArr[showIndex]];
                [scrollView setContentOffset:CGPointMake(screenW+margin, 0) animated:NO];
                [_firstImageView setupImgViewWithDict:_imgArr[showIndex-1]];
                [_lastImageView setupImgViewWithDict:_imgArr[showIndex+1]];
            }
            fristContentX = scrollView.contentOffset.x;
            [_midImageView restoreView];
        }
    }else if (count == 2){
        if ((scrollView.contentOffset.x == screenW+margin) && (fristContentX != scrollView.contentOffset.x)){//第二
            fristContentX = scrollView.contentOffset.x;
            [_firstImageView restoreView];
            
        }else if ((scrollView.contentOffset.x == 0) && (fristContentX != scrollView.contentOffset.x)){//第一
            
            fristContentX = scrollView.contentOffset.x;
            [_midImageView restoreView];
        }
    }
    else if (count == 3){
        if ((scrollView.contentOffset.x == screenW+margin) && (fristContentX != scrollView.contentOffset.x)){//第二
            fristContentX = scrollView.contentOffset.x;
            [_firstImageView restoreView];
            [_lastImageView restoreView];
            
        }else if ((scrollView.contentOffset.x == 0) && (fristContentX != scrollView.contentOffset.x)){//第一
            
            fristContentX = scrollView.contentOffset.x;
            [_midImageView restoreView];
        }else if((scrollView.contentOffset.x == (screenW+margin)*2) && (fristContentX != scrollView.contentOffset.x)){
            fristContentX = scrollView.contentOffset.x;
            [_midImageView restoreView];
        }
    }
}


@end
