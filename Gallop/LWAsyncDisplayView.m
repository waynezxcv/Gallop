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
#import "LWAsyncImageView.h"
#import "GallopUtils.h"
#import "LWTransaction.h"
#import "LWTransactionGroup.h"
#import "CALayer+LWTransaction.h"
#import "LWAsyncImageView+Display.h"
#import "LWFlag.h"




@interface LWAsyncDisplayView ()<LWAsyncDisplayLayerDelegate>

@property (nonatomic,strong) NSMutableArray* reusePool;//这个数组用来存放暂时不使用的LWAsyncImageView
@property (nonatomic,strong) NSMutableArray* imageContainers;//这个数组用来存放正在使用的LWAsyncImageView
@property (nonatomic,strong) UILongPressGestureRecognizer* longPressGesture;//长按手势
@property (nonatomic,assign) BOOL showingHighlight;//是否正在高亮显示
@property (nonatomic,strong) LWTextHighlight* highlight;//当前的高亮显示
@property (nonatomic,assign) CGPoint highlightAdjustPoint;//高亮的坐标偏移点
@property (nonatomic,assign) CGPoint touchBeganPoint;//记录触摸开始的坐标
@property (nonatomic,strong,readonly) LWFlag* displayFlag;//一个自增的标识类，用于取消绘制。


@end


@implementation LWAsyncDisplayView

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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
    self.layer.contentsScale = [GallopUtils contentsScale];
    [self addGestureRecognizer:self.longPressGesture];
    self.layer.opaque = YES;
    self.displaysAsynchronously = YES;
    
    _showingHighlight = NO;
    _highlight = nil;
    _touchBeganPoint = CGPointZero;
    _highlightAdjustPoint = CGPointZero;
    _displayFlag = [[LWFlag alloc] init];
}

- (void)setLayout:(LWLayout *)layout {
    
    if ([_layout isEqual: layout]) {
        return;
    }
    
    [self _resetHighlight];
    [self _cleanImageViewAddToReusePool];
    [self _cleanupAndReleaseModelOnSubThread];
    
    _layout = layout;
    [self.layer setNeedsDisplay];
    
    __weak typeof(self) weakSelf = self;
    [self setImageStoragesResizeBlock:^(LWImageStorage* imageStorage,CGFloat delta) {
        __strong typeof(weakSelf) swself = weakSelf;
        if (swself.auotoLayoutCallback) {
            swself.auotoLayoutCallback(imageStorage,delta);
        }
    }];
}

#pragma mark - Private

- (void)_resetHighlight {
    _highlightAdjustPoint = CGPointZero;
    _touchBeganPoint = CGPointZero;
    _showingHighlight = NO;
}


- (void)_cleanupAndReleaseModelOnSubThread {
    
    id <LWLayoutProtocol> oldLayout = _layout;
    LWTextHighlight* oldHighlight = _highlight;
    
    _layout = nil;
    _highlight = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [oldLayout class];
        [oldHighlight class];
    });
}


- (void)_cleanImageViewAddToReusePool {
    
    [self.displayFlag increment];
    
    for (NSInteger i = 0; i < self.imageContainers.count; i ++) {
        LWAsyncImageView* container = [self.imageContainers objectAtIndex:i];
        container.image = nil;
        container.gifImage = nil;
        container.hidden = YES;
        [self.reusePool addObject:container];
    }
    
    [self.imageContainers removeAllObjects];
    
}


