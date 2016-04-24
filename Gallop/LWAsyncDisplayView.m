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
#import "NSObject+SwizzleMethod.h"


typedef void(^foundLinkCompleteBlock)(LWTextStorage* foundTextStorage,id linkAttributes);

@interface LWAsyncDisplayView ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) NSMutableArray* imageContainers;
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
{
    NSArray* _textStorages;
    NSArray* _imageStorages;
    LWTextHightlight* _hightlight;
    BOOL _showingHighlight;
    BOOL _needUpdateTextStorages;
    BOOL _needUpdatedImageStorages;
}

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
    _showingHighlight = NO;
}

#pragma mark - Layout & Display

- (void)setLayout:(LWLayout *)layout {
    self.setedImageContents = YES;
    self.displayed = YES;
    _needUpdateTextStorages = NO;
    _needUpdatedImageStorages = NO;
    [self _clenLayoutWithLayout:layout];
    _layout = layout;
    [self _updateLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)_clenLayoutWithLayout:(LWLayout *)newLayout {
    for (LWTextStorage* textStorage in _textStorages) {
        [textStorage removeAttachFromViewAndLayer];
    }
    LWLayout* layout = _layout;
    _layout = nil;
    
    NSArray* textStroages = _textStorages;
    _textStorages = nil;
    _needUpdateTextStorages = YES;
    
    LWTextHightlight* hightlight = _hightlight;
    _hightlight = nil;
    
    NSArray* imageStorages = _imageStorages;
    _imageStorages = nil;
    _needUpdatedImageStorages = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [textStroages count];
        [hightlight class];
        [layout class];
        [imageStorages count];
    });
}


- (void)_updateLayout {
    if (_needUpdatedImageStorages) {
        [self _cleanImageContainers];
        _imageStorages = self.layout.container.imageStorages;
        self.setedImageContents = NO;
    }
    if (_needUpdateTextStorages) {
        _textStorages = self.layout.container.textStorages;
        self.displayed = NO;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (_needUpdatedImageStorages) {
            if (self.autoReuseImageContainer == YES) {
                [self _autoReuseImageContainers];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (_needUpdatedImageStorages) {
                if (self.autoReuseImageContainer == YES) {
                    [self _autoSetImageStorages];
                } else {
                    [self _setImageStorages];
                }
            }
            if (_needUpdateTextStorages) {
                [self _setNeedDisplay];
            }
        });
    });
}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = frame.size;
    if (!CGSizeEqualToSize(oldSize, newSize) &&
        !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setFrame:frame];
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
        for (NSInteger i = 0 ; i < _imageStorages.count; i ++) {
            LWImageStorage* imageStorage = _imageStorages[i];
            LWImageContainer* container = self.imageContainers[i];
            if (imageStorage.type == LWImageStorageWebImage) {
                [container delayLayoutImageStorage:imageStorage];
                [container setContentWithImageStorage:imageStorage];
            }
        }
        self.setedImageContents = YES;
    }
}

- (void)_cleanImageContainers {
    for (NSInteger i = 0; i < self.imageContainers.count; i ++) {
        LWImageContainer* container = self.imageContainers[i];
        [container cleanup];
    }
}

- (void)_setImageStorages {
    for (NSInteger i = 0; i < _imageStorages.count; i ++) {
        LWImageStorage* imageStorage = _imageStorages[i];
        if (self.imageContainers.count > i) {
            LWImageContainer* container = self.imageContainers[i];
            if (imageStorage.type == LWImageStorageWebImage) {
                [container delayLayoutImageStorage:imageStorage];
                [container setContentWithImageStorage:imageStorage];
            }
        }
    }
    self.setedImageContents = YES;
}

