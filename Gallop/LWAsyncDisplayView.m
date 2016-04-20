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

@property (nonatomic,assign) BOOL setedFrame;
@property (nonatomic,assign,getter=isDisplayed) BOOL displayed;
@property (nonatomic,assign,getter=isSetedImageContents) BOOL setedImageContents;

/**
 *  是否自动管理ImageContainer。默认为YES。若为NO，则需指定一个 maxImageStorageCount
 *  如需设置maxImageStorageCount,请使用“- (id)initWithmaxImageStorageCount:(NSInteger)count”，
 *  “- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)count”
 *  方法来初始化
 */
@property (nonatomic,assign) BOOL autoReuseImageContainer;

/**
 *  最大的ImageContainer数量，默认为0
 *  如需设置maxImageStorageCount,请使用“- (id)initWithmaxImageStorageCount:(NSInteger)count”，
 *  “- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)count”
 *  方法来初始化
 */
@property (nonatomic,assign) NSInteger maxImageStorageCount;

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

- (id)initWithmaxImageStorageCount:(NSInteger)count {
    self = [super init];
    if (self) {
        [self setup];
        self.autoReuseImageContainer = NO;
        self.maxImageStorageCount = count;
        for (NSInteger i = 0; i < self.maxImageStorageCount; i ++) {
            LWImageContainer* container = [LWImageContainer layer];
            [self.layer addSublayer:container];
            [self.imageContainers addObject:container];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.autoReuseImageContainer = NO;
        self.maxImageStorageCount = count;
        for (NSInteger i = 0; i < self.maxImageStorageCount; i ++) {
            LWImageContainer* container = [LWImageContainer layer];
            [self.layer addSublayer:container];
            [self.imageContainers addObject:container];
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
        self.autoReuseImageContainer = YES;
        self.maxImageStorageCount = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.autoReuseImageContainer = YES;
        self.maxImageStorageCount = 0;
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
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        [textStorage removeAttachFromViewAndLayer];
    }
    _layout = layout;
    self.setedFrame = NO;
    self.displayed = NO;
    self.setedImageContents = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.autoReuseImageContainer == YES) {
            [self _autoReuseImageContainers];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (self.autoReuseImageContainer == YES) {
                [self _autoSetImageStorages];
            } else {
                [self _setImageStorages];
            }
            [self _setNeedDisplay];
        });
    });
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = frame.size;
    if (!CGSizeEqualToSize(oldSize, newSize) &&
        !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setFrame:frame];
        self.setedFrame = YES;
        [self _setNeedDisplay];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize) &&
        !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setBounds:bounds];
        [self _setNeedDisplay];
    }
}

- (void)_autoSetImageStorages {
    if (!self.setedImageContents) {
        for (NSInteger i = 0 ; i < self.layout.imageStorages.count; i ++) {
            LWImageStorage* imageStorage = self.layout.imageStorages[i];
            LWImageContainer* container = self.imageContainers[i];
            [container delayLayoutImageStorage:imageStorage];
            [container setContentWithImageStorage:imageStorage];
        }
        self.setedImageContents = YES;
    }
}

- (void)_setImageStorages {
    for (NSInteger i = 0; i < self.imageContainers.count; i ++) {
        LWImageContainer* container = self.imageContainers[i];
        [container cleanup];
    }
    for (NSInteger i = 0; i < self.layout.imageStorages.count; i ++) {
        LWImageStorage* imageStorage = self.layout.imageStorages[i];
        LWImageContainer* container = self.imageContainers[i];
        [container delayLayoutImageStorage:imageStorage];
        [container setContentWithImageStorage:imageStorage];
    }
    self.setedImageContents = YES;
}

#pragma mark - Display
- (void)_setNeedDisplay {
    if (!self.displayed && self.setedFrame) {
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
    [(LWAsyncDisplayLayer *)self.layer asyncDisplaySize:self.bounds.size];
}

#pragma mark - RestImageContainers
- (void)_autoReuseImageContainers {
    if (self.isNeedRestImageContainers) {
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
}

- (BOOL)isNeedRestImageContainers {
    if (self.imageContainers.count == self.layout.imageStorages.count) {
        return NO;
    }
    return YES;
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
    self.displayed = NO;
}

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    if (self.displayed == NO) {
        return YES;
    }
    return NO;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:)] &&
        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
        [self.delegate extraAsyncDisplayIncontext:context size:size];
    }
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        [textStorage drawInContext:context layer:layer];
    }
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL)isFinished {
    self.displayed = YES;
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
