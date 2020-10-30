//
//  NSAttributedString+DWText.m
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import "NSAttributedString+DWText.h"
#import "NSParagraphStyle+DWText.h"
#import "DWTextArchiver.h"
#import "DWTextRunDelegate.h"
#import "DWTextUtilities.h"
#import <CoreFoundation/CoreFoundation.h>


// Dummy class for category
@interface NSAttributedString_DWText : NSObject @end
@implementation NSAttributedString_DWText @end


static double _DWDeviceSystemVersion() {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

#ifndef kSystemVersion
#define kSystemVersion _DWDeviceSystemVersion()
#endif

#ifndef kiOS6Later
#define kiOS6Later (kSystemVersion >= 6)
#endif

#ifndef kiOS7Later
#define kiOS7Later (kSystemVersion >= 7)
#endif

#ifndef kiOS8Later
#define kiOS8Later (kSystemVersion >= 8)
#endif

#ifndef kiOS9Later
#define kiOS9Later (kSystemVersion >= 9)
#endif



@implementation NSAttributedString (DWText)

- (NSData *)DW_archiveToData {
    NSData *data = nil;
    @try {
        data = [DWTextArchiver archivedDataWithRootObject:self];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return data;
}

+ (instancetype)DW_unarchiveFromData:(NSData *)data {
    NSAttributedString *one = nil;
    @try {
        one = [DWTextUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    return one;
}

- (NSDictionary *)DW_attributesAtIndex:(NSUInteger)index {
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attributesAtIndex:index effectiveRange:NULL];
}

- (id)DW_attribute:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > self.length || self.length == 0) return nil;
    if (self.length > 0 && index == self.length) index--;
    return [self attribute:attributeName atIndex:index effectiveRange:NULL];
}

- (NSDictionary *)DW_attributes {
    return [self DW_attributesAtIndex:0];
}

- (UIFont *)DW_font {
    return [self DW_fontAtIndex:0];
}

- (UIFont *)DW_fontAtIndex:(NSUInteger)index {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    UIFont *font = [self DW_attribute:NSFontAttributeName atIndex:index];
    if (kSystemVersion <= 6) {
        if (font) {
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) {
                CTFontRef CTFont = (__bridge CTFontRef)(font);
                CFStringRef name = CTFontCopyPostScriptName(CTFont);
                CGFloat size = CTFontGetSize(CTFont);
                if (!name) {
                    font = nil;
                } else {
                    font = [UIFont fontWithName:(__bridge NSString *)(name) size:size];
                    CFRelease(name);
                }
            }
        }
    }
    return font;
}

- (NSNumber *)DW_kern {
    return [self DW_kernAtIndex:0];
}

- (NSNumber *)DW_kernAtIndex:(NSUInteger)index {
    return [self DW_attribute:NSKernAttributeName atIndex:index];
}

- (UIColor *)DW_color {
    return [self DW_colorAtIndex:0];
}

- (UIColor *)DW_colorAtIndex:(NSUInteger)index {
    UIColor *color = [self DW_attribute:NSForegroundColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self DW_attribute:(NSString *)kCTForegroundColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    if (color && ![color isKindOfClass:[UIColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [UIColor colorWithCGColor:(__bridge CGColorRef)(color)];
        } else {
            color = nil;
        }
    }
    return color;
}

- (UIColor *)DW_backgroundColor {
    return [self DW_backgroundColorAtIndex:0];
}

- (UIColor *)DW_backgroundColorAtIndex:(NSUInteger)index {
    return [self DW_attribute:NSBackgroundColorAttributeName atIndex:index];
}

- (NSNumber *)DW_strokeWidth {
    return [self DW_strokeWidthAtIndex:0];
}

- (NSNumber *)DW_strokeWidthAtIndex:(NSUInteger)index {
    return [self DW_attribute:NSStrokeWidthAttributeName atIndex:index];
}

- (UIColor *)DW_strokeColor {
    return [self DW_strokeColorAtIndex:0];
}

- (UIColor *)DW_strokeColorAtIndex:(NSUInteger)index {
    UIColor *color = [self DW_attribute:NSStrokeColorAttributeName atIndex:index];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self DW_attribute:(NSString *)kCTStrokeColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSShadow *)DW_shadow {
    return [self DW_shadowAtIndex:0];
}

- (NSShadow *)DW_shadowAtIndex:(NSUInteger)index {
    return [self DW_attribute:NSShadowAttributeName atIndex:index];
}

- (NSUnderlineStyle)DW_strikethroughStyle {
    return [self DW_strikethroughStyleAtIndex:0];
}

- (NSUnderlineStyle)DW_strikethroughStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self DW_attribute:NSStrikethroughStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)DW_strikethroughColor {
    return [self DW_strikethroughColorAtIndex:0];
}

- (UIColor *)DW_strikethroughColorAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:NSStrikethroughColorAttributeName atIndex:index];
    }
    return nil;
}

- (NSUnderlineStyle)DW_underlineStyle {
    return [self DW_underlineStyleAtIndex:0];
}

- (NSUnderlineStyle)DW_underlineStyleAtIndex:(NSUInteger)index {
    NSNumber *style = [self DW_attribute:NSUnderlineStyleAttributeName atIndex:index];
    return style.integerValue;
}

- (UIColor *)DW_underlineColor {
    return [self DW_underlineColorAtIndex:0];
}

- (UIColor *)DW_underlineColorAtIndex:(NSUInteger)index {
    UIColor *color = nil;
    if (kSystemVersion >= 7) {
        color = [self DW_attribute:NSUnderlineColorAttributeName atIndex:index];
    }
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self DW_attribute:(NSString *)kCTUnderlineColorAttributeName atIndex:index]);
        color = [UIColor colorWithCGColor:ref];
    }
    return color;
}