#pragma mark - Display
- (void)_setNeedDisplay {
    if (!self.displayed) {
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

- (void)setNeedRedDraw {
    [self.layer setNeedsDisplay];
}

#pragma mark - RestImageContainers
- (void)_autoReuseImageContainers {
    if (self.isNeedRestImageContainers) {
        NSInteger delta = self.imageContainers.count - _imageStorages.count;
        if (delta < 0) {
            for (NSInteger i = 0; i < _imageStorages.count; i ++) {
                if (i < ABS(delta)) {
                    LWImageContainer* container = [LWImageContainer layer];
                    [self.layer addSublayer:container];
                    [self.imageContainers addObject:container];
                }
            }
        } else if (delta > 0 ) {
            for (NSInteger i = 0; i < self.imageContainers.count; i ++ ) {
                if (i >= _imageStorages.count) {
                    LWImageContainer* container = self.imageContainers[i];
                    [container cleanup];
                }
            }
        }
    }
}

- (BOOL)isNeedRestImageContainers {
    if (self.imageContainers.count == _imageStorages.count) {
        return NO;
    }
    return YES;
}

#pragma mark - Setter & Getter

- (NSMutableArray *)imageContainers {
    if (_imageContainers) {
        return _imageContainers;
    }
    _imageContainers = [[NSMutableArray alloc] init];
    return _imageContainers;
}

#pragma mark - LWAsyncDisplayLayerDelegate
- (void)displayDidCancled {
    return;
}

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    for (LWImageStorage* imageStorage in _imageStorages) {
        if (imageStorage.type == LWImageStorageLocalImage) {
            [imageStorage.image drawInRect:imageStorage.frame];
        }
    }
    if (_showingHighlight && _hightlight) {
        for (NSString* rectString in _hightlight.positions) {
            CGRect rect = CGRectFromString(rectString);
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.0f];
            [_hightlight.hightlightColor setFill];
            [beizerPath fill];
        }
    }
    for (LWTextStorage* textStorage in _textStorages) {
        [textStorage drawInContext:context layer:layer];
    }
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:)] &&
        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
        [self.delegate extraAsyncDisplayIncontext:context size:size];
    }
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL)isFinished {
    return;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BOOL found = NO;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (LWTextStorage* textStorage in _textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            CTFrameRef textFrame = textStorage.CTFrame;
            if (textFrame == NULL) {
                continue;
            }
            LWTextHightlight* hightlight = [self _isNeedShowHighlight:textStorage touchPoint:touchPoint];
            if (hightlight) {
                [self _showHighlight:hightlight];
                found = YES;
            }
        }
    }
    if (!found) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BOOL found = NO;
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (LWTextStorage* textStorage in _textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            CTFrameRef textFrame = textStorage.CTFrame;
            if (textFrame == NULL) {
                continue;
            }
            LWTextHightlight* hightlight = [self _isNeedShowHighlight:textStorage touchPoint:touchPoint];
            if (hightlight) {
                [self _showHighlight:hightlight];
                found = YES;
            } else {
                [self _hideHightlight];
            }
        }
    }
    if (!found) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __block BOOL found = NO;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (LWImageStorage* imageStorage in _imageStorages) {
        if (imageStorage == nil) {
            continue;
        }
        if (CGRectContainsPoint(imageStorage.frame, touchPoint)) {
            if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedImageStorage:touch:)]) {
                [self.delegate lwAsyncDisplayView:self didCilickedImageStorage:imageStorage touch:touch];
            }
        }
    }
    for (LWTextStorage* textStorage in _textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            CTFrameRef textFrame = textStorage.CTFrame;
            if (textFrame == NULL) {
                continue;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                found = [self _handleLinkTouchIfNeed:textStorage touchPoint:touchPoint];
                [self _removeHightlight];
            });
        }
    }
    if (!found) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}


- (LWTextHightlight *)_isNeedShowHighlight:(LWTextStorage *)textStorage touchPoint:(CGPoint)touchPoint {
    __block LWTextHightlight* highlight;
    [self _foundLinkWithTextStroage:textStorage touchPoint:touchPoint
                         completion:^(LWTextStorage *foundTextStorage, id linkAttributes) {
                             for (LWTextHightlight* foundHighlight in foundTextStorage.hightlights) {
                                 if ([foundHighlight.linkAttributes isEqual:linkAttributes]) {
                                     highlight = foundHighlight;
                                 }
                             }
                         }];
    return highlight;
}


- (BOOL)_handleLinkTouchIfNeed:(LWTextStorage *)textStorage touchPoint:(CGPoint)touchPoint {
    __block BOOL found = NO;
    __weak typeof(self) weakSelf = self;
    [self _foundLinkWithTextStroage:textStorage touchPoint:touchPoint
                         completion:^(LWTextStorage *foundTextStorage, id linkAttributes) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             if ([strongSelf.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedLinkWithfData:)] &&
                                 [strongSelf.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                                 [strongSelf.delegate lwAsyncDisplayView:strongSelf didCilickedLinkWithfData:linkAttributes];
                                 found = YES;
                             }
                         }];
    return found;
}

- (void)_foundLinkWithTextStroage:(LWTextStorage *)textStorage
                       touchPoint:(CGPoint) touchPoint
                       completion:(foundLinkCompleteBlock)completion {
    CTFrameRef textFrame = textStorage.CTFrame;
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
                        completion(textStorage,[runAttribues objectForKey:kLWTextLinkAttributedName]);
                        break;
                    }
                }
            }
        }
    }
}

- (void)_showHighlight:(LWTextHightlight *)highlight {
    _showingHighlight = YES;
    _hightlight = highlight;
    [self setNeedRedDraw];
}

- (void)_hideHightlight {
    if (!_showingHighlight) {
        return;
    }
    _showingHighlight = NO;
    [self setNeedRedDraw];
}

- (void)_removeHightlight {
    [self _hideHightlight];
    _hightlight = nil;
}

- (CGRect)_getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

@end
