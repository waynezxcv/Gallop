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

#import "LWAsyncDisplayView.h"
#import "LWAsyncDisplayLayer.h"
#import "GallopUtils.h"
#import "LWTransaction.h"
#import "LWTransactionGroup.h"
#import "CALayer+LWTransaction.h"


@interface LWAsyncDisplayView ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) NSMutableArray* reusePool;
@property (nonatomic,strong) NSMutableArray* imageContainers;

@end


@implementation LWAsyncDisplayView

{
    LWTextHighlight* _highlight;
    CGPoint _highlightAdjustPoint;
    BOOL _showingHighlight;
    CGPoint _longpressPoint;
    NSArray* _textStorages;
    NSArray* _imageStorages;
    NSTimer* _longpressTimer;
}


#pragma mark - LifeCycle

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
    self.layer.opaque = YES;
    self.layer.contentsScale = [GallopUtils contentsScale];
    _showingHighlight = NO;
    self.displaysAsynchronously = YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Private
- (void)_cleanAddToReusePool {
    for (NSInteger i = 0; i < self.imageContainers.count; i ++) {
        UIView* container = [self.imageContainers objectAtIndex:i];
        [container cleanup];
        [self.reusePool addObject:container];
    }
    [self.imageContainers removeAllObjects];
}

