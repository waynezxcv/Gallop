//
//  LWAlertView.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/24.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAlertView.h"
#import "LWAlertContentView.h"
#import "GallopUtils.h"


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
