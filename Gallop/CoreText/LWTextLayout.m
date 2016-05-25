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


#import "LWTextLayout.h"
#import "LWTextLine.h"
#import "GallopUtils.h"
#import "CALayer+WebCache.h"
#import <objc/runtime.h>
#import "GallopUtils.h"


@interface LWTextLayout ()

@property (nonatomic,strong) LWTextContainer* container;
@property (nonatomic,strong) NSAttributedString* text;
@property (nonatomic,assign) CGRect cgPathBox;
@property (nonatomic,assign) CGPathRef cgPath;
@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic,assign) CTFramesetterRef ctFrameSetter;
@property (nonatomic,assign) CGSize suggestSize;
@property (nonatomic,strong) NSArray<LWTextLine *>* linesArray;
@property (nonatomic,assign) CGRect textBoundingRect;
@property (nonatomic,assign) CGSize textBoundingSize;
@property (nonatomic,strong) NSMutableArray<LWTextAttachment *>* attachments;
@property (nonatomic,strong) NSMutableArray<NSValue *>* attachmentRanges;
@property (nonatomic,strong) NSMutableArray<NSValue *>* attachmentRects;
@property (nonatomic,strong) NSMutableSet<id>* attachmentContentsSet;
@property (nonatomic,strong) NSMutableArray<LWTextHighlight *>* textHighlights;
@property (nonatomic,strong) NSMutableArray<LWTextBackgroundColor *>* backgroundColors;


@end


@implementation LWTextLayout

#pragma mark - Init

