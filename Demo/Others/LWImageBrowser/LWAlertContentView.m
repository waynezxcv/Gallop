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


#import "LWAlertContentView.h"
#import "LWImageBrowserDefine.h"


@interface LWAlertContentView ()

@property (nonatomic,strong) UILabel* label;

@end

@implementation LWAlertContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(0, 0, 0, 0.8);
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:15.0f];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.numberOfLines = 0;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];

        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        _message = [message copy];
    }
    self.label.text = self.message;
}

@end
