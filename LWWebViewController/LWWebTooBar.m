//
//  LWWebTooBar.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/15.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWWebTooBar.h"
#import "LWDefine.h"



@implementation LWWebTooBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(247, 247, 247, 0.9);

        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(10.0f, 12.0f, 40.0f, 20.0);
        [self.backButton setTitle:@"后退" forState:UIControlStateNormal];
        [self.backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.backButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:self.backButton];

        self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.forwardButton.frame = CGRectMake(60.0f, 12.0f, 40.0f, 20.0f);
        [self.forwardButton setTitle:@"前进" forState:UIControlStateNormal];
        [self.forwardButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.forwardButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:self.forwardButton];

        self.reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.reloadButton.frame = CGRectMake(SCREEN_WIDTH - 50.0f, 12.0f, 40.0f, 20.0f);
        [self.reloadButton setTitle:@"刷新" forState:UIControlStateNormal];
        [self.reloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.reloadButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:self.reloadButton];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, rect.size.width, 0.0f);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokePath(context);
}


- (void)setCanGoBack:(BOOL)canGoBack{
    _canGoBack = canGoBack;
    self.backButton.enabled = _canGoBack;
    if (self.canGoBack) {
        [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [self.backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)setCanGoForward:(BOOL)canGoForward {
    _canGoForward = canGoForward;
    self.forwardButton.enabled = canGoForward;
    if (self.forwardButton) {
        [self.forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [self.forwardButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

@end
