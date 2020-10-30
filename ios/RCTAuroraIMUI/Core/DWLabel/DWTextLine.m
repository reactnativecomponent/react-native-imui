//
//  DWTextLine.m
//  RCTAuroraIMUI
//
//  Created by Kinooo Y on 2020/10/13.
//

#import "DWTextLine.h"
#import "DWTextUtilities.h"


@implementation DWTextLine {
    CGFloat _firstGlyphPos; // first glyph position for baseline, typically 0.
}

+ (instancetype)lineWithCTLine:(CTLineRef)CTLine position:(CGPoint)position vertical:(BOOL)isVertical {
    if (!CTLine) return nil;
    DWTextLine *line = [self new];
    line->_position = position;
    line->_vertical = isVertical;
    [line setCTLine:CTLine];
    return line;
}

- (void)dealloc {
    if (_CTLine) CFRelease(_CTLine);
}

- (void)setCTLine:(_Nonnull CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (CTLine) CFRetain(CTLine);
        if (_CTLine) CFRelease(_CTLine);
        _CTLine = CTLine;
        if (_CTLine) {
            _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
            CFRange range = CTLineGetStringRange(_CTLine);
            _range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                _firstGlyphPos = pos.x;
            } else {
                _firstGlyphPos = 0;
            }
            _trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        } else {
            _lineWidth = _ascent = _descent = _leading = _firstGlyphPos = _trailingWhitespaceWidth = 0;
            _range = NSMakeRange(0, 0);
        }
        [self reloadBounds];
    }
}

- (void)setPosition:(CGPoint)position {
    _position = position;
    [self reloadBounds];
}

- (void)reloadBounds {
    if (_vertical) {
        _bounds = CGRectMake(_position.x - _descent, _position.y, _ascent + _descent, _lineWidth);
        _bounds.origin.y += _firstGlyphPos;
    } else {
        _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + _descent);
        _bounds.origin.x += _firstGlyphPos;
    }
    
    _attachments = nil;
    _attachmentRanges = nil;
    _attachmentRects = nil;
    if (!_CTLine) return;
    CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
    
    NSMutableArray *attachments = [NSMutableArray new];
    NSMutableArray *attachmentRanges = [NSMutableArray new];
    NSMutableArray *attachmentRects = [NSMutableArray new];
    for (NSUInteger r = 0; r < runCount; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) continue;
        NSDictionary *attrs = (id)CTRunGetAttributes(run);
        DWTextAttachment *attachment = attrs[DWTextAttachmentAttributeName];
        if (attachment) {
            CGPoint runPosition = CGPointZero;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            
            CGFloat ascent, descent, leading, runWidth;
            CGRect runTypoBounds;
            runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            
            if (_vertical) {
                DWTEXT_SWAP(runPosition.x, runPosition.y);
                runPosition.y = _position.y + runPosition.y;
                runTypoBounds = CGRectMake(_position.x + runPosition.x - descent, runPosition.y , ascent + descent, runWidth);
            } else {
                runPosition.x += _position.x;
                runPosition.y = _position.y - runPosition.y;
                runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);
            }
            
            NSRange runRange = DWTextNSRangeFromCFRange(CTRunGetStringRange(run));
            [attachments addObject:attachment];
            [attachmentRanges addObject:[NSValue valueWithRange:runRange]];
            [attachmentRects addObject:[NSValue valueWithCGRect:runTypoBounds]];
        }
    }
    _attachments = attachments.count ? attachments : nil;
    _attachmentRanges = attachmentRanges.count ? attachmentRanges : nil;
    _attachmentRects = attachmentRects.count ? attachmentRects : nil;
}

- (CGSize)size {
    return _bounds.size;
}

- (CGFloat)width {
    return CGRectGetWidth(_bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(_bounds);
}

- (CGFloat)top {
    return CGRectGetMinY(_bounds);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(_bounds);
}

- (CGFloat)left {
    return CGRectGetMinX(_bounds);
}

- (CGFloat)right {
    return CGRectGetMaxX(_bounds);
}

- (NSString *)description {
    NSMutableString *desc = @"".mutableCopy;
    NSRange range = self.range;
    [desc appendFormat:@"<DWTextLine: %p> row:%zd range:%tu,%tu",self, self.row, range.location, range.length];
    [desc appendFormat:@" position:%@",NSStringFromCGPoint(self.position)];
    [desc appendFormat:@" bounds:%@",NSStringFromCGRect(self.bounds)];
    return desc;
}

@end


@implementation DWTextRunGlyphRange
+ (instancetype)rangeWithRange:(NSRange)range drawMode:(DWTextRunGlyphDrawMode)mode {
    DWTextRunGlyphRange *one = [self new];
    one.glyphRangeInRun = range;
    one.drawMode = mode;
    return one;
}
@end

