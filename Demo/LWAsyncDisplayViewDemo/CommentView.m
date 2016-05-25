


/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/










#import "CommentView.h"
#import "GallopUtils.h"

@interface CommentView ()<UITextViewDelegate>

@property (nonatomic,strong) UILabel* placeholderLabel;
@property (nonatomic,assign) CGFloat textViewHeight;
@property (nonatomic,strong) UIButton* emojiButton;

@end

@implementation CommentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(247, 247, 247, 0.9);
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.textView];
        [self addSubview:self.emojiButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame sendBlock:(PressSendBlock)sendBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.sendBlock = [sendBlock copy];
        self.backgroundColor = RGB(247, 247, 247, 0.9);
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.textView];
        [self addSubview:self.emojiButton];
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
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:
                                CGRectMake(10.0f,
                                           12.0f,
                                           SCREEN_WIDTH - 55.0f,
                                           rect.size.height - 24.0f)
                                                          cornerRadius:3.0f];
    [[UIColor grayColor] setStroke];
    [bezierPath stroke];
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = CGRectMake(10.0f, 12.0f, SCREEN_WIDTH - 55.0f, self.bounds.size.height - 24.0f);
    self.placeholderLabel.frame = CGRectMake(15.0f, 12.0f, SCREEN_WIDTH - 55.0f, self.bounds.size.height - 24.0f);
    self.emojiButton.frame = CGRectMake(SCREEN_WIDTH - 40.0f, 4.5f, 35.0f, 35.0f);
}

#pragma mark  - UITextViewDelegate

- (void)textView:(AutoFitSizeTextView *)textView heightChanged:(NSInteger)height {
    [self setNeedsDisplay];
    if (self.frame.size.height <= 100.0f &&
        self.frame.origin.y != SCREEN_HEIGHT &&
        self.frame.size.height >= 44.0f) {
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y - height - 3.0f,
                                self.frame.size.width,
                                self.frame.size.height + height + 3.0f);
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self placeholderHidenOrShow:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        if (self.textView.text.length != 0) {
            if (self.sendBlock) {
                NSString* content = [self.textView.text copy];
                self.sendBlock(content);
                self.textView.text = @"";
                [self.textView resignFirstResponder];
            }
        }
        [self textViewDidChange:textView];
        return NO;
    }
    return YES;
}


- (void)placeholderHidenOrShow:(UITextView *)textView {
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
    _textView = [[AutoFitSizeTextView alloc] initWithFrame:CGRectZero];
    _textView.layer.cornerRadius = 3.0f;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.fitSizeDelegate = self;
    _textView.layoutManager.allowsNonContiguousLayout = NO;
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

- (UIButton *)emojiButton {
    if (_emojiButton) {
        return _emojiButton;
    }
    _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emojiButton setImage:[UIImage imageNamed:@"[face]"] forState:UIControlStateNormal];
    return _emojiButton;
}

@end
