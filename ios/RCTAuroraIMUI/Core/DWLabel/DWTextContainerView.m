//
//  DWTextContainerView.m
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//



#import "DWTextContainerView.h"

@implementation DWTextContainerView{
    BOOL _attachmentChanged;
    NSMutableArray *_attachmentViews;
    NSMutableArray *_attachmentLayers;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];
    _attachmentViews = [NSMutableArray array];
    _attachmentLayers = [NSMutableArray array];
    return self;
}

- (void)setDebugOption:(DWTextDebugOption *)debugOption {
    BOOL needDraw = _debugOption.needDrawDebug;
    _debugOption = debugOption.copy;
    if (_debugOption.needDrawDebug != needDraw) {
        [self setNeedsDisplay];
    }
}

- (void)setTextVerticalAlignment:(DWTextVerticalAlignment)textVerticalAlignment {
    if (_textVerticalAlignment == textVerticalAlignment) return;
    _textVerticalAlignment = textVerticalAlignment;
    [self setNeedsDisplay];
}

- (void)setContentsFadeDuration:(NSTimeInterval)contentsFadeDuration {
    if (_contentsFadeDuration == contentsFadeDuration) return;
    _contentsFadeDuration = contentsFadeDuration;
    if (contentsFadeDuration <= 0) {
        [self.layer removeAnimationForKey:@"contents"];
    }
}

- (void)setLayout:(DWTextLayout *)layout {
    if (_layout == layout) return;
    _layout = layout;
    _attachmentChanged = YES;
    [self setNeedsDisplay];
}

- (void)setLayout:(DWTextLayout *)layout withFadeDuration:(NSTimeInterval)fadeDuration {
    self.contentsFadeDuration = fadeDuration;
    self.layout = layout;
}

- (void)drawRect:(CGRect)rect {
    // fade content
    [self.layer removeAnimationForKey:@"contents"];
    if (_contentsFadeDuration > 0) {
        CATransition *transition = [CATransition animation];
        transition.duration = _contentsFadeDuration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        transition.type = kCATransitionFade;
        [self.layer addAnimation:transition forKey:@"contents"];
    }
    
    // update attachment
    if (_attachmentChanged) {
        for (UIView *view in _attachmentViews) {
            if (view.superview == self) [view removeFromSuperview];
        }
        for (CALayer *layer in _attachmentLayers) {
            if (layer.superlayer == self.layer) [layer removeFromSuperlayer];
        }
        [_attachmentViews removeAllObjects];
        [_attachmentLayers removeAllObjects];
    }
    
    // draw layout
    CGSize boundingSize = _layout.textBoundingSize;
    CGPoint point = CGPointZero;
    if (_textVerticalAlignment == DWTextVerticalAlignmentCenter) {
        if (_layout.container.isVerticalForm) {
            point.x = -(self.bounds.size.width - boundingSize.width) * 0.5;
        } else {
            point.y = (self.bounds.size.height - boundingSize.height) * 0.5;
        }
    } else if (_textVerticalAlignment == DWTextVerticalAlignmentBottom) {
        if (_layout.container.isVerticalForm) {
            point.x = -(self.bounds.size.width - boundingSize.width);
        } else {
            point.y = (self.bounds.size.height - boundingSize.height);
        }
    }
    [_layout drawInContext:UIGraphicsGetCurrentContext() size:self.bounds.size point:point view:self layer:self.layer debug:_debugOption cancel:nil];
    
    // update attachment
    if (_attachmentChanged) {
        _attachmentChanged = NO;
        for (DWTextAttachment *a in _layout.attachments) {
            if ([a.content isKindOfClass:[UIView class]]) [_attachmentViews addObject:a.content];
            if ([a.content isKindOfClass:[CALayer class]]) [_attachmentLayers addObject:a.content];
        }
    }
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldSize, self.bounds.size)) {
        [self setNeedsLayout];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    [super setBounds:bounds];
    if (!CGSizeEqualToSize(oldSize, self.bounds.size)) {
        [self setNeedsLayout];
    }
}

#pragma mark - UIResponder forward

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [self.hostView canPerformAction:action withSender:sender];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.hostView;
}

@end


