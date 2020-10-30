//
//  UIPasteboard+DWText.m
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import "UIPasteboard+DWText.h"
#import "NSAttributedString+DWText.h"
#import <MobileCoreServices/MobileCoreServices.h>


#if __has_include("DWImage.h")
#import "DWImage.h"
#define DWTextAnimatedImageAvailable 1
#elif __has_include(<DWImage/DWImage.h>)
#import <DWImage/DWImage.h>
#define DWTextAnimatedImageAvailable 1
#elif __has_include(<DWWebImage/DWImage.h>)
#import <DWWebImage/DWImage.h>
#define DWTextAnimatedImageAvailable 1
#else
#define DWTextAnimatedImageAvailable 0
#endif


// Dummy class for category
@interface UIPasteboard_DWText : NSObject @end
@implementation UIPasteboard_DWText @end


NSString *const DWTextPasteboardTypeAttributedString = @"com.ibireme.NSAttributedString";
NSString *const DWTextUTTypeWEBP = @"com.google.webp";

@implementation UIPasteboard (DWText)


- (void)setDW_PNGData:(NSData *)PNGData {
    [self setData:PNGData forPasteboardType:(id)kUTTypePNG];
}

- (NSData *)DW_PNGData {
    return [self dataForPasteboardType:(id)kUTTypePNG];
}

- (void)setDW_JPEGData:(NSData *)JPEGData {
    [self setData:JPEGData forPasteboardType:(id)kUTTypeJPEG];
}

- (NSData *)DW_JPEGData {
    return [self dataForPasteboardType:(id)kUTTypeJPEG];
}

- (void)setDW_GIFData:(NSData *)GIFData {
    [self setData:GIFData forPasteboardType:(id)kUTTypeGIF];
}

- (NSData *)DW_GIFData {
    return [self dataForPasteboardType:(id)kUTTypeGIF];
}

- (void)setDW_WEBPData:(NSData *)WEBPData {
    [self setData:WEBPData forPasteboardType:DWTextUTTypeWEBP];
}

- (NSData *)DW_WEBPData {
    return [self dataForPasteboardType:DWTextUTTypeWEBP];
}

- (void)setDW_ImageData:(NSData *)imageData {
    [self setData:imageData forPasteboardType:(id)kUTTypeImage];
}

- (NSData *)DW_ImageData {
    return [self dataForPasteboardType:(id)kUTTypeImage];
}

- (void)setDW_AttributedString:(NSAttributedString *)attributedString {
    self.string = [attributedString DW_plainTextForRange:NSMakeRange(0, attributedString.length)];
    NSData *data = [attributedString DW_archiveToData];
    if (data) {
        NSDictionary *item = @{DWTextPasteboardTypeAttributedString : data};
        [self addItems:@[item]];
    }
    [attributedString enumerateAttribute:DWTextAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(DWTextAttachment *attachment, NSRange range, BOOL *stop) {
        
        // save image
        UIImage *simpleImage = nil;
        if ([attachment.content isKindOfClass:[UIImage class]]) {
            simpleImage = attachment.content;
        } else if ([attachment.content isKindOfClass:[UIImageView class]]) {
            simpleImage = ((UIImageView *)attachment.content).image;
        }
        if (simpleImage) {
            NSDictionary *item = @{@"com.apple.uikit.image" : simpleImage};
            [self addItems:@[item]];
        }
        
#if DWTextAnimatedImageAvailable
        // save animated image
        if ([attachment.content isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = attachment.content;
            Class aniImageClass = NSClassFromString(@"DWImage");
            UIImage *image = imageView.image;
            if (aniImageClass && [image isKindOfClass:aniImageClass]) {
                NSData *data = [image valueForKey:@"animatedImageData"];
                NSNumber *type = [image valueForKey:@"animatedImageType"];
                if (data) {
                    switch (type.unsignedIntegerValue) {
                        case DWImageTypeGIF: {
                            NSDictionary *item = @{(id)kUTTypeGIF : data};
                            [self addItems:@[item]];
                        } break;
                        case DWImageTypePNG: { // APNG
                            NSDictionary *item = @{(id)kUTTypePNG : data};
                            [self addItems:@[item]];
                        } break;
                        case DWImageTypeWebP: {
                            NSDictionary *item = @{(id)DWTextUTTypeWEBP : data};
                            [self addItems:@[item]];
                        } break;
                        default: break;
                    }
                }
            }
        }
#endif
        
    }];
}

- (NSAttributedString *)DW_AttributedString {
    for (NSDictionary *items in self.items) {
        NSData *data = items[DWTextPasteboardTypeAttributedString];
        if (data) {
            return [NSAttributedString DW_unarchiveFromData:data];
        }
    }
    return nil;
}

@end