- (void)setImageStoragesResizeBlock:(void(^)(LWImageStorage* imageStorage, CGFloat delta))resizeBlock {
    for (NSInteger i = 0; i < _imageStorages.count; i ++) {
        @autoreleasepool {
            LWImageStorage* imageStorage = _imageStorages[i];
            if ([imageStorage.contents isKindOfClass:[UIImage class]] &&
                imageStorage.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {
                continue;
            }
            UIView* container = [self _dequeueReusableImageContainerWithIdentifier:imageStorage.identifier];
            if (!container) {
                container = [[UIView alloc] initWithFrame:CGRectZero];
                container.identifier = imageStorage.identifier;
                [self addSubview:container];
            }
            [self.imageContainers addObject:container];
            [container setContentWithImageStorage:imageStorage resizeBlock:resizeBlock];
        }
    }
}

- (UIView *)_dequeueReusableImageContainerWithIdentifier:(NSString *)identifier {
    for (UIView* container in self.reusePool) {
        if ([container.identifier isEqualToString:identifier]) {
            [self.reusePool removeObject:container];
            return container;
        }
    }
    return nil;
}


#pragma mark - Display

- (LWAsyncDisplayTransaction *)asyncDisplayTransaction {
    LWAsyncDisplayTransaction* transaction = [[LWAsyncDisplayTransaction alloc] init];
    transaction.willDisplayBlock = ^(CALayer *layer) {
        for (LWTextStorage* textStorage in _textStorages) {
            [textStorage.textLayout removeAttachmentFromSuperViewOrLayer];
        }
    };
    transaction.displayBlock = ^(CGContextRef context,
                                 CGSize size,
                                 LWAsyncDisplayIsCanclledBlock isCancelledBlock) {
        [self _drawStoragesInContext:context
                         inCancelled:isCancelledBlock];
    };
    transaction.didDisplayBlock = ^(CALayer *layer, BOOL finished) {
        if (!finished) {
            for (LWTextStorage* textStorage in _textStorages) {
                [textStorage.textLayout removeAttachmentFromSuperViewOrLayer];
            }
        }
    };
    return transaction;
}

- (void)_drawStoragesInContext:(CGContextRef)context inCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelledBlock {
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:isCancelled:)]) {
        if (isCancelledBlock()) {
            return;
        }
        [self.delegate extraAsyncDisplayIncontext:context size:self.bounds.size isCancelled:isCancelledBlock];
    }
    
    for (LWImageStorage* imageStorage in _imageStorages) {
        if (isCancelledBlock()) {
            return;
        }
        [imageStorage lw_drawInContext:context isCancelled:isCancelledBlock];
    }
    
    for (LWTextStorage* textStorage in _textStorages) {
        
        [textStorage.textLayout drawIncontext:context
                                         size:CGSizeZero
                                        point:textStorage.frame.origin
                                containerView:self
                               containerLayer:self.layer
                                  isCancelled:isCancelledBlock];
    }
    
    if (_showingHighlight && _highlight) {
        for (NSValue* rectValue in _highlight.positions) {
            if (isCancelledBlock()) {
                return;
            }
            
            CGRect rect = [rectValue CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x + _highlightAdjustPoint.x,
                                           rect.origin.y + _highlightAdjustPoint.y,
                                           rect.size.width,
                                           rect.size.height);
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect
                                                                  cornerRadius:2.0f];
            [_highlight.hightlightColor setFill];
            [beizerPath fill];
        }
    }
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _removeLongpressHighlight];
    BOOL found = NO;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for (LWTextStorage* textStorage in _textStorages) {
        if (!_highlight) {
            LWTextHighlight* hightlight =  [self _NeedShowHighlightWithIsLongpress:NO
                                                                       textStorage:textStorage
                                                                        touchPoint:touchPoint];
            if (hightlight) {
                [self _showHighlight:hightlight adjustPoint:textStorage.frame.origin];
                found = YES;
                break;
            }
        }
    }
    
    _longpressPoint = touchPoint;
    [self _startLongPressTimer];
    
    if (!found) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BOOL found = NO;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (LWTextStorage* textStorage in _textStorages) {
        LWTextHighlight* hightlight =  [self _NeedShowHighlightWithIsLongpress:NO
                                                                   textStorage:textStorage
                                                                    touchPoint:touchPoint];
        if (_highlight && hightlight == _highlight) {
            [self _startLongPressTimer];
            [self _showHighlight:hightlight adjustPoint:textStorage.frame.origin];
            found = YES;
        } else {
            [self _endLongPressTimer];
            [self _hideTapHighlight];
        }
        break;
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
        if (CGRectContainsPoint(imageStorage.frame, touchPoint)) {
            if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedImageStorage:touch:)]) {
                found = YES;
                [self.delegate lwAsyncDisplayView:self didCilickedImageStorage:imageStorage touch:touch];
                break;
            }
        }
    }
    
    for (LWTextStorage* textStorage in _textStorages) {
        LWTextHighlight* hightlight =  [self _NeedShowHighlightWithIsLongpress:NO
                                                                   textStorage:textStorage
                                                                    touchPoint:touchPoint];
        if (_highlight && hightlight == _highlight) {
            if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedTextStorage:linkdata:)]) {
                [self.delegate lwAsyncDisplayView:self didCilickedTextStorage:textStorage linkdata:_highlight.content];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(0.1f * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                               [self _removeTapHighlight];
                           });
            break;
        }
    }
    
    [self _endLongPressTimer];
    if (!found) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _removeTapHighlight];
    [self _removeLongpressHighlight];
    [super touchesCancelled:touches withEvent:event];
}

- (void)_startLongPressTimer {
    if (!_longpressTimer) {
        _longpressTimer = [NSTimer timerWithTimeInterval:0.5f
                                                  target:self
                                                selector:@selector(_longPressHandler:)
                                                userInfo:nil
                                                 repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_longpressTimer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)_endLongPressTimer {
    _longpressPoint = CGPointZero;
    if (_longpressTimer) {
        [_longpressTimer invalidate];
        _longpressTimer = nil;
    }
}

- (void)_longPressHandler:(NSTimer *)timer {
    if (CGPointEqualToPoint(_longpressPoint, CGPointZero)) {
        return;
    }
    for (LWTextStorage* textStorage in _textStorages) {
        LWTextHighlight* highlight = [self _NeedShowHighlightWithIsLongpress:YES
                                                                 textStorage:textStorage
                                                                  touchPoint:_longpressPoint];
        
        if (!highlight) {
            continue;
        }
        [self _showHighlight:highlight adjustPoint:textStorage.frame.origin];
        if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didLongpressedTextStorage:linkdata:)] &&
            [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
            [self.delegate lwAsyncDisplayView:self didLongpressedTextStorage:textStorage
                                     linkdata:_highlight.content];
        }
        break;
    }
    [self _endLongPressTimer];
}

