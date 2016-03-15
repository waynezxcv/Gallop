//
//  LWWebViewProgress.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/3.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWWebViewProgress.h"
#import "LWDefine.h"



@interface LWWebViewProgress ()

@property (nonatomic,strong) CAShapeLayer* shapeLayer;

@end

@implementation LWWebViewProgress

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = CGRectMake(0.0f, 0.0f, 0.0f, self.bounds.size.height);
        self.shapeLayer.backgroundColor = [UIColor blueColor].CGColor;
        [self.layer addSublayer:self.shapeLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.shapeLayer.frame = CGRectMake(0.0f, 0.0f,_progress * SCREEN_WIDTH, self.bounds.size.height);
}

@end
