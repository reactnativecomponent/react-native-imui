//
//  DWTextAttribute.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Enum Define

/// The attribute type
typedef NS_OPTIONS(NSInteger, DWTextAttributeType) {
    DWTextAttributeTypeNone     = 0,
    DWTextAttributeTypeUIKit    = 1 << 0, ///< UIKit attributes, such as UILabel/UITextField/drawInRect.
    DWTextAttributeTypeCoreText = 1 << 1, ///< CoreText attributes, used by CoreText.
    DWTextAttributeTypeDWText   = 1 << 2, ///< DWText attributes, used by DWText.
};

/// Get the attribute type from an attribute name.
extern DWTextAttributeType DWTextAttributeGetType(NSString *attributeName);

/**
 Line style in DWText (similar to NSUnderlineStyle).
 */
typedef NS_OPTIONS (NSInteger, DWTextLineStyle) {
    // basic style (bitmask:0xFF)
    DWTextLineStyleNone       = 0x00, ///< (        ) Do not draw a line (Default).
    DWTextLineStyleSingle     = 0x01, ///< (──────) Draw a single line.
    DWTextLineStyleThick      = 0x02, ///< (━━━━━━━) Draw a thick line.
    DWTextLineStyleDouble     = 0x09, ///< (══════) Draw a double line.
    
    // style pattern (bitmask:0xF00)
    DWTextLineStylePatternSolid      = 0x000, ///< (────────) Draw a solid line (Default).
    DWTextLineStylePatternDot        = 0x100, ///< (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    DWTextLineStylePatternDash       = 0x200, ///< (— — — —) Draw a line of dashes.
    DWTextLineStylePatternDashDot    = 0x300, ///< (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    DWTextLineStylePatternDashDotDot = 0x400, ///< (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    DWTextLineStylePatternCircleDot  = 0x900, ///< (••••••••••••) Draw a line of small circle dots.
};

/**
 Text vertical alignment.
 */
typedef NS_ENUM(NSInteger, DWTextVerticalAlignment) {
    DWTextVerticalAlignmentTop =    0, ///< Top alignment.
    DWTextVerticalAlignmentCenter = 1, ///< Center alignment.
    DWTextVerticalAlignmentBottom = 2, ///< Bottom alignment.
};

/**
 The direction define in DWText.
 */
typedef NS_OPTIONS(NSUInteger, DWTextDirection) {
    DWTextDirectionNone   = 0,
    DWTextDirectionTop    = 1 << 0,
    DWTextDirectionRight  = 1 << 1,
    DWTextDirectionBottom = 1 << 2,
    DWTextDirectionLeft   = 1 << 3,
};

/**
 The trunction type, tells the truncation engine which type of truncation is being requested.
 */
typedef NS_ENUM (NSUInteger, DWTextTruncationType) {
    /// No truncate.
    DWTextTruncationTypeNone   = 0,
    
    /// Truncate at the beginning of the line, leaving the end portion visible.
    DWTextTruncationTypeStart  = 1,
    
    /// Truncate at the end of the line, leaving the start portion visible.
    DWTextTruncationTypeEnd    = 2,
    
    /// Truncate in the middle of the line, leaving both the start and the end portions visible.
    DWTextTruncationTypeMiddle = 3,
};



#pragma mark - Attribute Name Defined in DWText

/// The value of this attribute is a `DWTextBackedString` object.
/// Use this attribute to store the original plain text if it is replaced by something else (such as attachment).
UIKIT_EXTERN NSString *const DWTextBackedStringAttributeName;

/// The value of this attribute is a `DWTextBinding` object.
/// Use this attribute to bind a range of text together, as if it was a single charactor.
UIKIT_EXTERN NSString *const DWTextBindingAttributeName;

/// The value of this attribute is a `DWTextShadow` object.
/// Use this attribute to add shadow to a range of text.
/// Shadow will be drawn below text glyphs. Use DWTextShadow.subShadow to add multi-shadow.
UIKIT_EXTERN NSString *const DWTextShadowAttributeName;

/// The value of this attribute is a `DWTextShadow` object.
/// Use this attribute to add inner shadow to a range of text.
/// Inner shadow will be drawn above text glyphs. Use DWTextShadow.subShadow to add multi-shadow.
UIKIT_EXTERN NSString *const DWTextInnerShadowAttributeName;

/// The value of this attribute is a `DWTextDecoration` object.
/// Use this attribute to add underline to a range of text.
/// The underline will be drawn below text glyphs.
UIKIT_EXTERN NSString *const DWTextUnderlineAttributeName;

/// The value of this attribute is a `DWTextDecoration` object.
/// Use this attribute to add strikethrough (delete line) to a range of text.
/// The strikethrough will be drawn above text glyphs.
UIKIT_EXTERN NSString *const DWTextStrikethroughAttributeName;

/// The value of this attribute is a `DWTextBorder` object.
/// Use this attribute to add cover border or cover color to a range of text.
/// The border will be drawn above the text glyphs.
UIKIT_EXTERN NSString *const DWTextBorderAttributeName;