- (LWTextHighlight *)_NeedShowHighlightWithIsLongpress:(BOOL)isLongPress
                                           textStorage:(LWTextStorage *)textStorage
                                            touchPoint:(CGPoint)touchPoint {
    if (![textStorage isKindOfClass:[LWTextStorage class]]) {
        return nil;
    }
    CGPoint adjustPosition = textStorage.frame.origin;
    LWTextHighlight* needShow = nil;
    for (LWTextHighlight* one in textStorage.textLayout.textHighlights) {
        for (NSValue* value in one.positions) {
            CGRect rect = [value CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x + adjustPosition.x,
                                           rect.origin.y + adjustPosition.y,
                                           rect.size.width,
                                           rect.size.height);
            if (CGRectContainsPoint(adjustRect, touchPoint)) {
                if (!isLongPress) {
                    if (one.type == LWTextHighLightTypeNormal) {
                        return one;
                    }
                    else if (one.type == LWTextHighLightTypeLongPress) {
                        continue;
                    }
                    needShow = one;
                } else {
                    if (one.type == LWTextHighLightTypeLongPress) {
                        return one;
                    }
                    continue;
                }
            }
        }
    }
    return needShow;
}

- (void)_showHighlight:(LWTextHighlight *)highlight adjustPoint:(CGPoint)adjustPoint {
    _showingHighlight = YES;
    _highlight = highlight;
    _highlightAdjustPoint = adjustPoint;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)_hideTapHighlight {
    if (!_showingHighlight ||
        _highlight.type == LWTextHighLightTypeLongPress) {
        return;
    }
    _showingHighlight = NO;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)_removeTapHighlight {
    [self _hideTapHighlight];
    _highlight = nil;
    _highlightAdjustPoint = CGPointZero;
}

- (void)_removeLongpressHighlight {
    if (!_showingHighlight){
        return;
    }
    _showingHighlight = NO;
    _highlight = nil;
    _highlightAdjustPoint = CGPointZero;
    _longpressPoint = CGPointZero;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)removeAllHighlights {
    [self _removeLongpressHighlight];
}

#pragma mark - Getter

+ (Class)layerClass {
    return [LWAsyncDisplayLayer class];
}

- (NSMutableArray *)imageContainers {
    if (_imageContainers) {
        return _imageContainers;
    }
    _imageContainers = [[NSMutableArray alloc] init];
    return _imageContainers;
}

- (NSMutableArray *)reusePool {
    if (_reusePool) {
        return _reusePool;
    }
    _reusePool = [[NSMutableArray alloc] init];
    return _reusePool;
}

#pragma mark - Setter

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    _displaysAsynchronously = displaysAsynchronously;
    [(LWAsyncDisplayLayer *)self.layer setDisplaysAsynchronously:_displaysAsynchronously];
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout == layout) {
        return;
    }
    
    [self _cleanAddToReusePool];
    
    _highlightAdjustPoint = CGPointZero;
    _longpressPoint = CGPointZero;
    _showingHighlight = NO;
    
    id oldLayout = _layout;
    LWTextHighlight* oldHighlight = _highlight;
    NSArray* oldImageStorages = _imageStorages;
    NSArray* oldTextStorages = _textStorages;
    _layout = nil;
    _imageStorages = nil;
    _textStorages = nil;
    _highlight = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [oldLayout class];
        [oldTextStorages class];
        [oldImageStorages class];
        [oldHighlight class];
    });
    
    _layout = layout;
    _imageStorages = self.layout.imageStorages;
    _textStorages = self.layout.textStorages;
    [self.layer setNeedsDisplay];
    
    __weak typeof(self) weakSelf = self;
    [self setImageStoragesResizeBlock:^(LWImageStorage* imageStorage,CGFloat delta) {
        __strong typeof(weakSelf) swself = weakSelf;
        if (swself.auotoLayoutCallback) {
            swself.auotoLayoutCallback(imageStorage,delta);
        }
    }];
}

@end
