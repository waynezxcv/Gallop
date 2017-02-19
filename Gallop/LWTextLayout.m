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
#import "CALayer+WebCache.h"
#import <objc/runtime.h>
#import "GallopUtils.h"
#import "GallopDefine.h"
#import "NSMutableAttributedString+Gallop.h"
#import "LWCGRectTransform.h"
#import "CALayer+LWTransaction.h"
#import "CALayer+WebCache.h"






static inline CGSize _getSuggetSizeAndRange(CTFramesetterRef framesetter,
                                            NSAttributedString* attributedString,
                                            CGSize size,
                                            NSUInteger numberOfLines,
                                            CFRange* rangeToSize);

@interface LWTextLayout ()

@property (nonatomic,strong) LWTextContainer* container;
@property (nonatomic,strong) NSAttributedString* text;
@property (nonatomic,assign) CGRect cgPathBox;
@property (nonatomic,assign) CGPathRef cgPath;
@property (nonatomic,assign) CGPathRef suggestPathRef;
@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic,assign) CTFramesetterRef ctFrameSetter;
@property (nonatomic,assign) CGSize suggestSize;
@property (nonatomic,strong) NSArray<LWTextLine *>* linesArray;
@property (nonatomic,assign) CGRect textBoundingRect;
@property (nonatomic,assign) CGSize textBoundingSize;
@property (nonatomic,strong) NSArray<LWTextAttachment *>* attachments;
@property (nonatomic,strong) NSArray<NSValue *>* attachmentRanges;
@property (nonatomic,strong) NSArray<NSValue *>* attachmentRects;
@property (nonatomic,strong) NSSet<id>* attachmentContentsSet;
@property (nonatomic,strong) NSArray<LWTextHighlight *>* textHighlights;
@property (nonatomic,strong) NSArray<LWTextBackgroundColor *>* backgroundColors;
@property (nonatomic,strong) NSArray<LWTextBoundingStroke *>* boudingStrokes;
@property (nonatomic,assign) NSInteger numberOfLines;
@property (nonatomic,assign) BOOL needTruncation;

@end



@implementation LWTextLayout

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.container forKey:@"container"];
    [aCoder encodeObject:self.text forKey:@"text"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    LWTextContainer* container = [aDecoder decodeObjectForKey:@"container"];
    NSAttributedString* text = [aDecoder decodeObjectForKey:@"text"];
    LWTextLayout* one = [LWTextLayout lw_layoutWithContainer:container
                                                        text:text];
    return one;
}

#pragma mark - Init

