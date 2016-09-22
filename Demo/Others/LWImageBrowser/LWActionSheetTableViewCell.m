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


#import "LWActionSheetTableViewCell.h"
#import "LWImageBrowserDefine.h"



@interface LWActionSheetTableViewCell ()

@property (nonatomic,strong) LWActionSheetTableViewCellContent* content;

@end

@implementation LWActionSheetTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.content = [[LWActionSheetTableViewCellContent alloc]
                        initWithFrame:CGRectMake(0.0f,
                                                 60.0f,
                                                 SCREEN_WIDTH,
                                                 60.0f)];
        [self.contentView addSubview:self.content];
    }
    return self;
}


- (void)show {
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.content.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60.0f);
    } completion:^(BOOL finished) {}];
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
        self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
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