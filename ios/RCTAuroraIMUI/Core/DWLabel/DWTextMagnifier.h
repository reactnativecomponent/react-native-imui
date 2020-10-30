//
//  DWTextMagnifier.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>

#if __has_include(<DWText/DWText.h>)
#import <DWText/DWTextAttribute.h>
#else
#import "DWTextAttribute.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// Magnifier type
typedef NS_ENUM(NSInteger, DWTextMagnifierType) {
    DWTextMagnifierTypeCaret,  ///< Circular magnifier
    DWTextMagnifierTypeRanged, ///< Round rectangle magnifier
};

/**
 A magnifier view which can be displayed in `DWTextEffectWindow`.
 
 @discussion Use `magnifierWithType:` to create instance.
 Typically, you should not use this class directly.
 */
@interface DWTextMagnifier : UIView

/// Create a mangifier with the specified type. @param type The magnifier type.
+ (id)magnifierWithType:(DWTextMagnifierType)type;

@property (nonatomic, readonly) DWTextMagnifierType type;  ///< Type of magnifier
@property (nonatomic, readonly) CGSize fitSize;            ///< The 'best' size for magnifier view.
@property (nonatomic, readonly) CGSize snapshotSize;       ///< The 'best' snapshot image size for magnifier.
@property (nullable, nonatomic, strong) UIImage *snapshot; ///< The image in magnifier (readwrite).

@property (nullable, nonatomic, weak) UIView *hostView;   ///< The coordinate based view.
@property (nonatomic) CGPoint hostCaptureCenter;          ///< The snapshot capture center in `hostView`.
@property (nonatomic) CGPoint hostPopoverCenter;          ///< The popover center in `hostView`.
@property (nonatomic) BOOL hostVerticalForm;              ///< The host view is vertical form.
@property (nonatomic) BOOL captureDisabled;               ///< A hint for `DWTextEffectWindow` to disable capture.
@property (nonatomic) BOOL captureFadeAnimation;          ///< Show fade animation when the snapshot image changed.
@end

NS_ASSUME_NONNULL_END
