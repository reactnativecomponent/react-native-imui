//
//  UIPasteboard+DWText.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Extend UIPasteboard to support image and attributed string.
 */
@interface UIPasteboard (DWText)

@property (nullable, nonatomic, copy) NSData *DW_PNGData;    ///< PNG file data
@property (nullable, nonatomic, copy) NSData *DW_JPEGData;   ///< JPEG file data
@property (nullable, nonatomic, copy) NSData *DW_GIFData;    ///< GIF file data
@property (nullable, nonatomic, copy) NSData *DW_WEBPData;   ///< WebP file data
@property (nullable, nonatomic, copy) NSData *DW_ImageData;  ///< image file data

/// Attributed string,
/// Set this attributed will also set the string property which is copy from the attributed string.
/// If the attributed string contains one or more image, it will also set the `images` property.
@property (nullable, nonatomic, copy) NSAttributedString *DW_AttributedString;

@end


/// The name identifying the attributed string in pasteboard.
UIKIT_EXTERN NSString *const DWTextPasteboardTypeAttributedString;

/// The UTI Type identifying WebP data in pasteboard.
UIKIT_EXTERN NSString *const DWTextUTTypeWEBP;

NS_ASSUME_NONNULL_END