- (NSNumber *)DW_ligature {
    return [self DW_ligatureAtIndex:0];
}

- (NSNumber *)DW_ligatureAtIndex:(NSUInteger)index {
    return [self DW_attribute:NSLigatureAttributeName atIndex:index];
}

- (NSString *)DW_textEffect {
    return [self DW_textEffectAtIndex:0];
}

- (NSString *)DW_textEffectAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:NSTextEffectAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)DW_obliqueness {
    return [self DW_obliquenessAtIndex:0];
}

- (NSNumber *)DW_obliquenessAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:NSObliquenessAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)DW_expansion {
    return [self DW_expansionAtIndex:0];
}

- (NSNumber *)DW_expansionAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:NSExpansionAttributeName atIndex:index];
    }
    return nil;
}

- (NSNumber *)DW_baselineOffset {
    return [self DW_baselineOffsetAtIndex:0];
}

- (NSNumber *)DW_baselineOffsetAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:NSBaselineOffsetAttributeName atIndex:index];
    }
    return nil;
}

- (BOOL)DW_verticalGlyphForm {
    return [self DW_verticalGlyphFormAtIndex:0];
}

- (BOOL)DW_verticalGlyphFormAtIndex:(NSUInteger)index {
    NSNumber *num = [self DW_attribute:NSVerticalGlyphFormAttributeName atIndex:index];
    return num.boolValue;
}

- (NSString *)DW_language {
    return [self DW_languageAtIndex:0];
}

- (NSString *)DW_languageAtIndex:(NSUInteger)index {
    if (kSystemVersion >= 7) {
        return [self DW_attribute:(id)kCTLanguageAttributeName atIndex:index];
    }
    return nil;
}

- (NSArray *)DW_writingDirection {
    return [self DW_writingDirectionAtIndex:0];
}

- (NSArray *)DW_writingDirectionAtIndex:(NSUInteger)index {
    return [self DW_attribute:(id)kCTWritingDirectionAttributeName atIndex:index];
}

- (NSParagraphStyle *)DW_paragraphStyle {
    return [self DW_paragraphStyleAtIndex:0];
}

- (NSParagraphStyle *)DW_paragraphStyleAtIndex:(NSUInteger)index {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    NSParagraphStyle *style = [self DW_attribute:NSParagraphStyleAttributeName atIndex:index];
    if (style) {
        if (CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) { \
            style = [NSParagraphStyle DW_styleWithCTStyle:(__bridge CTParagraphStyleRef)(style)];
        }
    }
    return style;
}

#define ParagraphAttribute(_attr_) \
NSParagraphStyle *style = self.DW_paragraphStyle; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

#define ParagraphAttributeAtIndex(_attr_) \
NSParagraphStyle *style = [self DW_paragraphStyleAtIndex:index]; \
if (!style) style = [NSParagraphStyle defaultParagraphStyle]; \
return style. _attr_;

- (NSTextAlignment)DW_alignment {
    ParagraphAttribute(alignment);
}

- (NSLineBreakMode)DW_lineBreakMode {
    ParagraphAttribute(lineBreakMode);
}

- (CGFloat)DW_lineSpacing {
    ParagraphAttribute(lineSpacing);
}

- (CGFloat)DW_paragraphSpacing {
    ParagraphAttribute(paragraphSpacing);
}

- (CGFloat)DW_paragraphSpacingBefore {
    ParagraphAttribute(paragraphSpacingBefore);
}

- (CGFloat)DW_firstLineHeadIndent {
    ParagraphAttribute(firstLineHeadIndent);
}

- (CGFloat)DW_headIndent {
    ParagraphAttribute(headIndent);
}

- (CGFloat)DW_tailIndent {
    ParagraphAttribute(tailIndent);
}

- (CGFloat)DW_minimumLineHeight {
    ParagraphAttribute(minimumLineHeight);
}

- (CGFloat)DW_maximumLineHeight {
    ParagraphAttribute(maximumLineHeight);
}

- (CGFloat)DW_lineHeightMultiple {
    ParagraphAttribute(lineHeightMultiple);
}

- (NSWritingDirection)DW_baseWritingDirection {
    ParagraphAttribute(baseWritingDirection);
}

- (float)DW_hyphenationFactor {
    ParagraphAttribute(hyphenationFactor);
}

- (CGFloat)DW_defaultTabInterval {
    if (!kiOS7Later) return 0;
    ParagraphAttribute(defaultTabInterval);
}

- (NSArray *)DW_tabStops {
    if (!kiOS7Later) return nil;
    ParagraphAttribute(tabStops);
}

- (NSTextAlignment)DW_alignmentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(alignment);
}

- (NSLineBreakMode)DW_lineBreakModeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineBreakMode);
}

- (CGFloat)DW_lineSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineSpacing);
}

- (CGFloat)DW_paragraphSpacingAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacing);
}

- (CGFloat)DW_paragraphSpacingBeforeAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(paragraphSpacingBefore);
}

- (CGFloat)DW_firstLineHeadIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(firstLineHeadIndent);
}

- (CGFloat)DW_headIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(headIndent);
}

- (CGFloat)DW_tailIndentAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(tailIndent);
}

- (CGFloat)DW_minimumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(minimumLineHeight);
}

- (CGFloat)DW_maximumLineHeightAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(maximumLineHeight);
}

- (CGFloat)DW_lineHeightMultipleAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(lineHeightMultiple);
}

- (NSWritingDirection)DW_baseWritingDirectionAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(baseWritingDirection);
}

- (float)DW_hyphenationFactorAtIndex:(NSUInteger)index {
    ParagraphAttributeAtIndex(hyphenationFactor);
}

- (CGFloat)DW_defaultTabIntervalAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return 0;
    ParagraphAttributeAtIndex(defaultTabInterval);
}