+ (LWTextLayout *)lw_layoutWithContainer:(LWTextContainer *)container
                                    text:(NSAttributedString *)text {
    
    if (!text || !container) {
        return nil;
    }
    
    
    NSMutableAttributedString* mutableAtrributedText = text.mutableCopy;
    NSInteger maxNumberOfLines = container.maxNumberOfLines;
    CGPathRef containerPath = container.path.CGPath;
    CGRect containerBoudingBox = CGPathGetPathBoundingBox(containerPath);
    CTFramesetterRef ctFrameSetter = CTFramesetterCreateWithAttributedString((CFTypeRef)mutableAtrributedText);
    CFRange cfRange = CFRangeMake(0, (CFIndex)[mutableAtrributedText length]);
    NSInteger originLength = cfRange.length;
    CGSize suggestSize = _getSuggetSizeAndRange(ctFrameSetter,
                                                mutableAtrributedText,
                                                containerBoudingBox.size,
                                                maxNumberOfLines,
                                                &cfRange);
    NSInteger realLength = cfRange.length;
    BOOL needTruncation = NO;
    if (originLength != realLength) {
        needTruncation  = YES;
    }
    CGMutablePathRef suggetPath = CGPathCreateMutable();
    
    CGRect suggestRect = {
        containerBoudingBox.origin,{
            containerBoudingBox.size.width,
            suggestSize.height
        }
    };
    
    if (containerBoudingBox.size.height != CGFLOAT_MAX) {
        switch (container.vericalAlignment) {
            case LWTextVericalAlignmentTop:
                break;
            case LWTextVericalAlignmentCenter:
                suggestRect = CGRectMake(suggestRect.origin.x,
                                         suggestRect.origin.y + (containerBoudingBox.size.height - suggestRect.size.height)/2.0f,
                                         suggestRect.size.width,
                                         suggestRect.size.height);
                break;
            case LWTextVericalAlignmentBottom:
                suggestRect = CGRectMake(suggestRect.origin.x,
                                         suggestRect.origin.y + containerBoudingBox.size.height - suggestRect.size.height,
                                         suggestRect.size.width,
                                         suggestRect.size.height);
                break;
        }
    }
    
    CGPathAddRect(suggetPath, NULL,suggestRect);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFrameSetter,
                                                  cfRange,
                                                  suggetPath,
                                                  NULL);
    
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
    
    BOOL isNeedStroke = NO;
    CGRect textBoundingRect = CGRectZero;
    NSUInteger lineCurrentIndex = 0;
    NSMutableArray* highlights = [[NSMutableArray alloc] init];
    NSMutableArray* backgroundColors = [[NSMutableArray alloc] init];
    NSMutableArray* boundingStrokes = [[NSMutableArray alloc] init];
    
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
            
            {
                LWTextHighlight* highlight = [attributes objectForKey:LWTextLinkAttributedName];
                if (highlight) {
                    if (highlight.type == LWTextHighLightTypeWholeText) {
                        NSArray* highlightPositions =
                        @[[NSValue valueWithCGRect:suggestRect]];
                        highlight.positions = highlightPositions;
                    } else {
                        NSArray* highlightPositions = [self _highlightPositionsWithCtFrame:ctFrame
                                                                                     range:highlight.range];
                        highlight.positions = highlightPositions;
                    }
                    bool isContain = NO;
                    for (LWTextHighlight* one in highlights) {
                        if ([one isEqual:highlight]) {
                            isContain = YES;
                        }
                    }
                    if (!isContain) {
                        [highlights addObject:highlight];
                    }
                }
            }
            
            {
                LWTextHighlight* highlight = [attributes objectForKey:LWTextLongPressAttributedName];
                if (highlight) {
                    if (highlight.type == LWTextHighLightTypeLongPress) {
                        NSArray* highlightPositions =
                        @[[NSValue valueWithCGRect:suggestRect]];
                        highlight.positions = highlightPositions;
                    }
                    bool isContain = NO;
                    for (LWTextHighlight* one in highlights) {
                        if ([one isEqual:highlight]) {
                            isContain = YES;
                        }
                    }
                    if (!isContain) {
                        [highlights addObject:highlight];
                    }
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
            
            LWTextBoundingStroke* boundingStroke = [attributes objectForKey:LWTextBoundingStrokeAttributedName];
            if (boundingStroke) {
                NSArray* boundingStrokePositions = [self _highlightPositionsWithCtFrame:ctFrame range:color.range];
                boundingStroke.positions = boundingStrokePositions;
                if (![boundingStrokes containsObject:boundingStroke]) {
                    [boundingStrokes addObject:boundingStroke];
                }
            }
            LWTextStroke* textStroke = [attributes objectForKey:LWTextStrokeAttributedName];
            if (textStroke) {
                isNeedStroke = YES;
            }
        }
        
        CGPoint ctLineOrigin = lineOrigins[i];
        CGPoint position;
        position.x = suggestRect.origin.x + ctLineOrigin.x;
        position.y = suggestRect.size.height + suggestRect.origin.y - ctLineOrigin.y;
        
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
    
    NSMutableArray* attachments = [[NSMutableArray alloc] init];
    NSMutableArray* attachmentRanges = [[NSMutableArray alloc] init];
    NSMutableArray* attachmentRects = [[NSMutableArray alloc] init];
    NSMutableSet* attachmentContentsSet = [[NSMutableSet alloc] init];
    
    for (NSUInteger i = 0; i < lines.count; i ++) {
        LWTextLine* line = lines[i];
        if (line.attachments.count > 0) {
            [attachments addObjectsFromArray:line.attachments];
            [attachmentRanges addObjectsFromArray:line.attachmentRanges];
            [attachmentRects addObjectsFromArray:line.attachmentRects];
            for (LWTextAttachment* attachment in line.attachments) {
                if (attachment.content) {
                    [attachmentContentsSet addObject:attachment.content];
                }
            }
        }
    }
    
    suggestRect = CGRectMake(suggestRect.origin.x - container.edgeInsets.left,
                             suggestRect.origin.y - container.edgeInsets.top,
                             suggestRect.size.width + container.edgeInsets.left + container.edgeInsets.right,
                             suggestRect.size.height + container.edgeInsets.top + container.edgeInsets.bottom);
    
    LWTextLayout* layout = [[LWTextLayout alloc] init];
    layout.needStrokeDraw = isNeedStroke;
    layout.container = container;
    layout.text = mutableAtrributedText;
    layout.suggestPathRef = suggetPath;
    layout.cgPath = [UIBezierPath bezierPathWithRect:suggestRect].CGPath;
    layout.ctFrameSetter = ctFrameSetter;
    layout.ctFrame = ctFrame;
    layout.linesArray = lines;
    layout.suggestSize = suggestSize;
    layout.cgPathBox = containerBoudingBox;
    layout.textBoundingRect = textBoundingRect;
    layout.textBoundingSize = textBoundingRect.size;
    layout.textHighlights = [highlights copy];
    layout.backgroundColors = [backgroundColors copy];
    layout.boudingStrokes = [boundingStrokes copy];
    layout.attachments = [attachments copy];
    layout.attachmentRanges = [attachmentRanges copy];
    layout.attachmentRects = [attachmentRects copy];
    layout.attachmentContentsSet = [attachmentContentsSet copy];
    layout.numberOfLines = layout.linesArray.count;
    layout.needTruncation = needTruncation;
    if (layout.backgroundColors.count > 0) layout.needTextBackgroundColorDraw = YES;
    if (layout.boudingStrokes.count > 0) layout.needBoudingStrokeDraw = YES;
    if (layout.attachments.count > 0) layout.needAttachmentDraw = YES;
    if (lineOrigins){
        free(lineOrigins);
    }
    
    return layout;
}

