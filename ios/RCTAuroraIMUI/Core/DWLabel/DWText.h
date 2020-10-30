//
//  DWText.h
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import <UIKit/UIKit.h>

#if __has_include(<DWText/DWText.h>)
FOUNDATION_EXPORT double DWTextVersionNumber;
FOUNDATION_EXPORT const unsigned char DWTextVersionString[];
#import <DWText/DWLabel.h>
#import <DWText/DWTextView.h>
#import <DWText/DWTextAttribute.h>
#import <DWText/DWTextArchiver.h>
#import <DWText/DWTextParser.h>
#import <DWText/DWTextRunDelegate.h>
#import <DWText/DWTextRubyAnnotation.h>
#import <DWText/DWTextLayout.h>
#import <DWText/DWTextLine.h>
#import <DWText/DWTextInput.h>
#import <DWText/DWTextDebugOption.h>
#import <DWText/DWTextKeyboardManager.h>
#import <DWText/DWTextUtilities.h>
#import <DWText/NSAttributedString+DWText.h>
#import <DWText/NSParagraphStyle+DWText.h>
#import <DWText/UIPasteboard+DWText.h>
#else
#import "DWLabel.h"
#import "DWTextView.h"
#import "DWTextAttribute.h"
#import "DWTextArchiver.h"
#import "DWTextParser.h"
#import "DWTextRunDelegate.h"
#import "DWTextRubyAnnotation.h"
#import "DWTextLayout.h"
#import "DWTextLine.h"
#import "DWTextInput.h"
#import "DWTextDebugOption.h"
#import "DWTextKeyboardManager.h"
#import "DWTextUtilities.h"
#import "NSAttributedString+DWText.h"
#import "NSParagraphStyle+DWText.h"
#import "UIPasteboard+DWText.h"
#endif

