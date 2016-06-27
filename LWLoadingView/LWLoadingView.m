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


#import "LWLoadingView.h"
#import "LWLoadingAnimationView.h"


@interface LWLoadingView ()

@property (nonatomic,strong) LWLoadingAnimationView* animationView;

@end

@implementation LWLoadingView

- (id)init {
    self = [super initWithFrame:SCREEN_BOUNDS];
    if (self) {
        self.backgroundColor = RGB(255, 255, 255, 1);
        self.animationView = [[LWLoadingAnimationView alloc]
                              initWithFrame:CGRectMake(SCREEN_WIDTH/2- 40.0f,
                                                       SCREEN_HEIGHT/2 - 40.0f,
                                                       80.0f,
                                                       80.0f)];
        self.animationView.animationTintColor = RGB(232, 104, 96,1.0f);
        [self addSubview:self.animationView];
    }
    return self;
}

- (id)initWithBackgroundColor:(UIColor *)color {
    self = [super initWithFrame:SCREEN_BOUNDS];
    if (self) {
        self.backgroundColor = color;
        self.animationView = [[LWLoadingAnimationView alloc]
                              initWithFrame:CGRectMake(SCREEN_WIDTH/2- 40.0f,
                                                       SCREEN_HEIGHT/2 - 40.0f,
                                                       80.0f,
                                                       80.0f)];
        self.animationView.animationTintColor = RGB(232, 104, 96,1.0f);
        [self addSubview:self.animationView];
    }
    return self;
}


+ (void)showInView:(UIView *)view {
    LWLoadingView* loadingView = [[LWLoadingView alloc] init];
    [view addSubview:loadingView];
    loadingView.hidden = NO;
    [loadingView.animationView animationBegin];
}


+ (void)showInView:(UIView *)view backgroundColor:(UIColor *)color {
    LWLoadingView* loadingView = [[LWLoadingView alloc] initWithBackgroundColor:color];
    [view addSubview:loadingView];
    loadingView.hidden = NO;
    [loadingView.animationView animationBegin];
}

+ (void)hideInViwe:(UIView *)view {
    for (UIView* aView in view.subviews) {
        if ([aView isMemberOfClass:[LWLoadingView class]]) {
            LWLoadingView* loadingView = (LWLoadingView *)aView;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    loadingView.alpha = 0.0f;
                }completion:^(BOOL finished) {
                    [loadingView.animationView animationStop];
                    [loadingView removeFromSuperview];
                }];
            });
        }
    }
}

@end
