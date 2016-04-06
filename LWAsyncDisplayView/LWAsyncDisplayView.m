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
#import "LWRunLoopObserver.h"


typedef NS_ENUM(NSUInteger, LWAsyncDisplayViewState) {
    LWAsyncDisplayViewStateNeedLayout,
    LWAsyncDisplayViewStateNeedDisplay,
    LWAsyncDisplayViewStateHasDisplayed
};

@interface LWAsyncDisplayView ()
<LWAsyncDisplayLayerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign) LWAsyncDisplayViewState state;
@property (nonatomic,strong) UITapGestureRecognizer* tapGestureRecognizer;

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
    self.state = LWAsyncDisplayViewStateNeedLayout;
    self.layer.opaque = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    ((LWAsyncDisplayLayer *)self.layer).asyncDisplayDelegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Layout & Display

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = frame.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [super setFrame:frame];
        self.state = LWAsyncDisplayViewStateNeedDisplay;
    }
    [self _displayIfNeed];
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [super setBounds:bounds];
        self.state = LWAsyncDisplayViewStateNeedDisplay;
    }
    [self _displayIfNeed];
}

- (void)setLayouts:(NSArray *)layouts {
    if (_layouts && [_layouts isEqualToArray:layouts]) {
        return;
    }
    _layouts = [layouts copy];
    [self _displayIfNeed];
}

- (void)_displayIfNeed {
    if (self.state == LWAsyncDisplayViewStateNeedDisplay) {
        [(LWAsyncDisplayLayer *)self.layer cleanUp];
        [(LWAsyncDisplayLayer *)self.layer drawContentInRect:self.bounds];
    }
}

#pragma mark - Setter & Getter

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(_didSingleTapThisView:)];
        _tapGestureRecognizer.delegate = self;
    }
    return _tapGestureRecognizer;
}

#pragma mark - LWAsyncDisplayLayerDelegate

- (void)displayDidCancled {
    self.state = LWAsyncDisplayViewStateNeedLayout;
}

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    if (self.state == LWAsyncDisplayViewStateHasDisplayed) {
        return NO;
    }
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    if ([self.delegate respondsToSelector:@selector(extraAsyncDisplayIncontext:size:)] &&
        [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
        [self.delegate extraAsyncDisplayIncontext:context size:size];
    }
    for (LWTextLayout* layout in self.layouts) {
        [layout drawInContext:context];
    }
}

- (void)didFinishAsyncDisplay:(LWAsyncDisplayLayer *)layer isFiniedsh:(BOOL)isFinished {
    if (isFinished) {
        self.state = LWAsyncDisplayViewStateHasDisplayed;
    }
}

#pragma mark - SignleTapGesture

- (void)_didSingleTapThisView:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self];
    for (LWTextLayout* layout in self.layouts) {
        if (layout == nil) {
            continue;
        }
        CTFrameRef textFrame = layout.frame;
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
                            if ([self.delegate respondsToSelector:@selector(lwAsyncDicsPlayView:didCilickedLinkWithfData:)] &&
                                [self.delegate conformsToProtocol:@protocol(LWAsyncDisplayViewDelegate)]) {
                                [self.delegate lwAsyncDicsPlayView:self didCilickedLinkWithfData:[runAttribues objectForKey:kLWTextLinkAttributedName]];
                                break;
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

- (void)_layout:(LWTextLayout *)layout drawHighLightWithAttach:(LWTextAttach *)attach {
    
}

#pragma mark - UIGestrueRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