- (id)init {
    self = [super init];
    if (self) {
        self.needDebugDraw = NO;
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
    if (self.suggestPathRef) {
        CFRelease(self.suggestPathRef);
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
    
    if (self.isNeedBoudingStrokeDraw) {
        [self _drawTextBoudingStrokeInContext:context
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
                                     size:(CGSize)size
                                    point:(CGPoint)point
                              isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld  {
    
    [textLayout.backgroundColors enumerateObjectsUsingBlock:^(LWTextBackgroundColor *
                                                              _Nonnull background,
                                                              NSUInteger idx,
                                                              BOOL * _Nonnull stop) {
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

- (void)_drawTextBoudingStrokeInContext:(CGContextRef)context
                             textLayout:(LWTextLayout *)textLayout
                                   size:(CGSize)size
                                  point:(CGPoint)point
                            isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld  {
    
    [textLayout.boudingStrokes enumerateObjectsUsingBlock:^(LWTextBoundingStroke * _Nonnull boundingStroke,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        for (NSValue* value in boundingStroke.positions) {
            if (isCancelld()) {
                break;
            }
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(point.x + rect.origin.x, point.y + rect.origin.y, rect.size.width, rect.size.height);
            
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
            [boundingStroke.strokeColor setStroke];
            [beizerPath setLineWidth:1.0f];
            [beizerPath stroke];
        }
    }];
}

- (void)_drawDebugInContext:(CGContextRef) context
                 textLayout:(LWTextLayout *)textLayout
                       size:(CGSize)size
                      point:(CGPoint)point
                isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld  {
    
    CGRect r = CGRectOffset(textLayout.cgPathBox, point.x, point.y);
    CGContextAddRect(context,CGRectMake(r.origin.x - 0.2f,
                                        r.origin.y - 1.0f,
                                        r.size.width + 5.0f,
                                        r.size.height + 2.0f));
    CGContextSetLineWidth(context, 0.2f);
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextStrokePath(context);
    
    
    CGContextAddRect(context, CGRectOffset(textLayout.textBoundingRect,point.x,point.y));
    CGContextSetFillColorWithColor(context, RGB(44.0f, 189.0f, 230.0f, 0.1f).CGColor);
    CGContextFillPath(context);
    
    [textLayout.linesArray enumerateObjectsUsingBlock:^(LWTextLine * _Nonnull line,
                                                        NSUInteger idx,
                                                        BOOL * _Nonnull stop) {
        if (isCancelld()) {
            return ;
        }
        CGContextMoveToPoint(context,
                             line.lineOrigin.x + point.x,
                             (line.lineOrigin.y + point.y + 1.0f));
        
        CGContextAddLineToPoint(context,
                                line.lineOrigin.x + point.x + line.lineWidth,
                                (line.lineOrigin.y + point.y + 1.0f));
        CGContextSetLineWidth(context, 1.0f);//base line
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextStrokePath(context);
        
        for (LWTextGlyph* glyph in line.glyphs) {
            CGContextAddRect(context, CGRectMake(point.x + line.lineOrigin.x + glyph.position.x,
                                                 line.lineOrigin.y + point.y  - glyph.ascent,
                                                 glyph.width,
                                                 glyph.ascent + glyph.descent));
            CGContextSetLineWidth(context, 0.2f);
            CGContextSetStrokeColorWithColor(context,
                                             [UIColor orangeColor].CGColor);
            CGContextStrokePath(context);
        }
    }];
    
    
    [textLayout.textHighlights enumerateObjectsUsingBlock:^(LWTextHighlight * _Nonnull highlight,
                                                            NSUInteger idx,
                                                            BOOL * _Nonnull stop) {
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
            [RGB(133.0f, 116.0f, 89.0f, 0.25f) setFill];
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
            if (textLayout.isNeedStrokeDraw) {
                NSDictionary* attributes = (id)CTRunGetAttributes(run);
                LWTextStroke* textStroke = [attributes objectForKey:LWTextStrokeAttributedName];
                if (textStroke) {
                    [self _drawGlyphsInContext:context run:run];
                }
                else {
                    CTRunDraw(run, context, CFRangeMake(0, 0));
                }
            } else {
                CTRunDraw(run, context, CFRangeMake(0, 0));
            }
        }
    }];
    CGContextRestoreGState(context);
}

- (void)_drawGlyphsInContext:(CGContextRef)context
                         run:(CTRunRef)run {
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    LWTextStroke* textStroke = CFDictionaryGetValue(runAttrs, LWTextStrokeAttributedName);
    if (!textStroke) {
        return;
    }
    
    CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
    if (!runFont){
        return;
    }
    
    NSUInteger glyphCount = CTRunGetGlyphCount(run);
    if (glyphCount <= 0) {
        return;
    }
    CGGlyph glyphs[glyphCount];
    CTRunGetGlyphs(run, CFRangeMake(0, 0),glyphs);
    CGPoint glyphPositions[glyphCount];
    CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
    
    CGColorRef strokeColor = textStroke.strokeColor.CGColor;
    CGFloat strokeWidth = textStroke.strokeWidth;
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGContextSetStrokeColorWithColor(context, strokeColor);
    CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth * 0.01));
    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(runFont));
    CGContextShowGlyphsAtPositions(context, glyphs, glyphPositions, glyphCount);
    CGFontRelease(cgFont);
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
        rect =  [LWCGRectTransform lw_CGRectFitWithContentMode:attachment.contentMode
                                                          rect:rect
                                                          size:asize];
        rect = CGRectStandardize(rect);
        rect.origin.x += point.x;
        rect.origin.y += point.y;
        
        //图片类型的附件直接绘制到LWAsyncImageView上
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
            view.frame = rect;
            [containerView addSubview:view];
            
            dispatch_main_async_safe(^{
                
                layer.frame = rect;
                [containerLayer addSublayer:layer];
                
                if (attachment.userInfo && attachment.userInfo[@"URL"]) {
                    
                    [view.layer lw_setImageWithURL:attachment.userInfo[@"URL"]
                                  placeholderImage:nil
                                      cornerRadius:0
                             cornerBackgroundColor:nil
                                       borderColor:nil
                                       borderWidth:0
                                              size:CGSizeZero
                                       contentMode:attachment.contentMode
                                            isBlur:NO
                                           options:0
                                          progress:nil
                                         completed:nil];
                }
            });
            
        } else if (layer) {
            
            dispatch_main_async_safe(^{
                layer.frame = rect;
                [containerLayer addSublayer:layer];
                
                if (attachment.userInfo && attachment.userInfo[@"URL"]) {
                    [layer lw_setImageWithURL:attachment.userInfo[@"URL"]
                             placeholderImage:nil
                                 cornerRadius:0
                        cornerBackgroundColor:nil
                                  borderColor:nil
                                  borderWidth:0
                                         size:CGSizeZero
                                  contentMode:attachment.contentMode
                                       isBlur:NO
                                      options:0
                                     progress:nil
                                    completed:nil];
                }
            });
        }
    }
}


- (void)removeAttachmentFromSuperViewOrLayer {
    for (LWTextAttachment* attachment in self.attachments) {
        @autoreleasepool {
            if ([attachment.content isKindOfClass:[UIView class]]) {
                dispatch_main_async_safe(^{
                    UIView* view = attachment.content;
                    [view removeFromSuperview];
                });
            } else if ([attachment.content isKindOfClass:[CALayer class]]) {
                dispatch_main_async_safe(^{
                    CALayer* layer = attachment.content;
                    [layer removeFromSuperlayer];
                });
            }
        }
    }
}

#pragma mark - Private

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
        
        if ([self _isPosition:selectionStartPosition inRange:range] &&
            [self _isPosition:selectionEndPosition inRange:range]) {
            
            CGFloat ascent, descent, leading, offset, offset2;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            offset2 = CTLineGetOffsetForStringIndex(line, selectionEndPosition, NULL);
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset,
                                         linePoint.y - descent,
                                         offset2 - offset,
                                         ascent + descent);
            
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
            break;
        }
        
        if ([self _isPosition:selectionStartPosition inRange:range]) {
            CGFloat ascent, descent, leading, width, offset;
            offset = CTLineGetOffsetForStringIndex(line, selectionStartPosition, NULL);
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x + offset,
                                         linePoint.y - descent,
                                         width - offset,
                                         ascent + descent);
            
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
            
        } else if (selectionStartPosition < range.location &&
                   selectionEndPosition >= range.location + range.length) {
            
            CGFloat ascent, descent, leading, width;
            width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGRect lineRect = CGRectMake(linePoint.x,
                                         linePoint.y - descent,
                                         width,
                                         ascent + descent);
            CGRect rect = CGRectApplyAffineTransform(lineRect, transform);
            CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                           rect.origin.y + boundsRect.origin.y,
                                           rect.size.width,
                                           rect.size.height);
            [positions addObject:[NSValue valueWithCGRect:adjustRect]];
            
        } else if (selectionStartPosition < range.location &&
                   [self _isPosition:selectionEndPosition inRange:range]) {
            
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


@end


static inline CGSize _getSuggetSizeAndRange(CTFramesetterRef framesetter,
                                            NSAttributedString* attributedString,
                                            CGSize size,
                                            NSUInteger numberOfLines,
                                            CFRange* rangeToSize) {
    
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    if (numberOfLines > 0) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            *rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                        *rangeToSize,
                                                                        NULL,
                                                                        constraints,
                                                                        NULL);
    return CGSizeMake(ceil(suggestedSize.width), ceil(suggestedSize.height));
}