/// The value of this attribute is a `DWTextBorder` object.
/// Use this attribute to add background border or background color to a range of text.
/// The border will be drawn below the text glyphs.
UIKIT_EXTERN NSString *const DWTextBackgroundBorderAttributeName;

/// The value of this attribute is a `DWTextBorder` object.
/// Use this attribute to add a code block border to one or more line of text.
/// The border will be drawn below the text glyphs.
UIKIT_EXTERN NSString *const DWTextBlockBorderAttributeName;

/// The value of this attribute is a `DWTextAttachment` object.
/// Use this attribute to add attachment to text.
/// It should be used in conjunction with a CTRunDelegate.
UIKIT_EXTERN NSString *const DWTextAttachmentAttributeName;

/// The value of this attribute is a `DWTextHighlight` object.
/// Use this attribute to add a touchable highlight state to a range of text.
UIKIT_EXTERN NSString *const DWTextHighlightAttributeName;

/// The value of this attribute is a `NSValue` object stores CGAffineTransform.
/// Use this attribute to add transform to each glyph in a range of text.
UIKIT_EXTERN NSString *const DWTextGlyphTransformAttributeName;



#pragma mark - String Token Define

UIKIT_EXTERN NSString *const DWTextAttachmentToken; ///< Object replacement character (U+FFFC), used for text attachment.
UIKIT_EXTERN NSString *const DWTextTruncationToken; ///< Horizontal ellipsis (U+2026), used for text truncation  "…".



#pragma mark - Attribute Value Define

/**
 The tap/long press action callback defined in DWText.
 
 @param containerView The text container view (such as DWLabel/DWTextView).
 @param text          The whole text.
 @param range         The text range in `text` (if no range, the range.location is NSNotFound).
 @param rect          The text frame in `containerView` (if no data, the rect is CGRectNull).
 */
typedef void(^DWTextAction)(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect);


/**
 DWTextBackedString objects are used by the NSAttributedString class cluster
 as the values for text backed string attributes (stored in the attributed
 string under the key named DWTextBackedStringAttributeName).
 
 It may used for copy/paste plain text from attributed string.
 Example: If :) is replace by a custom emoji (such as😊), the backed string can be set to @":)".
 */
@interface DWTextBackedString : NSObject <NSCoding, NSCopying>
+ (instancetype)stringWithString:(nullable NSString *)string;
@property (nullable, nonatomic, copy) NSString *string; ///< backed string
@end


/**
 DWTextBinding objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named DWTextBindingAttributeName).
 
 Add this to a range of text will make the specified characters 'binding together'.
 DWTextView will treat the range of text as a single character during text
 selection and edit.
 */
@interface DWTextBinding : NSObject <NSCoding, NSCopying>
+ (instancetype)bindingWithDeleteConfirm:(BOOL)deleteConfirm;
@property (nonatomic) BOOL deleteConfirm; ///< confirm the range when delete in DWTextView
@end


/**
 DWTextShadow objects are used by the NSAttributedString class cluster
 as the values for shadow attributes (stored in the attributed string under
 the key named DWTextShadowAttributeName or DWTextInnerShadowAttributeName).
 
 It's similar to `NSShadow`, but offers more options.
 */
@interface DWTextShadow : NSObject <NSCoding, NSCopying>
+ (instancetype)shadowWithColor:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

@property (nullable, nonatomic, strong) UIColor *color; ///< shadow color
@property (nonatomic) CGSize offset;                    ///< shadow offset
@property (nonatomic) CGFloat radius;                   ///< shadow blur radius
@property (nonatomic) CGBlendMode blendMode;            ///< shadow blend mode
@property (nullable, nonatomic, strong) DWTextShadow *subShadow;  ///< a sub shadow which will be added above the parent shadow

+ (instancetype)shadowWithNSShadow:(NSShadow *)nsShadow; ///< convert NSShadow to DWTextShadow
- (NSShadow *)nsShadow; ///< convert DWTextShadow to NSShadow
@end


/**
 DWTextDecorationLine objects are used by the NSAttributedString class cluster
 as the values for decoration line attributes (stored in the attributed string under
 the key named DWTextUnderlineAttributeName or DWTextStrikethroughAttributeName).
 
 When it's used as underline, the line is drawn below text glyphs;
 when it's used as strikethrough, the line is drawn above text glyphs.
 */
@interface DWTextDecoration : NSObject <NSCoding, NSCopying>
+ (instancetype)decorationWithStyle:(DWTextLineStyle)style;
+ (instancetype)decorationWithStyle:(DWTextLineStyle)style width:(nullable NSNumber *)width color:(nullable UIColor *)color;
@property (nonatomic) DWTextLineStyle style;                   ///< line style
@property (nullable, nonatomic, strong) NSNumber *width;       ///< line width (nil means automatic width)
@property (nullable, nonatomic, strong) UIColor *color;        ///< line color (nil means automatic color)
@property (nullable, nonatomic, strong) DWTextShadow *shadow;  ///< line shadow
@end


