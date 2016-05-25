/*
 https://github.com/waynezxcv/Gallop

 Copyright (c) 2016 waynezxcv <liuweiself@126.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "LWTextLine.h"
#import "LWTextAttachment.h"
#import <objc/runtime.h>
#import "GallopUtils.h"

@interface LWTextLine ()

@property (nonatomic,assign) CTLineRef CTLine;
@property (nonatomic,assign) CGPoint lineOrigin;

@property (nonatomic,assign) NSRange range;
@property (nonatomic,assign) CGRect frame;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;

@property (nonatomic,assign) CGFloat ascent;
@property (nonatomic,assign) CGFloat descent;
@property (nonatomic,assign) CGFloat leading;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGFloat trailingWhitespaceWidth;

@property (nonatomic,strong) NSMutableArray<LWTextAttachment *>* attachments;
@property (nonatomic,strong) NSMutableArray<NSValue *>* attachmentRanges;
@property (nonatomic,strong) NSMutableArray<NSValue *>* attachmentRects;

@property (nonatomic,assign) CGFloat firstGlyphPosition;

@end


@implementation LWTextLine


+ (id)lw_textLineWithCTlineRef:(CTLineRef)CTLine lineOrigin:(CGPoint)lineOrigin {
    if (!CTLine) {
        return nil;
    }
    LWTextLine* line = [[LWTextLine alloc] init];
    line.CTLine = CTLine;
    line.lineOrigin = lineOrigin;
    return line;
}

- (id)init {
    self = [super init];
    if (self) {
        self.lineWidth = 0.0f;
        self.ascent = 0.0f;
        self.descent = 0.0f;
        self.leading = 0.0f;
        self.firstGlyphPosition = 0.0f;
        self.trailingWhitespaceWidth = 0.0f;
        self.range = NSMakeRange(0, 0);
    }
    return self;
}

- (void)dealloc {
    if (self.CTLine) {
        CFRelease(self.CTLine);
    }
}

#pragma mark - Setter

- (void)setCTLine:(CTLineRef)CTLine {
    if (_CTLine != CTLine) {
        if (_CTLine) {
            CFRelease(_CTLine);
        }
        _CTLine = CFRetain(CTLine);
        if (_CTLine) {
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            self.lineWidth = CTLineGetTypographicBounds(_CTLine, &ascent, &descent, &leading);
            self.ascent = ascent;
            self.descent = descent;
            self.leading = leading;
            CFRange range = CTLineGetStringRange(_CTLine);
            self.range = NSMakeRange(range.location, range.length);
            if (CTLineGetGlyphCount(_CTLine) > 0) {
                CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
                CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
                CGPoint pos;
                CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
                self.firstGlyphPosition = pos.x;
            } else {
                self.firstGlyphPosition = 0.0f;
            }
            self.trailingWhitespaceWidth = CTLineGetTrailingWhitespaceWidth(_CTLine);
        }
        [self _calculatesTheBounds];
    }
}

- (void)setLineOrigin:(CGPoint)lineOrigin {
    _lineOrigin = lineOrigin;
    [self _calculatesTheBounds];
}

#pragma mark - Calculates

- (void)_calculatesTheBounds {
    self.frame = CGRectMake(self.lineOrigin.x + self.firstGlyphPosition,
                            self.lineOrigin.y - self.ascent,
                            self.lineWidth,
                            self.ascent + self.descent);
    if (!self.CTLine){
        return;
    }
    CFArrayRef runs = CTLineGetGlyphRuns(self.CTLine);
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) {
        return;
    }
    [self.attachments removeAllObjects];
    [self.attachmentRanges removeAllObjects];
    [self.attachmentRects removeAllObjects];
    for (NSUInteger i = 0; i < runCount; i ++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, i);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0) {
            continue;
        }
        NSDictionary* attributes = (id)CTRunGetAttributes(run);
        LWTextAttachment* attachment = [attributes objectForKey:LWTextAttachmentAttributeName];
        if (attachment) {
            CGPoint runPosition = CGPointZero;
            CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
            CGFloat ascent, descent, leading, runWidth;
            CGRect runTypoBounds;
            runWidth = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runPosition.x += self.lineOrigin.x;
            runPosition.y = self.lineOrigin.y - runPosition.y;
            runTypoBounds = CGRectMake(runPosition.x, runPosition.y - ascent, runWidth, ascent + descent);
            NSRange runRange = NSMakeRange(CTRunGetStringRange(run).location, CTRunGetStringRange(run).length);
            [self.attachments addObject:attachment];
            [self.attachmentRanges addObject:[NSValue valueWithRange:runRange]];
            [self.attachmentRects addObject:[NSValue valueWithCGRect:runTypoBounds]];
        }
    }
}

#pragma mark - Getter

- (NSMutableArray *)attachments {
    if (_attachments) {
        return _attachments;
    }
    _attachments = [[NSMutableArray alloc] init];
    return _attachments;
}

- (NSMutableArray *)attachmentRanges {
    if (_attachmentRanges) {
        return _attachmentRanges;
    }
    _attachmentRanges = [[NSMutableArray alloc] init];
    return _attachmentRanges;
}

- (NSMutableArray *)attachmentRects {
    if (_attachmentRects) {
        return _attachmentRects;
    }
    _attachmentRects = [[NSMutableArray alloc] init];
    return _attachmentRects;
}

- (CGSize)size {
    return self.frame.size;
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()


@end
