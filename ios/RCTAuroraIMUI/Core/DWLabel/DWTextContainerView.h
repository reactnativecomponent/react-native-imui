//
//  DWTextContainerView.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "DWTextLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWTextContainerView : UIView

@property (nullable, nonatomic, weak) UIView *hostView;

/// Debug option for layout debug. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, copy) DWTextDebugOption *debugOption;

/// Text vertical alignment.
@property (nonatomic) DWTextVerticalAlignment textVerticalAlignment;

/// Text layout. Set this property will let the view redraw it's contents.
@property (nullable, nonatomic, strong) DWTextLayout *layout;

/// The contents fade animation duration when the layout's contents changed. Default is 0 (no animation).
@property (nonatomic) NSTimeInterval contentsFadeDuration;

/// Convenience method to set `layout` and `contentsFadeDuration`.
/// @param layout  Same as `layout` property.
/// @param fadeDuration  Same as `contentsFadeDuration` property.
- (void)setLayout:(nullable DWTextLayout *)layout withFadeDuration:(NSTimeInterval)fadeDuration;


@end

NS_ASSUME_NONNULL_END
