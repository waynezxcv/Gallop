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


#import "LWHTMLDisplayView.h"
#import "LWAsyncDisplayView.h"
#import "LWLayout.h"

@interface LWHTMLDisplayView ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;

@end

@implementation LWHTMLDisplayView

- (id)init {
    self = [super init];
    if (self) {
        self.asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.asyncDisplayView.delegate = self;
        [self addSubview:self.asyncDisplayView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.asyncDisplayView.delegate = self;
        [self addSubview:self.asyncDisplayView];
    }
    return self;
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    CGSize contentSize = CGSizeMake(SCREEN_WIDTH, [layout suggestHeightWithBottomMargin:10.0f]);
    self.contentSize = contentSize;
    self.asyncDisplayView.frame = CGRectMake(0, 0, SCREEN_WIDTH, contentSize.height);
    self.asyncDisplayView.layout = self.layout;
}
#pragma mark - LWAsyncDisplayViewDelegate

/***  点击链接 ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data {
    if ([self.displayDelegate respondsToSelector:@selector(lwhtmlDisplayView:didCilickedTextStorage:linkdata:)]) {
        [self.displayDelegate lwhtmlDisplayView:self didCilickedTextStorage:textStorage linkdata:data];
    }
}
/***  点击LWImageStorage回调 ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch {
    NSLog(@"%@",imageStorage.contents);

}

@end