- (NSArray *)DW_tabStopsAtIndex:(NSUInteger)index {
    if (!kiOS7Later) return nil;
    ParagraphAttributeAtIndex(tabStops);
}

#undef ParagraphAttribute
#undef ParagraphAttributeAtIndex

- (DWTextShadow *)DW_textShadow {
    return [self DW_textShadowAtIndex:0];
}

- (DWTextShadow *)DW_textShadowAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextShadowAttributeName atIndex:index];
}

- (DWTextShadow *)DW_textInnerShadow {
    return [self DW_textInnerShadowAtIndex:0];
}

- (DWTextShadow *)DW_textInnerShadowAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextInnerShadowAttributeName atIndex:index];
}

- (DWTextDecoration *)DW_textUnderline {
    return [self DW_textUnderlineAtIndex:0];
}

- (DWTextDecoration *)DW_textUnderlineAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextUnderlineAttributeName atIndex:index];
}

- (DWTextDecoration *)DW_textStrikethrough {
    return [self DW_textStrikethroughAtIndex:0];
}

- (DWTextDecoration *)DW_textStrikethroughAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextStrikethroughAttributeName atIndex:index];
}

- (DWTextBorder *)DW_textBorder {
    return [self DW_textBorderAtIndex:0];
}

- (DWTextBorder *)DW_textBorderAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextBorderAttributeName atIndex:index];
}

- (DWTextBorder *)DW_textBackgroundBorder {
    return [self DW_textBackgroundBorderAtIndex:0];
}

- (DWTextBorder *)DW_textBackgroundBorderAtIndex:(NSUInteger)index {
    return [self DW_attribute:DWTextBackedStringAttributeName atIndex:index];
}

- (CGAffineTransform)DW_textGlyphTransform {
    return [self DW_textGlyphTransformAtIndex:0];
}

- (CGAffineTransform)DW_textGlyphTransformAtIndex:(NSUInteger)index {
    NSValue *value = [self DW_attribute:DWTextGlyphTransformAttributeName atIndex:index];
    if (!value) return CGAffineTransformIdentity;
    return [value CGAffineTransformValue];
}

- (NSString *)DW_plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound ||range.length == NSNotFound) return nil;
    NSMutableString *result = [NSMutableString string];
    if (range.length == 0) return result;
    NSString *string = self.string;
    [self enumerateAttribute:DWTextBackedStringAttributeName inRange:range options:kNilOptions usingBlock:^(id value, NSRange range, BOOL *stop) {
        DWTextBackedString *backed = value;
        if (backed && backed.string) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:range]];
        }
    }];
    return result;
}

+ (NSMutableAttributedString *)DW_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                                        width:(CGFloat)width
                                                       ascent:(CGFloat)ascent
                                                      descent:(CGFloat)descent {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:DWTextAttachmentToken];
    
    DWTextAttachment *attach = [DWTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr DW_setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    DWTextRunDelegate *delegate = [DWTextRunDelegate new];
    delegate.width = width;
    delegate.ascent = ascent;
    delegate.descent = descent;
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr DW_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)DW_attachmentStringWithContent:(id)content
                                                  contentMode:(UIViewContentMode)contentMode
                                               attachmentSize:(CGSize)attachmentSize
                                                  alignToFont:(UIFont *)font
                                                    alignment:(DWTextVerticalAlignment)alignment {
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:DWTextAttachmentToken];
    
    DWTextAttachment *attach = [DWTextAttachment new];
    attach.content = content;
    attach.contentMode = contentMode;
    [atr DW_setTextAttachment:attach range:NSMakeRange(0, atr.length)];
    
    DWTextRunDelegate *delegate = [DWTextRunDelegate new];
    delegate.width = attachmentSize.width;
    switch (alignment) {
        case DWTextVerticalAlignmentTop: {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case DWTextVerticalAlignmentCenter: {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        } break;
        case DWTextVerticalAlignmentBottom: {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        } break;
        default: {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        } break;
    }
    
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    [atr DW_setRunDelegate:delegateRef range:NSMakeRange(0, atr.length)];
    if (delegate) CFRelease(delegateRef);
    
    return atr;
}

+ (NSMutableAttributedString *)DW_attachmentStringWithEmojiImage:(UIImage *)image
                                                        fontSize:(CGFloat)fontSize {
    if (!image || fontSize <= 0) return nil;
    
    BOOL hasAnim = NO;
    if (image.images.count > 1) {
        hasAnim = YES;
    } else if (NSProtocolFromString(@"DWAnimatedImage") &&
               [image conformsToProtocol:NSProtocolFromString(@"DWAnimatedImage")]) {
        NSNumber *frameCount = [image valueForKey:@"animatedImageFrameCount"];
        if (frameCount.intValue > 1) hasAnim = YES;
    }
    
    CGFloat ascent = DWTextEmojiGetAscentWithFontSize(fontSize);
    CGFloat descent = DWTextEmojiGetDescentWithFontSize(fontSize);
    CGRect bounding = DWTextEmojiGetGlyphBoundingRectWithFontSize(fontSize);
    
    DWTextRunDelegate *delegate = [DWTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width + 2 * bounding.origin.x;
    
    DWTextAttachment *attachment = [DWTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), bounding.origin.x, descent + bounding.origin.y, bounding.origin.x);
    if (hasAnim) {
        Class imageClass = NSClassFromString(@"DWAnimatedImageView");
        if (!imageClass) imageClass = [UIImageView class];
        UIImageView *view = (id)[imageClass new];
        view.frame = bounding;
        view.image = image;
        view.contentMode = UIViewContentModeScaleAspectFit;
        attachment.content = view;
    } else {
        attachment.content = image;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:DWTextAttachmentToken];
    [atr DW_setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr DW_setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}

- (NSRange)DW_rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (BOOL)DW_isSharedAttributesInAllRange {
    __block BOOL shared = YES;
    __block NSDictionary *firstAttrs = nil;
    [self enumerateAttributesInRange:self.DW_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (range.location == 0) {
            firstAttrs = attrs;
        } else {
            if (firstAttrs.count != attrs.count) {
                shared = NO;
                *stop = YES;
            } else if (firstAttrs) {
                if (![firstAttrs isEqualToDictionary:attrs]) {
                    shared = NO;
                    *stop = YES;
                }
            }
        }
    }];
    return shared;
}