+ (LWTextLayout *)lw_layoutWithContainer:(LWTextContainer *)container text:(NSAttributedString *)text sizeToFit:(BOOL)sizeToFit {
    if (!text || !container) {
        return nil;
    }
    LWTextLayout* layout = [[self alloc] init];
    layout.sizeToFit = sizeToFit;
    NSMutableAttributedString* mutableAtrributedText = text.mutableCopy;
    //******* cgPath、cgPathBox *****//
    CGPathRef cgPath = container.path.CGPath;
    CGRect cgPathBox = CGPathGetPathBoundingBox(cgPath);
    //******* ctframeSetter、ctFrame *****//
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)mutableAtrributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(ctFrameSetter,CFRangeMake(0,text.length),NULL,CGSizeMake(cgPathBox.size.width, cgPathBox.size.height),NULL);
    if (layout.sizeToFit) {
        cgPathBox = CGRectMake(cgPathBox.origin.x, cgPathBox.origin.y,cgPathBox.size.width,suggestSize.height);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, cgPathBox);
        cgPath = CGPathCreateMutableCopy(path);
        CFRelease(path);
    } else {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, cgPathBox);
        cgPath = CGPathCreateMutableCopy(path);
        CFRelease(path);
    }
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter,CFRangeMake(0, mutableAtrributedText.length),cgPath,NULL);
    //******* LWTextLine *****//
    NSInteger rowIndex = -1;
    NSUInteger rowCount = 0;
    CGRect lastRect = CGRectMake(0.0f, - CGFLOAT_MAX, 0.0f, 0.0f);
    CGPoint lastPosition = CGPointMake(0.0f, - CGFLOAT_MAX);
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(ctLines);
    CGPoint* lineOrigins = NULL;
    if (lineCount > 0) {
        lineOrigins = malloc(lineCount * sizeof(CGPoint));
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    }
    //******* textBoundingRect、textBoundingSize ********//
    CGRect textBoundingRect = CGRectZero;
    CGSize textBoundingSize = CGSizeZero;
    NSUInteger lineCurrentIndex = 0;
    NSMutableArray* highlights = [[NSMutableArray alloc] init];
    NSMutableArray* backgroundColors = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < lineCount; i++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        CFIndex runCount = CFArrayGetCount(ctRuns);
        if (!ctRuns || runCount == 0){
            continue;
        }

        for (NSUInteger i = 0; i < runCount; i ++) {
            CTRunRef run = CFArrayGetValueAtIndex(ctRuns, i);
            CFIndex glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount == 0) {
                continue;
            }
            NSDictionary* attributes = (id)CTRunGetAttributes(run);
            LWTextHighlight* highlight = [attributes objectForKey:LWTextLinkAttributedName];
            if (highlight) {
                NSArray* highlightPositions = [self _highlightPositionsWithCtFrame:ctFrame range:highlight.range];
                highlight.positions = highlightPositions;
                if (![highlights containsObject:highlight]) {
                    [highlights addObject:highlight];
                }
            }
            LWTextBackgroundColor* color = [attributes objectForKey:LWTextBackgroundColorAttributedName];
            if (color) {
                NSArray* backgroundsPositions = [self _highlightPositionsWithCtFrame:ctFrame range:color.range];
                color.positions = backgroundsPositions;
                if (![backgroundColors containsObject:color]) {
                    [backgroundColors addObject:color];
                }
            }
        }
        CGPoint ctLineOrigin = lineOrigins[i];
        CGPoint position;
        position.x = cgPathBox.origin.x + ctLineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - ctLineOrigin.y;
        LWTextLine* line = [LWTextLine lw_textLineWithCTlineRef:ctLine lineOrigin:position];
        CGRect rect = line.frame;
        BOOL newRow = YES;
        if (position.x != lastPosition.x) {
            if (rect.size.height > lastRect.size.height) {
                if (rect.origin.y < lastPosition.y && lastPosition.y < rect.origin.y + rect.size.height) {
                    newRow = NO;
                }
            } else {
                if (lastRect.origin.y < position.y && position.y < lastRect.origin.y + lastRect.size.height) {
                    newRow = NO;
                }
            }
        }
        if (newRow){
            rowIndex ++;
        }
        lastRect = rect;
        lastPosition = position;
        line.index = lineCurrentIndex;
        line.row = rowIndex;
        [lines addObject:line];
        rowCount = rowIndex + 1;
        lineCurrentIndex ++;
        if (i == 0){
            textBoundingRect = rect;
        } else {
            textBoundingRect = CGRectUnion(textBoundingRect,rect);
        }
    }
    CFRelease(cgPath);
    cgPathBox = CGRectMake(cgPathBox.origin.x - container.edgeInsets.left,
                           cgPathBox.origin.y - container.edgeInsets.top,
                           cgPathBox.size.width + container.edgeInsets.left + container.edgeInsets.right,
                           cgPathBox.size.height + container.edgeInsets.top + container.edgeInsets.bottom);
    cgPath = [UIBezierPath bezierPathWithRect:cgPathBox].CGPath;
    layout.needTextBackgroundColorDraw = NO;
    layout.needAttachmentDraw = NO;
    layout.container = container;
    layout.text = mutableAtrributedText;
    layout.cgPath = cgPath;
    layout.cgPathBox = cgPathBox;
    layout.ctFrameSetter = ctFrameSetter;
    layout.ctFrame = ctFrame;
    layout.suggestSize = suggestSize;
    layout.linesArray = lines;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingSize;
    [layout.textHighlights addObjectsFromArray:highlights];
    [layout.backgroundColors addObjectsFromArray:backgroundColors];
    if (layout.backgroundColors.count > 0) {
        layout.needTextBackgroundColorDraw = YES;
    }
    //******* attachments ********//
    for (NSUInteger i = 0; i < layout.linesArray.count; i ++) {
        LWTextLine* line = lines[i];
        if (line.attachments.count > 0) {
            [layout.attachments addObjectsFromArray:line.attachments];
            [layout.attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [layout.attachmentRects addObjectsFromArray:line.attachmentRects];
            for (LWTextAttachment* attachment in line.attachments) {
                if (attachment.content) {
                    [layout.attachmentContentsSet addObject:attachment.content];
                }
            }
        }
    }
    if (layout.attachments.count > 0) {
        layout.needAttachmentDraw = YES;
    }
    if (lineOrigins){
        free(lineOrigins);
    }
    return layout;
}


- (id)init {
    self = [super init];
    if (self) {
        self.sizeToFit = YES;
        self.needDebugDraw = NO;
        self.attachments = [[NSMutableArray alloc] init];
        self.attachmentRanges = [[NSMutableArray alloc] init];
        self.attachmentRects = [[NSMutableArray alloc] init];
        self.attachmentContentsSet = [[NSMutableSet alloc] init];
        self.textHighlights = [[NSMutableArray alloc] init];
        self.backgroundColors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    if (self.ctFrame) {
        CFRelease(self.ctFrame);
    }
    if (self.ctFrameSetter) {
        CFRelease(self.ctFrameSetter);
    }
}

#pragma mark - Draw & Remove
- (void)drawIncontext:(CGContextRef)context
                 size:(CGSize)size
                point:(CGPoint)point
        containerView:(UIView *)containerView
       containerLayer:(CALayer *)containerLayer
          isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    if (self.isNeedTextBackgroundColorDraw) {
        [self _drawTextBackgroundColorInContext:context
                                     textLayout:self
                                           size:size
                                          point:point
                                    isCancelled:isCancelld];
    }

    if (self.isNeedDebugDraw) {
        [self _drawDebugInContext:context
                       textLayout:self
                             size:size
                            point:point
                      isCancelled:isCancelld];
    }
    [self _drawTextInContext:context
                  textLayout:self
                        size:size
                       point:point
                 isCancelled:isCancelld];

    if (self.isNeedAttachmentDraw) {
        [self _drawAttachmentsIncontext:context
                              textLayou:self
                                   size:size
                                  point:point
                          containerView:containerView
                         containerLayer:containerLayer
                            isCancelled:isCancelld];
    }
}

