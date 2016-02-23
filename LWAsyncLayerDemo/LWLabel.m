//
//  LWLabel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWLabel.h"
#import "LWAsyncDisplayLayer.h"
#import "LWRunLoopObserver.h"

@interface LWLabel ()<LWAsyncDisplayLayerDelegate>

@end

@implementation LWLabel

#pragma mark - Initialization

/**
 *  “default is [CALayer class]. Used when creating the underlying layer for the view.”
 *  让self.layer为LWAsyncDisplayLayer
 *
 */
+ (Class)layerClass {
    return [LWAsyncDisplayLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.opaque = NO;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        ((LWAsyncDisplayLayer *)self.layer).asyncDisplayDelegate = self;

        self.text = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentLeft;
        self.veriticalAlignment = LWVerticalAlignmentCenter;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.attributedText = nil;
    }
    return self;
}

#pragma mark - Setter & Getter
//
//- (void)setAttributedText:(NSAttributedString *)attributedText {
//    if ([_attributedText isEqual:attributedText] || _attributedText == attributedText) {
//        return;
//    }
//    _attributedText  = [attributedText copy];
//    self.textLayout.attributedText = [self.attributedText copy];
//}
//
//- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
//    if (_lineBreakMode == lineBreakMode) {
//        return;
//    }
//    _lineBreakMode = lineBreakMode;
//    self.textLayout.lineBreakMode = self.lineBreakMode;
//}
//
//- (void)setVeriticalAlignment:(LWVerticalAlignment)veriticalAlignment {
//    if (_veriticalAlignment == veriticalAlignment) {
//        return;
//    }
//    _veriticalAlignment = veriticalAlignment;
//    self.textLayout.veriticalAlignment = self.veriticalAlignment;
//}
//
//- (void)setTextAlignment:(NSTextAlignment)textAlignment {
//    if (_textAlignment == textAlignment) {
//        return;
//    }
//    _textAlignment = textAlignment;
//    self.textLayout.textAlignment = self.textAlignment;
//}
//
//- (void)setFont:(UIFont *)font {
//    if ([_font isEqual:font] || _font == font) {
//        return;
//    }
//    _font = font;
//    self.textLayout.font = self.font;
//}
//
//- (void)setTextColor:(UIColor *)textColor {
//    if ([_textColor isEqual:textColor] || _textColor == textColor) {
//        return;
//    }
//    _textColor = textColor;
//    self.textLayout.textColor = self.textColor;
//}
//
//- (void)setText:(NSString *)text {
//    if ([_text isEqualToString:text] || _text == text) {
//        return;
//    }
//    _text = [text copy];
//    self.text = [self.text copy];
//}

- (void)setLayouts:(NSArray *)layouts {
    if (_layouts == layouts) {
        return;
    }
    _layouts = layouts;
    [self _setNeedDisplay];
}

#pragma mark - LWAsyncDisplayLayerDelegate

- (BOOL)willBeginAsyncDisplay:(LWAsyncDisplayLayer *)layer {
    return YES;
}

- (void)didAsyncDisplay:(LWAsyncDisplayLayer *)layer context:(CGContextRef)context size:(CGSize)size {
    for (LWTextLayout* layout in self.layouts) {
        [layout drawInContext:context];
    }
}

#pragma mark - Private

- (void)_setNeedDisplay {
    [(LWAsyncDisplayLayer *)self.layer cleanUp];
    [(LWAsyncDisplayLayer *)self.layer asyncDisplayContent];
}

#pragma mark - Touch
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch* touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    NSLog(@"touchbegan%@",NSStringFromCGPoint(point));
//    for (LWTextLayout* layout in self.layouts) {
//        for (LWTextAttach* attach in layout.attachs) {
//            NSLog(@"%@",NSStringFromCGRect(attach.position));
//            if (CGRectContainsPoint(attach.position, point)) {
////                NSLog(@"点击了。。:%@",attach.data);
//            }
//        }
//    }
//}

@end