- (BOOL)DW_canDrawWithUIKit {
    static NSMutableSet *failSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        failSet = [NSMutableSet new];
        [failSet addObject:(id)kCTGlyphInfoAttributeName];
        [failSet addObject:(id)kCTCharacterShapeAttributeName];
        if (kiOS7Later) {
            [failSet addObject:(id)kCTLanguageAttributeName];
        }
        [failSet addObject:(id)kCTRunDelegateAttributeName];
        [failSet addObject:(id)kCTBaselineClassAttributeName];
        [failSet addObject:(id)kCTBaselineInfoAttributeName];
        [failSet addObject:(id)kCTBaselineReferenceInfoAttributeName];
        if (kiOS8Later) {
            [failSet addObject:(id)kCTRubyAnnotationAttributeName];
        }
        [failSet addObject:DWTextShadowAttributeName];
        [failSet addObject:DWTextInnerShadowAttributeName];
        [failSet addObject:DWTextUnderlineAttributeName];
        [failSet addObject:DWTextStrikethroughAttributeName];
        [failSet addObject:DWTextBorderAttributeName];
        [failSet addObject:DWTextBackgroundBorderAttributeName];
        [failSet addObject:DWTextBlockBorderAttributeName];
        [failSet addObject:DWTextAttachmentAttributeName];
        [failSet addObject:DWTextHighlightAttributeName];
        [failSet addObject:DWTextGlyphTransformAttributeName];
    });
    
#define Fail { result = NO; *stop = YES; return; }
    __block BOOL result = YES;
    [self enumerateAttributesInRange:self.DW_rangeOfAll options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs.count == 0) return;
        for (NSString *str in attrs.allKeys) {
            if ([failSet containsObject:str]) Fail;
        }
        if (!kiOS7Later) {
            UIFont *font = attrs[NSFontAttributeName];
            if (CFGetTypeID((__bridge CFTypeRef)(font)) == CTFontGetTypeID()) Fail;
        }
        if (attrs[(id)kCTForegroundColorAttributeName] && !attrs[NSForegroundColorAttributeName]) Fail;
        if (attrs[(id)kCTStrokeColorAttributeName] && !attrs[NSStrokeColorAttributeName]) Fail;
        if (attrs[(id)kCTUnderlineColorAttributeName]) {
            if (!kiOS7Later) Fail;
            if (!attrs[NSUnderlineColorAttributeName]) Fail;
        }
        NSParagraphStyle *style = attrs[NSParagraphStyleAttributeName];
        if (style && CFGetTypeID((__bridge CFTypeRef)(style)) == CTParagraphStyleGetTypeID()) Fail;
    }];
    return result;
#undef Fail
}

@end

@implementation NSMutableAttributedString (DWText)

- (void)DW_setAttributes:(NSDictionary *)attributes {
    [self setDW_attributes:attributes];
}

- (void)setDW_attributes:(NSDictionary *)attributes {
    if (attributes == (id)[NSNull null]) attributes = nil;
    [self setAttributes:@{} range:NSMakeRange(0, self.length)];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self DW_setAttribute:key value:obj];
    }];
}

- (void)DW_setAttribute:(NSString *)name value:(id)value {
    [self DW_setAttribute:name value:value range:NSMakeRange(0, self.length)];
}

- (void)DW_setAttribute:(NSString *)name value:(id)value range:(NSRange)range {
    if (!name || [NSNull isEqual:name]) return;
    if (value && ![NSNull isEqual:value]) [self addAttribute:name value:value range:range];
    else [self removeAttribute:name range:range];
}

- (void)DW_removeAttributesInRange:(NSRange)range {
    [self setAttributes:nil range:range];
}

#pragma mark - Property Setter

- (void)setDW_font:(UIFont *)font {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self DW_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)setDW_kern:(NSNumber *)kern {
    [self DW_setKern:kern range:NSMakeRange(0, self.length)];
}

- (void)setDW_color:(UIColor *)color {
    [self DW_setColor:color range:NSMakeRange(0, self.length)];
}

- (void)setDW_backgroundColor:(UIColor *)backgroundColor {
    [self DW_setBackgroundColor:backgroundColor range:NSMakeRange(0, self.length)];
}

- (void)setDW_strokeWidth:(NSNumber *)strokeWidth {
    [self DW_setStrokeWidth:strokeWidth range:NSMakeRange(0, self.length)];
}

- (void)setDW_strokeColor:(UIColor *)strokeColor {
    [self DW_setStrokeColor:strokeColor range:NSMakeRange(0, self.length)];
}

- (void)setDW_shadow:(NSShadow *)shadow {
    [self DW_setShadow:shadow range:NSMakeRange(0, self.length)];
}

- (void)setDW_strikethroughStyle:(NSUnderlineStyle)strikethroughStyle {
    [self DW_setStrikethroughStyle:strikethroughStyle range:NSMakeRange(0, self.length)];
}

- (void)setDW_strikethroughColor:(UIColor *)strikethroughColor {
    [self DW_setStrikethroughColor:strikethroughColor range:NSMakeRange(0, self.length)];
}

- (void)setDW_underlineStyle:(NSUnderlineStyle)underlineStyle {
    [self DW_setUnderlineStyle:underlineStyle range:NSMakeRange(0, self.length)];
}

