//
//  LWLabel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWLabel.h"


@implementation LWLabel


#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.text = @"";
    self.font = [UIFont systemFontOfSize:13.0f];
    self.textColor = [UIColor blackColor];
    self.shadowColor = [UIColor blackColor];
    self.shadowOffset = CGSizeMake(5.0f, 5.0f);
    self.textAlignment = NSTextAlignmentLeft;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* attributesDict = @{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],
                                     NSForegroundColorAttributeName:[UIColor blackColor]};
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributesDict];
}

#pragma mark - Setter & Getter

@end