- (void)_drawTextBackgroundColorInContext:(CGContextRef)context
                               textLayout:(LWTextLayout *)textLayout
                                     size:(CGSize)size point:(CGPoint)point
                              isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld  {

    [textLayout.backgroundColors enumerateObjectsUsingBlock:^(LWTextBackgroundColor * _Nonnull background, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        for (NSValue* value in background.positions) {
            if (isCancelld()) {
                break;
            }
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(point.x + rect.origin.x, point.y + rect.origin.y, rect.size.width, rect.size.height);
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
            [background.backgroundColor setFill];
            [beizerPath fill];
        }
    }];
}

- (void)_drawDebugInContext:(CGContextRef) context
                 textLayout:(LWTextLayout *)textLayout
                       size:(CGSize)size
                      point:(CGPoint)point
                isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld  {
    CGContextAddRect(context, CGRectOffset(textLayout.cgPathBox, point.x, point.y));
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillPath(context);
    CGContextAddRect(context, CGRectOffset(textLayout.textBoundingRect,point.x,point.y));
    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextFillPath(context);
    [textLayout.linesArray enumerateObjectsUsingBlock:^(LWTextLine * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        CGContextMoveToPoint(context,line.lineOrigin.x + point.x,(line.lineOrigin.y + point.y));
        CGContextAddLineToPoint(context, line.lineOrigin.x + point.x + line.lineWidth,(line.lineOrigin.y + point.y));
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextStrokePath(context);
    }];
    [textLayout.textHighlights enumerateObjectsUsingBlock:^(LWTextHighlight * _Nonnull highlight, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        for (NSValue* rectValue in highlight.positions) {
            if (isCancelld()) {
                break;
            }
            CGRect rect = [rectValue CGRectValue];
            CGRect adjustRect = CGRectOffset(rect, point.x, point.y);
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect
                                                                  cornerRadius:2.0f];
            [highlight.hightlightColor setFill];
            [beizerPath fill];
        }
    }];
}

- (void)_drawTextInContext:(CGContextRef)context
                textLayout:(LWTextLayout *)textLayout
                      size:(CGSize)size
                     point:(CGPoint)point
               isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, point.x, point.y);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    NSArray* lines = textLayout.linesArray;
    [lines enumerateObjectsUsingBlock:^(LWTextLine*  _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSetTextPosition(context, line.lineOrigin.x ,size.height - line.lineOrigin.y);
        CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
        for (NSUInteger j = 0; j < CFArrayGetCount(runs);j ++) {
            if (isCancelld()) {
                break;
            }
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            CTRunDraw(run, context, CFRangeMake(0, 0));
        }
    }];
    CGContextRestoreGState(context);
}