- (void)setDW_underlineColor:(UIColor *)underlineColor {
    [self DW_setUnderlineColor:underlineColor range:NSMakeRange(0, self.length)];
}

- (void)setDW_ligature:(NSNumber *)ligature {
    [self DW_setLigature:ligature range:NSMakeRange(0, self.length)];
}

- (void)setDW_textEffect:(NSString *)textEffect {
    [self DW_setTextEffect:textEffect range:NSMakeRange(0, self.length)];
}

- (void)setDW_obliqueness:(NSNumber *)obliqueness {
    [self DW_setObliqueness:obliqueness range:NSMakeRange(0, self.length)];
}

- (void)setDW_expansion:(NSNumber *)expansion {
    [self DW_setExpansion:expansion range:NSMakeRange(0, self.length)];
}

- (void)setDW_baselineOffset:(NSNumber *)baselineOffset {
    [self DW_setBaselineOffset:baselineOffset range:NSMakeRange(0, self.length)];
}

- (void)setDW_verticalGlyphForm:(BOOL)verticalGlyphForm {
    [self DW_setVerticalGlyphForm:verticalGlyphForm range:NSMakeRange(0, self.length)];
}

- (void)setDW_language:(NSString *)language {
    [self DW_setLanguage:language range:NSMakeRange(0, self.length)];
}

- (void)setDW_writingDirection:(NSArray *)writingDirection {
    [self DW_setWritingDirection:writingDirection range:NSMakeRange(0, self.length)];
}

- (void)setDW_paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self DW_setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setDW_alignment:(NSTextAlignment)alignment {
    [self DW_setAlignment:alignment range:NSMakeRange(0, self.length)];
}

- (void)setDW_baseWritingDirection:(NSWritingDirection)baseWritingDirection {
    [self DW_setBaseWritingDirection:baseWritingDirection range:NSMakeRange(0, self.length)];
}

- (void)setDW_lineSpacing:(CGFloat)lineSpacing {
    [self DW_setLineSpacing:lineSpacing range:NSMakeRange(0, self.length)];
}

- (void)setDW_paragraphSpacing:(CGFloat)paragraphSpacing {
    [self DW_setParagraphSpacing:paragraphSpacing range:NSMakeRange(0, self.length)];
}

- (void)setDW_paragraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    [self DW_setParagraphSpacing:paragraphSpacingBefore range:NSMakeRange(0, self.length)];
}

- (void)setDW_firstLineHeadIndent:(CGFloat)firstLineHeadIndent {
    [self DW_setFirstLineHeadIndent:firstLineHeadIndent range:NSMakeRange(0, self.length)];
}

- (void)setDW_headIndent:(CGFloat)headIndent {
    [self DW_setHeadIndent:headIndent range:NSMakeRange(0, self.length)];
}

- (void)setDW_tailIndent:(CGFloat)tailIndent {
    [self DW_setTailIndent:tailIndent range:NSMakeRange(0, self.length)];
}

- (void)setDW_lineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self DW_setLineBreakMode:lineBreakMode range:NSMakeRange(0, self.length)];
}

- (void)setDW_minimumLineHeight:(CGFloat)minimumLineHeight {
    [self DW_setMinimumLineHeight:minimumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setDW_maximumLineHeight:(CGFloat)maximumLineHeight {
    [self DW_setMaximumLineHeight:maximumLineHeight range:NSMakeRange(0, self.length)];
}

- (void)setDW_lineHeightMultiple:(CGFloat)lineHeightMultiple {
    [self DW_setLineHeightMultiple:lineHeightMultiple range:NSMakeRange(0, self.length)];
}

- (void)setDW_hyphenationFactor:(float)hyphenationFactor {
    [self DW_setHyphenationFactor:hyphenationFactor range:NSMakeRange(0, self.length)];
}

- (void)setDW_defaultTabInterval:(CGFloat)defaultTabInterval {
    [self DW_setDefaultTabInterval:defaultTabInterval range:NSMakeRange(0, self.length)];
}

- (void)setDW_tabStops:(NSArray *)tabStops {
    [self DW_setTabStops:tabStops range:NSMakeRange(0, self.length)];
}

- (void)setDW_textShadow:(DWTextShadow *)textShadow {
    [self DW_setTextShadow:textShadow range:NSMakeRange(0, self.length)];
}

- (void)setDW_textInnerShadow:(DWTextShadow *)textInnerShadow {
    [self DW_setTextInnerShadow:textInnerShadow range:NSMakeRange(0, self.length)];
}

- (void)setDW_textUnderline:(DWTextDecoration *)textUnderline {
    [self DW_setTextUnderline:textUnderline range:NSMakeRange(0, self.length)];
}

- (void)setDW_textStrikethrough:(DWTextDecoration *)textStrikethrough {
    [self DW_setTextStrikethrough:textStrikethrough range:NSMakeRange(0, self.length)];
}

- (void)setDW_textBorder:(DWTextBorder *)textBorder {
    [self DW_setTextBorder:textBorder range:NSMakeRange(0, self.length)];
}

- (void)setDW_textBackgroundBorder:(DWTextBorder *)textBackgroundBorder {
    [self DW_setTextBackgroundBorder:textBackgroundBorder range:NSMakeRange(0, self.length)];
}

- (void)setDW_textGlyphTransform:(CGAffineTransform)textGlyphTransform {
    [self DW_setTextGlyphTransform:textGlyphTransform range:NSMakeRange(0, self.length)];
}

#pragma mark - Range Setter

- (void)DW_setFont:(UIFont *)font range:(NSRange)range {
    /*
     In iOS7 and later, UIFont is toll-free bridged to CTFontRef,
     although Apple does not mention it in documentation.
     
     In iOS6, UIFont is a wrapper for CTFontRef, so CoreText can alse use UIfont,
     but UILabel/UITextView cannot use CTFontRef.
     
     We use UIFont for both CoreText and UIKit.
     */
    [self DW_setAttribute:NSFontAttributeName value:font range:range];
}

- (void)DW_setKern:(NSNumber *)kern range:(NSRange)range {
    [self DW_setAttribute:NSKernAttributeName value:kern range:range];
}

- (void)DW_setColor:(UIColor *)color range:(NSRange)range {
    [self DW_setAttribute:(id)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
    [self DW_setAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)DW_setBackgroundColor:(UIColor *)backgroundColor range:(NSRange)range {
    [self DW_setAttribute:NSBackgroundColorAttributeName value:backgroundColor range:range];
}

- (void)DW_setStrokeWidth:(NSNumber *)strokeWidth range:(NSRange)range {
    [self DW_setAttribute:NSStrokeWidthAttributeName value:strokeWidth range:range];
}

- (void)DW_setStrokeColor:(UIColor *)strokeColor range:(NSRange)range {
    [self DW_setAttribute:(id)kCTStrokeColorAttributeName value:(id)strokeColor.CGColor range:range];
    [self DW_setAttribute:NSStrokeColorAttributeName value:strokeColor range:range];
}

- (void)DW_setShadow:(NSShadow *)shadow range:(NSRange)range {
    [self DW_setAttribute:NSShadowAttributeName value:shadow range:range];
}

- (void)DW_setStrikethroughStyle:(NSUnderlineStyle)strikethroughStyle range:(NSRange)range {
    NSNumber *style = strikethroughStyle == 0 ? nil : @(strikethroughStyle);
    [self DW_setAttribute:NSStrikethroughStyleAttributeName value:style range:range];
}

- (void)DW_setStrikethroughColor:(UIColor *)strikethroughColor range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSStrikethroughColorAttributeName value:strikethroughColor range:range];
    }
}

- (void)DW_setUnderlineStyle:(NSUnderlineStyle)underlineStyle range:(NSRange)range {
    NSNumber *style = underlineStyle == 0 ? nil : @(underlineStyle);
    [self DW_setAttribute:NSUnderlineStyleAttributeName value:style range:range];
}

- (void)DW_setUnderlineColor:(UIColor *)underlineColor range:(NSRange)range {
    [self DW_setAttribute:(id)kCTUnderlineColorAttributeName value:(id)underlineColor.CGColor range:range];
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSUnderlineColorAttributeName value:underlineColor range:range];
    }
}