- (void)setImageStoragesResizeBlock:(void(^)(LWImageStorage* imageStorage, CGFloat delta))resizeBlock {
    
    LWFlag* displayFlag = _displayFlag;
    int32_t value = displayFlag.value;
    
    LWAsyncDisplayIsCanclledBlock isCancelledBlock = ^ BOOL() {
        return value != _displayFlag.value;
    };
    
    for (NSInteger i = 0; i < self.layout.imageStorages.count; i ++) {
        
        @autoreleasepool {
            
            if (isCancelledBlock()) {
                return;
            }
            
            LWImageStorage* imageStorage = self.layout.imageStorages[i];
            if ([imageStorage.contents isKindOfClass:[UIImage class]] &&
                imageStorage.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {
                continue;
            }
            
            
            LWAsyncImageView* container = [self _dequeueReusableImageContainerWithIdentifier:imageStorage.identifier];
            if (!container) {
                container = [[LWAsyncImageView alloc] initWithFrame:CGRectZero];
                container.identifier = imageStorage.identifier;
                [self addSubview:container];
            }
            
            container.displayAsynchronously = self.displaysAsynchronously;
            container.backgroundColor = imageStorage.backgroundColor;
            container.clipsToBounds = imageStorage.clipsToBounds;
            container.contentMode = imageStorage.contentMode;
            container.frame = imageStorage.frame;
            container.layer.shadowColor = imageStorage.shadowColor.CGColor;
            container.layer.shadowOffset = imageStorage.shadowOffset;
            container.layer.shadowOpacity = imageStorage.shadowOpacity;
            container.layer.shadowRadius = imageStorage.shadowRadius;
            container.hidden = NO;
            
            [container lw_setImageWihtImageStorage:imageStorage resize:resizeBlock completion:nil];
            [self.imageContainers addObject:container];
        }
    }
}

- (LWAsyncImageView *)_dequeueReusableImageContainerWithIdentifier:(NSString *)identifier {
    for (LWAsyncImageView* container in self.reusePool) {
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
        
        for (LWTextStorage* textStorage in self.layout.textStorages) {
            //先移除之前的附件
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
            for (LWTextStorage* textStorage in self.layout.textStorages) {
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
        
        //这个代理方法调用需要用户额外绘制的内容
        [self.delegate extraAsyncDisplayIncontext:context size:self.bounds.size isCancelled:isCancelledBlock];
    }
    
    //绘制图片内容
    for (LWImageStorage* imageStorage in self.layout.imageStorages) {
        if (isCancelledBlock()) {
            return;
        }
        [imageStorage lw_drawInContext:context isCancelled:isCancelledBlock];
    }
    
    //绘制文字内容
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        [textStorage.textLayout drawIncontext:context
                                         size:CGSizeZero
                                        point:textStorage.frame.origin
                                containerView:self
                               containerLayer:self.layer
                                  isCancelled:isCancelledBlock];
    }
    
    //绘制高亮内容
    if (_showingHighlight && _highlight) {
        for (NSValue* rectValue in _highlight.positions) {
            if (isCancelledBlock()) {
                return;
            }
            CGRect rect = [rectValue CGRectValue];
            CGRect adjustRect = CGRectMake(rect.origin.x + _highlightAdjustPoint.x,rect.origin.y + _highlightAdjustPoint.y,rect.size.width,rect.size.height);
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:adjustRect cornerRadius:2.0f];
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
    
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        if (!_highlight) {
            LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
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
    
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
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
    
    for (LWImageStorage* imageStorage in self.layout.imageStorages) {
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
    
    for (LWTextStorage* textStorage in self.layout.textStorages) {
        LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:NO textStorage:textStorage touchPoint:touchPoint];
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
            for (LWTextStorage* textStorage in self.layout.textStorages) {
                LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:YES textStorage:textStorage touchPoint:_touchBeganPoint];
                
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
            for (LWTextStorage* textStorage in self.layout.textStorages) {
                LWTextHighlight* hightlight =  [self _searchTextHighlightWithType:YES textStorage:textStorage touchPoint:_touchBeganPoint];
                if (_highlight && hightlight == _highlight) {
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didLongpressedTextStorage:linkdata:)] &&
                        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                        [self.delegate lwAsyncDisplayView:self didLongpressedTextStorage:textStorage linkdata:_highlight.content];
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
            CGRect adjustRect = CGRectMake(rect.origin.x + adjustPosition.x,rect.origin.y + adjustPosition.y,rect.size.width,rect.size.height);
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
        [(LWAsyncDisplayLayer *)self.layer setDisplaysAsynchronously:_displaysAsynchronously];
    }
}

@end