/**
 DWTextBorder objects are used by the NSAttributedString class cluster
 as the values for border attributes (stored in the attributed string under
 the key named DWTextBorderAttributeName or DWTextBackgroundBorderAttributeName).
 
 It can be used to draw a border around a range of text, or draw a background
 to a range of text.
 
 Example:
    ╭──────╮
    │ Text │
    ╰──────╯
 */
@interface DWTextBorder : NSObject <NSCoding, NSCopying>
+ (instancetype)borderWithLineStyle:(DWTextLineStyle)lineStyle lineWidth:(CGFloat)width strokeColor:(nullable UIColor *)color;
+ (instancetype)borderWithFillColor:(nullable UIColor *)color cornerRadius:(CGFloat)cornerRadius;
@property (nonatomic) DWTextLineStyle lineStyle;              ///< border line style
@property (nonatomic) CGFloat strokeWidth;                    ///< border line width
@property (nullable, nonatomic, strong) UIColor *strokeColor; ///< border line color
@property (nonatomic) CGLineJoin lineJoin;                    ///< border line join
@property (nonatomic) UIEdgeInsets insets;                    ///< border insets for text bounds
@property (nonatomic) CGFloat cornerRadius;                   ///< border corder radius
@property (nullable, nonatomic, strong) DWTextShadow *shadow; ///< border shadow
@property (nullable, nonatomic, strong) UIColor *fillColor;   ///< inner fill color
@end


/**
 DWTextAttachment objects are used by the NSAttributedString class cluster
 as the values for attachment attributes (stored in the attributed string under
 the key named DWTextAttachmentAttributeName).
 
 When display an attributed string which contains `DWTextAttachment` object,
 the content will be placed in text metric. If the content is `UIImage`,
 then it will be drawn to CGContext; if the content is `UIView` or `CALayer`,
 then it will be added to the text container's view or layer.
 */
@interface DWTextAttachment : NSObject<NSCoding, NSCopying>
+ (instancetype)attachmentWithContent:(nullable id)content;
@property (nullable, nonatomic, strong) id content;             ///< Supported type: UIImage, UIView, CALayer
@property (nonatomic) UIViewContentMode contentMode;            ///< Content display mode.
@property (nonatomic) UIEdgeInsets contentInsets;               ///< The insets when drawing content.
@property (nullable, nonatomic, strong) NSDictionary *userInfo; ///< The user information dictionary.
@end


/**
 DWTextHighlight objects are used by the NSAttributedString class cluster
 as the values for touchable highlight attributes (stored in the attributed string
 under the key named DWTextHighlightAttributeName).
 
 When display an attributed string in `DWLabel` or `DWTextView`, the range of
 highlight text can be toucheds down by users. If a range of text is turned into
 highlighted state, the `attributes` in `DWTextHighlight` will be used to modify
 (set or remove) the original attributes in the range for display.
 */
@interface DWTextHighlight : NSObject <NSCoding, NSCopying>

/**
 Attributes that you can apply to text in an attributed string when highlight.
 Key:   Same as CoreText/DWText Attribute Name.
 Value: Modify attribute value when highlight (NSNull for remove attribute).
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, id> *attributes;

/**
 Creates a highlight object with specified attributes.
 
 @param attributes The attributes which will replace original attributes when highlight,
        If the value is NSNull, it will removed when highlight.
 */
+ (instancetype)highlightWithAttributes:(nullable NSDictionary<NSString *, id> *)attributes;

/**
 Convenience methods to create a default highlight with the specifeid background color.
 
 @param color The background border color.
 */
+ (instancetype)highlightWithBackgroundColor:(nullable UIColor *)color;

// Convenience methods below to set the `attributes`.
- (void)setFont:(nullable UIFont *)font;
- (void)setColor:(nullable UIColor *)color;
- (void)setStrokeWidth:(nullable NSNumber *)width;
- (void)setStrokeColor:(nullable UIColor *)color;
- (void)setShadow:(nullable DWTextShadow *)shadow;
- (void)setInnerShadow:(nullable DWTextShadow *)shadow;
- (void)setUnderline:(nullable DWTextDecoration *)underline;
- (void)setStrikethrough:(nullable DWTextDecoration *)strikethrough;
- (void)setBackgroundBorder:(nullable DWTextBorder *)border;
- (void)setBorder:(nullable DWTextBorder *)border;
- (void)setAttachment:(nullable DWTextAttachment *)attachment;

/**
 The user information dictionary, default is nil.
 */
@property (nullable, nonatomic, copy) NSDictionary *userInfo;

/**
 Tap action when user tap the highlight, default is nil.
 If the value is nil, DWTextView or DWLabel will ask it's delegate to handle the tap action.
 */
@property (nullable, nonatomic, copy) DWTextAction tapAction;

/**
 Long press action when user long press the highlight, default is nil.
 If the value is nil, DWTextView or DWLabel will ask it's delegate to handle the long press action.
 */
@property (nullable, nonatomic, copy) DWTextAction longPressAction;

@end

NS_ASSUME_NONNULL_END