- (void)_drawAttachmentsIncontext:(CGContextRef)context
                        textLayou:(LWTextLayout *)textLayout
                             size:(CGSize)size
                            point:(CGPoint)point
                    containerView:(UIView *)containerView
                   containerLayer:(CALayer *)containerLayer
                      isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    for (NSUInteger i = 0; i < textLayout.attachments.count; i++) {
        if (isCancelld()) {
            break;
        }
        LWTextAttachment* attachment = textLayout.attachments[i];
        if (!attachment.content) {
            continue;
        }
        UIImage* image = nil;
        UIView* view = nil;
        CALayer* layer = nil;
        if ([attachment.content isKindOfClass:[UIImage class]]) {
            image = attachment.content;
        } else if ([attachment.content isKindOfClass:[UIView class]]) {
            view = attachment.content;
        } else if ([attachment.content isKindOfClass:[CALayer class]]) {
            layer = attachment.content;
        }
        if ((!image && !view && !layer) || (!image && !view && !layer) ||
            (image && !context) || (view && !containerView)
            || (layer && !containerLayer)) {
            continue;
        }
        CGSize asize = image ? image.size : view ? view.frame.size : layer.frame.size;
        CGRect rect = ((NSValue *)textLayout.attachmentRects[i]).CGRectValue;
        rect = UIEdgeInsetsInsetRect(rect,attachment.contentEdgeInsets);
        rect = LWCGRectFitWithContentMode(rect, asize, attachment.contentMode);
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x;
        rect.origin.y += point.y;
        if (image) {
            CGImageRef ref = image.CGImage;
            if (ref) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, 0,CGRectGetMaxY(rect) + CGRectGetMinY(rect));
                CGContextScaleCTM(context, 1, -1);
                CGContextDrawImage(context, rect, ref);
                CGContextRestoreGState(context);
            }
        } else if (view) {
            dispatch_main_sync_safe(^{
                view.frame = rect;
                [containerView addSubview:view];
                if ([view isKindOfClass:[UIImageView class]]) {
                    if (attachment.userInfo) {
                        if (attachment.userInfo[@"URL"]) {
                            [view.layer sd_setImageWithURL:attachment.userInfo[@"URL"]];
                        }
                    }
                }
            });
        } else if (layer) {
            dispatch_main_sync_safe(^{
                layer.frame = rect;
                [containerLayer addSublayer:layer];
            });
        }
    }
}

- (void)removeAttachmentFromSuperViewOrLayer {
    for (LWTextAttachment* attachment in self.attachments) {
        if ([attachment.content isKindOfClass:[UIView class]]) {
            dispatch_main_sync_safe(^{
                UIView* view = attachment.content;
                [view removeFromSuperview];
            });
        } else if ([attachment.content isKindOfClass:[CALayer class]]) {
            dispatch_main_sync_safe(^{
                CALayer* layer = attachment.content;
                [layer removeFromSuperlayer];
            });
        }
    }
}

#pragma mark - Private
/**
 *  获取LWTextHightlight
 *
 */
+ (NSArray<NSValue *> *)_highlightPositionsWithCtFrame:(CTFrameRef)ctFrame
                                                 range:(NSRange)selectRange {
    CGPathRef path = CTFrameGetPath(ctFrame);
    CGRect boundsRect = CGPathGetBoundingBox(path);
    NSMutableArray* positions = [[NSMutableArray alloc] init];
    NSInteger selectionStartPosition = selectRange.location;
    NSInteger selectionEndPosition = NSMaxRange(selectRange);
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    if (!lines) {
        return nil;
    }
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origins[count];
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0,0), origins);
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange range = CTLineGetStringRange(line);
        //*** 在同一行 ***//
        if ([self _isPosition:selectionStartPosition inRange:range] && [self _isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, offset2 - offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
            break;
        }
        //*** 不在在同一行 ***//
        if ([self _isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset, linePoint.y - descent, width - offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
        }
        else if (selectionStartPosition < range.location && selectionEndPosition >= range.location + range.length) {
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, width, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
        }
        else if (selectionStartPosition < range.location && [self _isPosition:selectionEndPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x, linePoint.y - descent, offset, ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
        }
    }
    return positions;
}

+ (BOOL)_isPosition:(NSInteger)position inRange:(CFRange)range {
    return (position >= range.location && position < range.location + range.length);
}

static CGRect LWCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode) {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill: {
            if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                size.width < 0.01 || size.height < 0.01) {
                rect.origin = center;
                rect.size = CGSizeZero;
            } else {
                CGFloat scale;
                if (mode == UIViewContentModeScaleAspectFit) {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.height / size.height;
                    } else {
                        scale = rect.size.width / size.width;
                    }
                } else {
                    if (size.width / size.height < rect.size.width / rect.size.height) {
                        scale = rect.size.width / size.width;
                    } else {
                        scale = rect.size.height / size.height;
                    }
                }
                size.width *= scale;
                size.height *= scale;
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
        } break;
        case UIViewContentModeCenter: {
            rect.size = size;
            rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
        } break;
        case UIViewContentModeTop: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeBottom: {
            rect.origin.x = center.x - size.width * 0.5;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeLeft: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.size = size;
        } break;
        case UIViewContentModeRight: {
            rect.origin.y = center.y - size.height * 0.5;
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeTopLeft: {
            rect.size = size;
        } break;
        case UIViewContentModeTopRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.size = size;
        } break;
        case UIViewContentModeBottomLeft: {
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeBottomRight: {
            rect.origin.x += rect.size.width - size.width;
            rect.origin.y += rect.size.height - size.height;
            rect.size = size;
        } break;
        case UIViewContentModeScaleToFill:
        case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()


@end
