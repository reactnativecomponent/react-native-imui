//
//  DWTextDebugOption.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>

@class DWTextDebugOption;

NS_ASSUME_NONNULL_BEGIN

/**
 The DWTextDebugTarget protocol defines the method a debug target should implement.
 A debug target can be add to the global container to receive the shared debug
 option changed notification.
 */
@protocol DWTextDebugTarget <NSObject>

@required
/**
 When the shared debug option changed, this method would be called on main thread.
 It should return as quickly as possible. The option's property should not be changed
 in this method.
 
 @param option  The shared debug option.
 */
- (void)setDebugOption:(nullable DWTextDebugOption *)option;
@end



/**
 The debug option for DWText.
 */
@interface DWTextDebugOption : NSObject <NSCopying>
@property (nullable, nonatomic, strong) UIColor *baselineColor;      ///< baseline color
@property (nullable, nonatomic, strong) UIColor *CTFrameBorderColor; ///< CTFrame path border color
@property (nullable, nonatomic, strong) UIColor *CTFrameFillColor;   ///< CTFrame path fill color
@property (nullable, nonatomic, strong) UIColor *CTLineBorderColor;  ///< CTLine bounds border color
@property (nullable, nonatomic, strong) UIColor *CTLineFillColor;    ///< CTLine bounds fill color
@property (nullable, nonatomic, strong) UIColor *CTLineNumberColor;  ///< CTLine line number color
@property (nullable, nonatomic, strong) UIColor *CTRunBorderColor;   ///< CTRun bounds border color
@property (nullable, nonatomic, strong) UIColor *CTRunFillColor;     ///< CTRun bounds fill color
@property (nullable, nonatomic, strong) UIColor *CTRunNumberColor;   ///< CTRun number color
@property (nullable, nonatomic, strong) UIColor *CGGlyphBorderColor; ///< CGGlyph bounds border color
@property (nullable, nonatomic, strong) UIColor *CGGlyphFillColor;   ///< CGGlyph bounds fill color

- (BOOL)needDrawDebug; ///< `YES`: at least one debug color is visible. `NO`: all debug color is invisible/nil.
- (void)clear; ///< Set all debug color to nil.

/**
 Add a debug target.
 
 @discussion When `setSharedDebugOption:` is called, all added debug target will
 receive `setDebugOption:` in main thread. It maintains an unsafe_unretained
 reference to this target. The target must to removed before dealloc.
 
 @param target A debug target.
 */
+ (void)addDebugTarget:(id<DWTextDebugTarget>)target;

/**
 Remove a debug target which is added by `addDebugTarget:`.
 
 @param target A debug target.
 */
+ (void)removeDebugTarget:(id<DWTextDebugTarget>)target;

/**
 Returns the shared debug option.
 
 @return The shared debug option, default is nil.
 */
+ (nullable DWTextDebugOption *)sharedDebugOption;

/**
 Set a debug option as shared debug option.
 This method must be called on main thread.
 
 @discussion When call this method, the new option will set to all debug target
 which is added by `addDebugTarget:`.
 
 @param option  A new debug option (nil is valid).
 */
+ (void)setSharedDebugOption:(nullable DWTextDebugOption *)option;

@end

NS_ASSUME_NONNULL_END