- (void)DW_setLigature:(NSNumber *)ligature range:(NSRange)range {
    [self DW_setAttribute:NSLigatureAttributeName value:ligature range:range];
}

- (void)DW_setTextEffect:(NSString *)textEffect range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSTextEffectAttributeName value:textEffect range:range];
    }
}

- (void)DW_setObliqueness:(NSNumber *)obliqueness range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSObliquenessAttributeName value:obliqueness range:range];
    }
}

- (void)DW_setExpansion:(NSNumber *)expansion range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSExpansionAttributeName value:expansion range:range];
    }
}

- (void)DW_setBaselineOffset:(NSNumber *)baselineOffset range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSBaselineOffsetAttributeName value:baselineOffset range:range];
    }
}

- (void)DW_setVerticalGlyphForm:(BOOL)verticalGlyphForm range:(NSRange)range {
    NSNumber *v = verticalGlyphForm ? @(YES) : nil;
    [self DW_setAttribute:NSVerticalGlyphFormAttributeName value:v range:range];
}

- (void)DW_setLanguage:(NSString *)language range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:(id)kCTLanguageAttributeName value:language range:range];
    }
}

- (void)DW_setWritingDirection:(NSArray *)writingDirection range:(NSRange)range {
    [self DW_setAttribute:(id)kCTWritingDirectionAttributeName value:writingDirection range:range];
}

- (void)DW_setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range {
    /*
     NSParagraphStyle is NOT toll-free bridged to CTParagraphStyleRef.
     
     CoreText can use both NSParagraphStyle and CTParagraphStyleRef,
     but UILabel/UITextView can only use NSParagraphStyle.
     
     We use NSParagraphStyle in both CoreText and UIKit.
     */
    [self DW_setAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

#define ParagraphStyleSet(_attr_) \
[self enumerateAttribute:NSParagraphStyleAttributeName \
                 inRange:range \
                 options:kNilOptions \
              usingBlock: ^(NSParagraphStyle *value, NSRange subRange, BOOL *stop) { \
                  NSMutableParagraphStyle *style = nil; \
                  if (value) { \
                      if (CFGetTypeID((__bridge CFTypeRef)(value)) == CTParagraphStyleGetTypeID()) { \
                          value = [NSParagraphStyle DW_styleWithCTStyle:(__bridge CTParagraphStyleRef)(value)]; \
                      } \
                      if (value. _attr_ == _attr_) return; \
                      if ([value isKindOfClass:[NSMutableParagraphStyle class]]) { \
                          style = (id)value; \
                      } else { \
                          style = value.mutableCopy; \
                      } \
                  } else { \
                      if ([NSParagraphStyle defaultParagraphStyle]. _attr_ == _attr_) return; \
                      style = [NSParagraphStyle defaultParagraphStyle].mutableCopy; \
                  } \
                  style. _attr_ = _attr_; \
                  [self DW_setParagraphStyle:style range:subRange]; \
              }];

- (void)DW_setAlignment:(NSTextAlignment)alignment range:(NSRange)range {
    ParagraphStyleSet(alignment);
}

- (void)DW_setBaseWritingDirection:(NSWritingDirection)baseWritingDirection range:(NSRange)range {
    ParagraphStyleSet(baseWritingDirection);
}

- (void)DW_setLineSpacing:(CGFloat)lineSpacing range:(NSRange)range {
    ParagraphStyleSet(lineSpacing);
}

- (void)DW_setParagraphSpacing:(CGFloat)paragraphSpacing range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacing);
}

