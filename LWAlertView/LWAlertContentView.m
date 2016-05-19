//
//  LWAlertContentView.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/24.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAlertContentView.h"
#import "LWDefine.h"



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
