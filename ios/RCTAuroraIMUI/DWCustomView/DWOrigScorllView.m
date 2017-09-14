//
//  DWOrigScorllView.m
//  DWTestProject
//
//  Created by Dowin on 2017/9/8.
//  Copyright © 2017年 Dowin. All rights reserved.
//

#import "DWOrigScorllView.h"
#import "DWActionSheetView.h"


#define margin 20

@interface DWOrigScorllView()<UIScrollViewDelegate,DWActionSheetViewDelegate>{
    NSInteger count;
    NSInteger showIndex;
    CGFloat fristContentX;
    UIButton *downBtn;
    UITapGestureRecognizer *tapGest;
    UILongPressGestureRecognizer *longGest;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (copy, nonatomic) NSMutableArray *imgArr;
@property (strong, nonatomic) DWOrigImageView *firstImageView;
@property (strong, nonatomic) DWOrigImageView *midImageView;
@property (strong, nonatomic) DWOrigImageView *lastImageView;
@property (strong, nonatomic) DWOrigImageView *codeImageView;
@property (copy, nonatomic) NSString *strScanResult;

@end

@implementation DWOrigScorllView

- (void)dealloc{
     [self removeGestureRecognizer:tapGest];
}

+ (instancetype)scrollViewWithDataArr:(NSArray *)dataArr andIndex:(NSInteger )index showDownBtnTime:(NSTimeInterval)time{
    DWOrigScorllView *scroll = [[DWOrigScorllView alloc]init];
    [scroll setupWithDataArr:dataArr andIndex:index showDownBtnTime:time];
    return scroll;
}

- (void)setupWithDataArr:(NSArray *)arr andIndex:(NSInteger )index showDownBtnTime:(NSTimeInterval)time{
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
    [self performSelector:@selector(showBtnDelayMethod) withObject:nil afterDelay:time];
}

- (void)showBtnDelayMethod{
    downBtn.hidden = NO;
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
    
    longGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(clickLongGest:)];
    [self addGestureRecognizer:longGest];
    
    CGFloat btnWH = 35;
    CGFloat btnX = screenW - btnWH - 20;
    CGFloat btnY = screenH - btnWH - 20;
    downBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnWH, btnWH)];
    [downBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(clickDownLoadBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downBtn];
    downBtn.hidden = YES;
    [self performSelector:@selector(delayMethod) withObject:nil  afterDelay:5.0];
}


- (void)clickTapGest{
    if ([self.delegate respondsToSelector:@selector(origImageViewClickTap)]) {
        [self.delegate origImageViewClickTap];
    }
}

//长按
- (void)clickLongGest:(UILongPressGestureRecognizer *)gest{
    if (gest.state == UIGestureRecognizerStateBegan){
        if (_scrollView.contentOffset.x == screenW+margin){//中间
            [self qrCodeWithImage:_midImageView];
        }else if (_scrollView.contentOffset.x == 0){
            [self qrCodeWithImage:_firstImageView];
        }else if(_scrollView.contentOffset.x == (screenW+margin)*2){
            [self qrCodeWithImage:_lastImageView];
        }
    }
}

- (void)qrCodeWithImage:(DWOrigImageView *)orgImgView{
    _codeImageView = orgImgView;
    NSMutableArray *titles = [NSMutableArray arrayWithObjects:@"保存图片", nil];
    
    NSData *imgData = UIImageJPEGRepresentation(orgImgView.imgView.image,1);
    UIImage *codeImg;
    if (imgData.length/1024 > 1000) {
        NSData *data = nil;
        data = UIImageJPEGRepresentation(orgImgView.imgView.image,0.1);
        codeImg = [UIImage imageWithData:data];
//        NSLog(@"压缩:%zd",imgData.length);
    }else{
        codeImg = orgImgView.imgView.image;
//        NSLog(@"原图");
    }
    //1. 初始化扫描仪，设置设别类型和识别质量
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
    //2. 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:codeImg.CGImage]];
    if (features.count) {
        //3. 获取扫描结果
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        [titles addObject:@"识别图中二维码"];
        _strScanResult = scannedResult;
    }else{
        _strScanResult = @"";
    }
    DWActionSheetView *alertSheetView = [[DWActionSheetView alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:titles];
    [alertSheetView xxy_show];
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

#pragma mark - XXYActionSheetViewDelegate
- (void)actionSheet:(DWActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex){
        if (buttonIndex == 0) {//保存图片
            [_codeImageView saveImage];
        }else if(buttonIndex == 1){//识别二维码
            if ([self.delegate respondsToSelector:@selector(origImageViewClickScannedImg:)]) {
                [self.delegate origImageViewClickScannedImg:_strScanResult];
            }
        }
    }
}

@end
