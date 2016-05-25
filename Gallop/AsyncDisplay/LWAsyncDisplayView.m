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
#import "LWRunLoopTransactions.h"



@interface LWAsyncDisplayView ()

@property (nonatomic,strong) NSMutableArray* imageContainers;
@property (nonatomic,assign) NSInteger maxImageStorageCount;

@property (nonatomic,copy) NSArray* textStorages;
@property (nonatomic,copy) NSArray* imageStorages;

@end


@implementation LWAsyncDisplayView{
    LWTextHighlight* _highlight;
    CGPoint _highlightAdjustPoint;
    BOOL _showingHighlight;
}


#pragma mark - LifeCycle

- (id)initWithFrame:(CGRect)frame maxImageStorageCount:(NSInteger)count {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.maxImageStorageCount = count;
        for (NSInteger i = 0; i < self.maxImageStorageCount; i ++) {
            UIView* container = [[UIView alloc] initWithFrame:CGRectZero];
            container.hidden = YES;
            container.backgroundColor = RGB(240, 240, 240, 1);
            container.clipsToBounds = YES;
            [self addSubview:container];
            [self.imageContainers addObject:container];
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.maxImageStorageCount = 0;
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


#pragma mark - Private
- (void)_setImageStorages {
    for (NSInteger i = 0; i < self.imageContainers.count; i ++) {
        if (i >= _imageStorages.count) {
            UIView* container = self.imageContainers[i];
            [container cleanup];
        } else {
            LWImageStorage* imageStorage = _imageStorages[i];
            UIView* container = self.imageContainers[i];
            [container setContentWithImageStorage:imageStorage];
        }
    }
}

#pragma mark - Display

- (LWAsyncDisplayTransaction *)asyncDisplayTransaction {
    LWAsyncDisplayTransaction* transaction = [[LWAsyncDisplayTransaction alloc] init];
    transaction.willDisplayBlock = ^(CALayer *layer) {
        [layer removeAnimationForKey:@"fadeshowAnimation"];
        for (LWTextStorage* textStorage in _textStorages) {
            [textStorage.textLayout removeAttachmentFromSuperViewOrLayer];
        }
    };
    transaction.displayBlock = ^(CGContextRef context, CGSize size, LWAsyncDisplayIsCanclledBlock isCancelledBlock) {
        [self _drawStoragesInContext:context inCancelled:isCancelledBlock];
    };
    transaction.didDisplayBlock = ^(CALayer *layer, BOOL finished) {
        [layer removeAnimationForKey:@"fadeshowAnimation"];
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
                                         size:textStorage.textLayout.textBoundingSize
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
- (LWTextHighlight *)_isNeedShowHighlight:(LWTextStorage *)textStorage touchPoint:(CGPoint)touchPoint {
    if ([textStorage isKindOfClass:[LWTextStorage class]]) {
        CGPoint adjustPosition = textStorage.frame.origin;
        for (LWTextHighlight* aHighlight in textStorage.textLayout.textHighlights) {
            for (NSValue* value in aHighlight.positions) {
                CGRect rect = [value CGRectValue];
                CGRect adjustRect = CGRectMake(rect.origin.x + adjustPosition.x,
                                               rect.origin.y + adjustPosition.y,
                                               rect.size.width,
                                               rect.size.height);
                if (CGRectContainsPoint(adjustRect, touchPoint)) {
                    return aHighlight;
                }
            }
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    BOOL found = NO;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    for (LWTextStorage* textStorage in _textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            LWTextHighlight* hightlight = [self _isNeedShowHighlight:textStorage touchPoint:touchPoint];
            if (hightlight) {
                [self _showHighlight:hightlight adjustPoint:textStorage.frame.origin];
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
            LWTextHighlight* hightlight = [self _isNeedShowHighlight:textStorage touchPoint:touchPoint];
            if (hightlight) {
                [self _showHighlight:hightlight adjustPoint:textStorage.frame.origin];
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
                found = YES;
                [self.delegate lwAsyncDisplayView:self didCilickedImageStorage:imageStorage touch:touch];
            }
        }
    }
    for (LWTextStorage* textStorage in _textStorages) {
        if (textStorage == nil) {
            continue;
        }
        if ([textStorage isKindOfClass:[LWTextStorage class]]) {
            if (_highlight) {
                if ([self.delegate respondsToSelector:@selector(lwAsyncDisplayView:didCilickedLinkWithfData:)]) {
                    [self.delegate lwAsyncDisplayView:self didCilickedLinkWithfData:_highlight.content];
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _removeHightlight];
            });
            break;
        }
    }
    if (!found) {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)_showHighlight:(LWTextHighlight *)highlight adjustPoint:(CGPoint)adjustPoint {
    _showingHighlight = YES;
    _highlight = highlight;
    _highlightAdjustPoint = adjustPoint;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)_hideHightlight {
    if (!_showingHighlight) {
        return;
    }
    _showingHighlight = NO;
    [(LWAsyncDisplayLayer *)self.layer displayImmediately];
}

- (void)_removeHightlight {
    [self _hideHightlight];
    _highlight = nil;
    _highlightAdjustPoint = CGPointZero;
}

#pragma mark - Getter

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

#pragma mark - Setter

- (void)setDisplaysAsynchronously:(BOOL)displaysAsynchronously {
    _displaysAsynchronously = displaysAsynchronously;
    [(LWAsyncDisplayLayer *)self.layer setDisplaysAsynchronously:_displaysAsynchronously];
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout == layout) {
        return;
    }
    _layout = layout;
    self.imageStorages = self.layout.imageStorages;
    self.textStorages = self.layout.textStorages;
    [self.layer setNeedsDisplay];
    [self _setImageStorages];
}

@end
