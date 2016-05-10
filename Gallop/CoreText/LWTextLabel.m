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

#import "LWTextLabel.h"
#import "UIView+AsyncDisplay.h"
#import "LWTextLine.h"
#import "LWTextAttachment.h"

@implementation LWTextLabel
{
    LWTextHighlight* _highlight;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)setTextLayout:(LWTextLayout *)textLayout {
    if (_textLayout != textLayout) {
        _textLayout = textLayout;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize boundingSize = self.textLayout.textBoundingSize;
    CGPoint point = CGPointZero;
    [self.textLayout drawIncontext:context size:boundingSize point:point containerView:self containerLayer:self.layer];
    if (_highlight) {
        for (NSValue* value in _highlight.positions) {
            CGRect rect = [value CGRectValue];
            UIBezierPath* beizerPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                                  cornerRadius:2.0f];
            [_highlight.hightlightColor setFill];
            [beizerPath fill];
        }
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (LWTextHighlight* highlight in self.textLayout.textHighlights) {
        _highlight = highlight;
        [self setNeedsDisplay];
    }
}


@end
