//
//  LWActionSheetTableViewCell.m
//  WarmerApp
//
//  Created by 刘微 on 16/3/2.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWActionSheetTableViewCell.h"
#import "LWDefine.h"


@interface LWActionSheetTableViewCell ()

@property (nonatomic,strong) LWActionSheetTableViewCellContent* content;

@end

@implementation LWActionSheetTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.content = [[LWActionSheetTableViewCellContent alloc] initWithFrame:CGRectMake(0.0f,60.0f, SCREEN_WIDTH, 60.0f)];
        [self.contentView addSubview:self.content];
    }
    return self;
}

- (void)show {
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.content.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60.0f);
    } completion:^(BOOL finished) {

    }];
}

- (void)setTitle:(NSString *)title {
    if (_title != title ) {
        _title = title;
    }
    self.content.title = self.title;
}

@end



@interface LWActionSheetTableViewCellContent ()


@property (nonatomic,strong) UILabel* textLabel;

@end


@implementation LWActionSheetTableViewCellContent : UIView

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = [title copy];
    }
    self.textLabel.text = self.title;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 10.0f, 59.5f);
    CGContextAddLineToPoint(context, rect.size.width - 10.0f, 59.5f);
    CGContextSetLineWidth(context, 0.3f);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
}

@end