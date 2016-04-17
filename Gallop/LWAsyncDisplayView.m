//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
////
//  LWLabel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "LWAsyncDisplayView.h"
#import "LWAsyncDisplayLayer.h"
#import "LWRunLoopTransactions.h"
#import "CALayer+WebCache.h"
#import "CALayer+GallopAddtions.h"
#import "LWImageContainer.h"
#import "NSObject+SwizzleMethod.h"


@interface LWAsyncDisplayView ()
<LWAsyncDisplayLayerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic,strong) NSMutableArray* imageContainers;

@property (nonatomic,assign,getter=isNeedResetImageContainers) BOOL needResetImageContainers;
@property (nonatomic,assign) BOOL needLayoutSubviews;
@property (nonatomic,assign) BOOL needDisplay;

@end


@implementation LWAsyncDisplayView

#pragma mark - Initialization
/**
 *  “default is [CALayer class].
 *  Used when creating the underlying layer for the view.”
 *
 */
+ (Class)layerClass {
    return [LWAsyncDisplayLayer class];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.opaque = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    ((LWAsyncDisplayLayer *)self.layer).asyncDisplayDelegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Layout & Display

- (void)setLayout:(LWLayout *)layout {
    if (_layout == layout) {
        return;
    }
    _layout = layout;
    [self _resetImageContainersIfNeed];
    [self _setNeedDisplay];
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = frame.size;
    if (!CGSizeEqualToSize(oldSize, newSize) && !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setFrame:frame];
        [self _setNeedlayoutSubViews];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize) && !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setBounds:bounds];
        [self _setNeedlayoutSubViews];
    }
}

- (void)_setNeedlayoutSubViews {
    self.needLayoutSubviews = YES;
    if (self.needLayoutSubviews && self.needResetImageContainers == NO) {
        [[LWRunLoopTransactions transactionsWithTarget:self
                                              selector:@selector(_layoutSubViews)
                                                object:nil] commit];
    }
}

- (void)_layoutSubViews {
    for (NSInteger i = 0 ; i < self.layout.imageStorages.count; i ++) {
        LWImageStorage* imageStorage = self.layout.imageStorages[i];
        LWImageContainer* container = self.imageContainers[i];
        [container layoutImageStorage:imageStorage];
    }
    self.needLayoutSubviews = NO;
}

- (void)_setNeedDisplay {
    self.needDisplay = YES;
    if (self.needDisplay && self.needLayoutSubviews == NO) {
        self.needDisplay = NO;
        [self _setupImageStorages];
        [self _commitDisplay];
    }
}

- (void)_commitDisplay {
    [[LWRunLoopTransactions transactionsWithTarget:self
                                          selector:@selector(_display)
                                            object:nil] commit];
}

- (void)_display {
    [(LWAsyncDisplayLayer *)self.layer cleanUp];
    [self.layer setNeedsDisplay];
}

- (void)_resetImageContainersIfNeed {
    if (self.imageContainers.count == self.layout.imageStorages.count) {
        self.needResetImageContainers = NO;
    } else {
        [self _setNeedRestImageContainers];
    }
}

- (void)_setNeedRestImageContainers {
    self.needResetImageContainers = YES;
    if (self.needResetImageContainers) {
        self.needResetImageContainers = NO;
        [self _resetImageContainers];
    }
}

- (void)_resetImageContainers {
    NSInteger delta = self.imageContainers.count - self.layout.imageStorages.count;
    if (delta < 0) {
        for (NSInteger i = 0; i < self.layout.imageStorages.count; i ++) {
            if (i < ABS(delta)) {
                LWImageContainer* container = [LWImageContainer layer];
                [self.layer addSublayer:container];
                [self.imageContainers addObject:container];
            }
        }
    } else if (delta > 0 ) {
        for (NSInteger i = 0; i < self.imageContainers.count; i ++ ) {
            if (i >= self.layout.imageStorages.count) {
                LWImageContainer* container = self.imageContainers[i];
                [container cleanup];
            }
        }
    }
}

