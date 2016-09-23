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

#import "LWAlertView.h"
#import "LWAlertContentView.h"
#import "LWImageBrowserDefine.h"


@interface LWAlertView ()

@property (nonatomic,strong) LWAlertContentView* contentView;

@end

@implementation LWAlertView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView = [[LWAlertContentView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100.0f,
                                                                                SCREEN_HEIGHT/2 - 100.0f,
                                                                                200.0f,
                                                                                100.0f)];
        [self addSubview:self.contentView];
    }
    return self;
}

+ (void)shoWithMessage:(NSString *)message {
    LWAlertView* alertView = [[LWAlertView alloc] initWithFrame:SCREEN_BOUNDS];
    alertView.alpha = 0.0f;
    alertView.contentView.message = message;
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:alertView];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         alertView.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                      (int64_t)(0.5f * NSEC_PER_SEC)),
                                        dispatch_get_main_queue(), ^{
                                            [UIView animateWithDuration:0.2f animations:^{
                                                alertView.alpha = 0.0f;
                                            } completion:^(BOOL finished) {
                                                [alertView removeFromSuperview];
                                            }];
                                        });
                     }];
}

@end