- (void)DW_setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore range:(NSRange)range {
    ParagraphStyleSet(paragraphSpacingBefore);
}

- (void)DW_setFirstLineHeadIndent:(CGFloat)firstLineHeadIndent range:(NSRange)range {
    ParagraphStyleSet(firstLineHeadIndent);
}

- (void)DW_setHeadIndent:(CGFloat)headIndent range:(NSRange)range {
    ParagraphStyleSet(headIndent);
}

- (void)DW_setTailIndent:(CGFloat)tailIndent range:(NSRange)range {
    ParagraphStyleSet(tailIndent);
}

- (void)DW_setLineBreakMode:(NSLineBreakMode)lineBreakMode range:(NSRange)range {
    ParagraphStyleSet(lineBreakMode);
}

- (void)DW_setMinimumLineHeight:(CGFloat)minimumLineHeight range:(NSRange)range {
    ParagraphStyleSet(minimumLineHeight);
}

- (void)DW_setMaximumLineHeight:(CGFloat)maximumLineHeight range:(NSRange)range {
    ParagraphStyleSet(maximumLineHeight);
}

- (void)DW_setLineHeightMultiple:(CGFloat)lineHeightMultiple range:(NSRange)range {
    ParagraphStyleSet(lineHeightMultiple);
}

- (void)DW_setHyphenationFactor:(float)hyphenationFactor range:(NSRange)range {
    ParagraphStyleSet(hyphenationFactor);
}

- (void)DW_setDefaultTabInterval:(CGFloat)defaultTabInterval range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(defaultTabInterval);
}

- (void)DW_setTabStops:(NSArray *)tabStops range:(NSRange)range {
    if (!kiOS7Later) return;
    ParagraphStyleSet(tabStops);
}

#undef ParagraphStyleSet

- (void)DW_setSuperscript:(NSNumber *)superscript range:(NSRange)range {
    if ([superscript isEqualToNumber:@(0)]) {
        superscript = nil;
    }
    [self DW_setAttribute:(id)kCTSuperscriptAttributeName value:superscript range:range];
}

- (void)DW_setGlyphInfo:(CTGlyphInfoRef)glyphInfo range:(NSRange)range {
    [self DW_setAttribute:(id)kCTGlyphInfoAttributeName value:(__bridge id)glyphInfo range:range];
}

- (void)DW_setCharacterShape:(NSNumber *)characterShape range:(NSRange)range {
    [self DW_setAttribute:(id)kCTCharacterShapeAttributeName value:characterShape range:range];
}

- (void)DW_setRunDelegate:(CTRunDelegateRef)runDelegate range:(NSRange)range {
    [self DW_setAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
}

- (void)DW_setBaselineClass:(CFStringRef)baselineClass range:(NSRange)range {
    [self DW_setAttribute:(id)kCTBaselineClassAttributeName value:(__bridge id)baselineClass range:range];
}

- (void)DW_setBaselineInfo:(CFDictionaryRef)baselineInfo range:(NSRange)range {
    [self DW_setAttribute:(id)kCTBaselineInfoAttributeName value:(__bridge id)baselineInfo range:range];
}

- (void)DW_setBaselineReferenceInfo:(CFDictionaryRef)referenceInfo range:(NSRange)range {
    [self DW_setAttribute:(id)kCTBaselineReferenceInfoAttributeName value:(__bridge id)referenceInfo range:range];
}

- (void)DW_setRubyAnnotation:(CTRubyAnnotationRef)ruby range:(NSRange)range {
    if (kSystemVersion >= 8) {
        [self DW_setAttribute:(id)kCTRubyAnnotationAttributeName value:(__bridge id)ruby range:range];
    }
}

- (void)DW_setAttachment:(NSTextAttachment *)attachment range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSAttachmentAttributeName value:attachment range:range];
    }
}

- (void)DW_setLink:(id)link range:(NSRange)range {
    if (kSystemVersion >= 7) {
        [self DW_setAttribute:NSLinkAttributeName value:link range:range];
    }
}

- (void)DW_setTextBackedString:(DWTextBackedString *)textBackedString range:(NSRange)range {
    [self DW_setAttribute:DWTextBackedStringAttributeName value:textBackedString range:range];
}

- (void)DW_setTextBinding:(DWTextBinding *)textBinding range:(NSRange)range {
    [self DW_setAttribute:DWTextBindingAttributeName value:textBinding range:range];
}

- (void)DW_setTextShadow:(DWTextShadow *)textShadow range:(NSRange)range {
    [self DW_setAttribute:DWTextShadowAttributeName value:textShadow range:range];
}

- (void)DW_setTextInnerShadow:(DWTextShadow *)textInnerShadow range:(NSRange)range {
    [self DW_setAttribute:DWTextInnerShadowAttributeName value:textInnerShadow range:range];
}

- (void)DW_setTextUnderline:(DWTextDecoration *)textUnderline range:(NSRange)range {
    [self DW_setAttribute:DWTextUnderlineAttributeName value:textUnderline range:range];
}

- (void)DW_setTextStrikethrough:(DWTextDecoration *)textStrikethrough range:(NSRange)range {
    [self DW_setAttribute:DWTextStrikethroughAttributeName value:textStrikethrough range:range];
}

- (void)DW_setTextBorder:(DWTextBorder *)textBorder range:(NSRange)range {
    [self DW_setAttribute:DWTextBorderAttributeName value:textBorder range:range];
}

- (void)DW_setTextBackgroundBorder:(DWTextBorder *)textBackgroundBorder range:(NSRange)range {
    [self DW_setAttribute:DWTextBackgroundBorderAttributeName value:textBackgroundBorder range:range];
}

