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
#import "UIView+DisplayAddtions.h"


@interface LWAsyncDisplayView ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) NSMutableArray* reusePool;
@property (nonatomic,strong) NSMutableArray* imageContainers;
@property (nonatomic,strong) UILongPressGestureRecognizer* longPressGesture;

@end


@implementation LWAsyncDisplayView

{
    BOOL _showingHighlight;
    LWTextHighlight* _highlight;
    CGPoint _highlightAdjustPoint;
    CGPoint _touchBeganPoint;
    NSArray* _textStorages;
    NSArray* _imageStorages;
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
    self.displaysAsynchronously = YES;
    _showingHighlight = NO;
    _highlight = nil;
    _touchBeganPoint = CGPointZero;
    _highlightAdjustPoint = CGPointZero;
    _textStorages = nil;
    _imageStorages = nil;
    [self addGestureRecognizer:self.longPressGesture];
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
            [container setContentWithImageStorage:imageStorage
                           displaysAsynchronously:self.displaysAsynchronously
                                      resizeBlock:resizeBlock];
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
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL found = NO;
    
    if (_highlight) {
        _highlight = nil;
        if (_showingHighlight) {
            [self _hideHighlight];
        }
    }
    
    for (LWTextStorage* textStorage in _textStorages) {
        if (!_highlight) {
            LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO
                                                                  textStorage:textStorage
                                                                   touchPoint:touchPoint];
            if (hightlight) {
                _highlight = hightlight;
                _highlightAdjustPoint = textStorage.frame.origin;
                [self _showHighligt];
                found = YES;
                break;
            }
        }
    }
    
    if (!found) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL found = NO;
    
    if (!_highlight) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    for (LWTextStorage* textStorage in _textStorages) {
        LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO
                                                              textStorage:textStorage
                                                               touchPoint:touchPoint];
        if (hightlight == _highlight) {
            if (!_showingHighlight) {
                [self _showHighligt];
                found = YES;
            }
        } else {
            if (_showingHighlight) {
                [self _hideHighlight];
                found = NO;
            }
        }
        break;
    }
    
    if (!found) {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL found = NO;
    
    for (LWImageStorage* imageStorage in _imageStorages) {
        if (CGRectContainsPoint(imageStorage.frame, touchPoint)) {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedImageStorage:touch:)] &&
                [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                [self.delegate lwAsyncDisplayView:self didCilickedImageStorage:imageStorage touch:touch];
            }
            found = YES;
            break;
        }
    }
    
    
    if (!_highlight && !found) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    for (LWTextStorage* textStorage in _textStorages) {
        LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO
                                                              textStorage:textStorage
                                                               touchPoint:touchPoint];
        if (hightlight == _highlight) {
            if (self.delegate &&
                [self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedTextStorage:linkdata:)] &&
                [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                [self.delegate lwAsyncDisplayView:self didCilickedTextStorage:textStorage linkdata:_highlight.content];
            }
            found = YES;
            break;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(0.15f * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       _highlight = nil;
                       [self _hideHighlight];
                   });
    
    if (!found) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    switch (longPressGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint point = [longPressGestureRecognizer locationInView:self];
            _touchBeganPoint = point;
            for (LWTextStorage* textStorage in _textStorages) {
                LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:YES
                                                                      textStorage:textStorage
                                                                       touchPoint:_touchBeganPoint];
                
                if (hightlight.type == LWTextHighLightTypeLongPress) {
                    if (_highlight != hightlight) {
                        _highlight = hightlight;
                        _highlightAdjustPoint = textStorage.frame.origin;
                        [self _showHighligt];
                        break;
                    }
                }
            }
        }break;
            
        case UIGestureRecognizerStateEnded:{
            
            if (_highlight.type != LWTextHighLightTypeLongPress) {
                _highlight = nil;
                [self _hideHighlight];
            }
            
            for (LWTextStorage* textStorage in _textStorages) {
                LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:YES
                                                                      textStorage:textStorage
                                                                       touchPoint:_touchBeganPoint];
                if (_highlight && hightlight == _highlight) {
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didLongpressedTextStorage:linkdata:)] &&
                        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                        [self.delegate lwAsyncDisplayView:self
                                didLongpressedTextStorage:textStorage
                                                 linkdata:_highlight.content];
                    }
                }
            }
        }break;
            
        default: break;
    }
}

- (LWTextHighlight *)_searchTextHighlightWithType:(BOOL)isLongPress
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

- (void)_showHighligt {
    _showingHighlight = YES;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)_hideHighlight {
    _showingHighlight = NO;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}


- (void)removeHighlightIfNeed {
    if (!_highlight) {
        return;
    }
    _highlightAdjustPoint = CGPointZero;
    _touchBeganPoint = CGPointZero;
    _showingHighlight = NO;
    _highlight = nil;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
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

- (UILongPressGestureRecognizer *)longPressGesture {
    if (_longPressGesture) {
        return _longPressGesture;
    }
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc]
                         initWithTarget:self
                         action:@selector(longPressHandler:)];
    _longPressGesture.minimumPressDuration = 0.5f;
    return _longPressGesture;
}

#pragma mark - Setter

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    if (_displaysAsynchronously != displaysAsynchronously) {
        _displaysAsynchronously = displaysAsynchronously;
        [(LWAsyncDisplayLayer *)self.layer
         setDisplaysAsynchronously:_displaysAsynchronously];
    }
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout == layout) {
        return;
    }
    
    [self _cleanAddToReusePool];
    
    _highlightAdjustPoint = CGPointZero;
    _touchBeganPoint = CGPointZero;
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