- (void)_setupImageStorages {
    if (self.needResetImageContainers == NO) {
        for (NSInteger i = 0; i < self.layout.imageStorages.count; i ++) {
            LWImageStorage* imageStorage = self.layout.imageStorages[i];
            LWImageContainer* container = self.imageContainers[i];
            [container setContentWithImageStorage:imageStorage];
        }
    }
}

#pragma mark - Setter & Getter

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                 initWithTarget:self
                                 action:@selector(_didSingleTapThisView:)];
        _tapGestureRecognizer.delegate = self;
    }
    return _tapGestureRecognizer;
}

- (NSMutableArray *)imageContainers {
    if (_imageContainers) {
        return _imageContainers;
    }
    _imageContainers = [[NSMutableArray alloc] init];
    return _imageContainers;
}

#pragma mark - LWAsyncDisplayLayerDelegate

- (void)displayDidCancled {
    self.needDisplay = YES;
}

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:)] &&
        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
        [self.delegate extraAsyncDisplayIncontext:context size:size];
    }
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        [textStorage drawInContext:context];
    }
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL)isFinished {
    self.needDisplay = YES;
}

#pragma mark - SignleTapGesture

- (void)_didSingleTapThisView:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self];
    for (LWImageStorage* imageStorage in self.layout.imageStorages) {
        if (imageStorage == nil) {
            continue;
        }
        if (CGRectContainsPoint(imageStorage.frame, touchPoint)) {
            if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedImageStorage:tapGesture:)]) {
                [self.delegate lwAsyncDisplayView:self didCilickedImageStorage:imageStorage tapGesture:tapGestureRecognizer];
            }
        }
    }
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            CTFrameRef textFrame = textStorage.CTFrame;
            if (textFrame == NULL) {
                continue;
            }
            CFArrayRef lines = CTFrameGetLines(textFrame);
            CGPoint origins[CFArrayGetCount(lines)];
            CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
            CGPathRef path = CTFrameGetPath(textFrame);
            CGRect boundsRect = CGPathGetBoundingBox(path);
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformMakeTranslation(0, boundsRect.size.height);
            transform = CGAffineTransformScale(transform, 1.f, -1.f);
            for (int i= 0; i < CFArrayGetCount(lines); i++) {
                CGPoint linePoint = origins[i];
                CTLineRef line = CFArrayGetValueAtIndex(lines, i);
                CGRect flippedRect = [self _getLineBounds:line point:linePoint];
                CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);

                CGRect adjustRect = CGRectMake(rect.origin.x + boundsRect.origin.x,
                                               rect.origin.y + boundsRect.origin.y,
                                               rect.size.width,
                                               rect.size.height);

                if (CGRectContainsPoint(adjustRect, touchPoint)) {
                    CGPoint relativePoint = CGPointMake(touchPoint.x - CGRectGetMinX(adjustRect),
                                                        touchPoint.y - CGRectGetMinY(adjustRect));
                    CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
                    CTRunRef touchedRun;
                    NSArray* runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
                    for (NSInteger i = 0; i < runObjArray.count; i ++) {
                        CTRunRef runObj = (__bridge CTRunRef)[runObjArray objectAtIndex:i];
                        CFRange range = CTRunGetStringRange((CTRunRef)runObj);
                        if (NSLocationInRange(index, NSMakeRange(range.location, range.length))) {
                            touchedRun = runObj;
                            NSDictionary* runAttribues = (NSDictionary *)CTRunGetAttributes(touchedRun);
                            if ([runAttribues objectForKey:kLWTextLinkAttributedName]) {
                                if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedLinkWithfData:)] &&
                                    [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                                    [self.delegate lwAsyncDisplayView:self didCilickedLinkWithfData:[runAttribues objectForKey:kLWTextLinkAttributedName]];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (CGRect)_getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}


#pragma mark - UIGestrueRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