- (void)DW_setTextAttachment:(DWTextAttachment *)textAttachment range:(NSRange)range {
    [self DW_setAttribute:DWTextAttachmentAttributeName value:textAttachment range:range];
}

- (void)DW_setTextHighlight:(DWTextHighlight *)textHighlight range:(NSRange)range {
    [self DW_setAttribute:DWTextHighlightAttributeName value:textHighlight range:range];
}

- (void)DW_setTextBlockBorder:(DWTextBorder *)textBlockBorder range:(NSRange)range {
    [self DW_setAttribute:DWTextBlockBorderAttributeName value:textBlockBorder range:range];
}

- (void)DW_setTextRubyAnnotation:(DWTextRubyAnnotation *)ruby range:(NSRange)range {
    if (kiOS8Later) {
        CTRubyAnnotationRef rubyRef = [ruby CTRubyAnnotation];
        [self DW_setRubyAnnotation:rubyRef range:range];
        if (rubyRef) CFRelease(rubyRef);
    }
}

- (void)DW_setTextGlyphTransform:(CGAffineTransform)textGlyphTransform range:(NSRange)range {
    NSValue *value = CGAffineTransformIsIdentity(textGlyphTransform) ? nil : [NSValue valueWithCGAffineTransform:textGlyphTransform];
    [self DW_setAttribute:DWTextGlyphTransformAttributeName value:value range:range];
}

- (void)DW_setTextHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                        userInfo:(NSDictionary *)userInfo
                       tapAction:(DWTextAction)tapAction
                 longPressAction:(DWTextAction)longPressAction {
    DWTextHighlight *highlight = [DWTextHighlight highlightWithBackgroundColor:backgroundColor];
    highlight.userInfo = userInfo;
    highlight.tapAction = tapAction;
    highlight.longPressAction = longPressAction;
    if (color) [self DW_setColor:color range:range];
    [self DW_setTextHighlight:highlight range:range];
}

- (void)DW_setTextTapHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                       tapAction:(DWTextAction)tapAction {
    [self DW_setTextHighlightRange:range
                         color:color
               backgroundColor:backgroundColor
                      userInfo:nil
                     tapAction:tapAction
               longPressAction:nil];
}

- (void)DW_setTextUserInfoHighlightRange:(NSRange)range
                           color:(UIColor *)color
                 backgroundColor:(UIColor *)backgroundColor
                        userInfo:(NSDictionary *)userInfo {
    [self DW_setTextHighlightRange:range
                         color:color
               backgroundColor:backgroundColor
                      userInfo:userInfo
                     tapAction:nil
               longPressAction:nil];
}

- (void)DW_insertString:(NSString *)string atIndex:(NSUInteger)location {
    [self replaceCharactersInRange:NSMakeRange(location, 0) withString:string];
    [self DW_removeDiscontinuousAttributesInRange:NSMakeRange(location, string.length)];
}

- (void)DW_appendString:(NSString *)string {
    NSUInteger length = self.length;
    [self replaceCharactersInRange:NSMakeRange(length, 0) withString:string];
    [self DW_removeDiscontinuousAttributesInRange:NSMakeRange(length, string.length)];
}

- (void)DW_setClearColorToJoinedEmoji {
    NSString *str = self.string;
    if (str.length < 8) return;
    
    // Most string do not contains the joined-emoji, test the joiner first.
    BOOL containsJoiner = NO;
    {
        CFStringRef cfStr = (__bridge CFStringRef)str;
        BOOL needFree = NO;
        UniChar *chars = NULL;
        chars = (void *)CFStringGetCharactersPtr(cfStr);
        if (!chars) {
            chars = malloc(str.length * sizeof(UniChar));
            if (chars) {
                needFree = YES;
                CFStringGetCharacters(cfStr, CFRangeMake(0, str.length), chars);
            }
        }
        if (!chars) { // fail to get unichar..
            containsJoiner = YES;
        } else {
            for (int i = 0, max = (int)str.length; i < max; i++) {
                if (chars[i] == 0x200D) { // 'ZERO WIDTH JOINER' (U+200D)
                    containsJoiner = YES;
                    break;
                }
            }
            if (needFree) free(chars);
        }
    }
    if (!containsJoiner) return;
    
    // NSRegularExpression is designed to be immutable and thread safe.
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"((👨‍👩‍👧‍👦|👨‍👩‍👦‍👦|👨‍👩‍👧‍👧|👩‍👩‍👧‍👦|👩‍👩‍👦‍👦|👩‍👩‍👧‍👧|👨‍👨‍👧‍👦|👨‍👨‍👦‍👦|👨‍👨‍👧‍👧)+|(👨‍👩‍👧|👩‍👩‍👦|👩‍👩‍👧|👨‍👨‍👦|👨‍👨‍👧))" options:kNilOptions error:nil];
    });
    
    UIColor *clear = [UIColor clearColor];
    [regex enumerateMatchesInString:str options:kNilOptions range:NSMakeRange(0, str.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self DW_setColor:clear range:result.range];
    }];
}

- (void)DW_removeDiscontinuousAttributesInRange:(NSRange)range {
    NSArray *keys = [NSMutableAttributedString DW_allDiscontinuousAttributeKeys];
    for (NSString *key in keys) {
        [self removeAttribute:key range:range];
    }
}

+ (NSArray *)DW_allDiscontinuousAttributeKeys {
    static NSMutableArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[(id)kCTSuperscriptAttributeName,
                 (id)kCTRunDelegateAttributeName,
                 DWTextBackedStringAttributeName,
                 DWTextBindingAttributeName,
                 DWTextAttachmentAttributeName].mutableCopy;
        if (kiOS8Later) {
            [keys addObject:(id)kCTRubyAnnotationAttributeName];
        }
        if (kiOS7Later) {
            [keys addObject:NSAttachmentAttributeName];
        }
    });
    return keys;
}

@end

