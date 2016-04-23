//
//  CommentView.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/23.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "CommentView.h"

@interface CommentView ()<UITextViewDelegate>

@property (nonatomic,strong) UILabel* placeholderLabel;

@end

@implementation CommentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(247, 247, 247, 0.9);
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.textView];
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
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10.0f, 7.0f, SCREEN_WIDTH - 20.0f, 30.0f) cornerRadius:3.0f];
    [[UIColor grayColor] setStroke];
    [bezierPath stroke];
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLabel.frame = CGRectMake(15.0f, 7.0f,  SCREEN_WIDTH - 20.0f, 30.0f);
    self.textView.frame = CGRectMake(10.0f, 7.0f, SCREEN_WIDTH - 20.0f, 30.0f);
}

#pragma mark  - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }
    else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - Setter

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = [placeHolder copy];
    self.placeholderLabel.text = self.placeHolder;
}

#pragma mark - Getter

- (UITextView *)textView {
    if (_textView) {
        return _textView;
    }
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
    _textView.layer.cornerRadius = 3.0f;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:15.0f];
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeySend;
    return _textView;
}

- (UILabel *)placeholderLabel {
    if (_placeholderLabel) {
        return _placeholderLabel;
    }
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.textColor = [UIColor grayColor];
    _placeholderLabel.font = [UIFont systemFontOfSize:15.0f];
    return _placeholderLabel;
}

@end
