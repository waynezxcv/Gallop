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


#import "LWImageBrowserButton.h"

@implementation LWImageBrowserButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect r = CGRectMake(10.0f, 10.0f, rect.size.width - 20.0f, rect.size.height - 20.0f);
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:5.0f];
    [[UIColor whiteColor] setStroke];
    [bezierPath stroke];
    [bezierPath addClip];
    
    NSMutableParagraphStyle* papragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [papragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f],
                                 NSParagraphStyleAttributeName:papragraphStyle};
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:@"•••"
                                                                 attributes:attributes];
    [string drawInRect:r];
}



@end
