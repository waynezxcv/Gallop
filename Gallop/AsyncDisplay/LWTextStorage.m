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

#import "LWTextStorage.h"

@interface LWTextStorage ()

@property (nonatomic,strong) LWTextLayout* textLayout;

@end

#pragma mark - Init

@implementation LWTextStorage

+ (LWTextStorage *)lw_textStorageWithTextLayout:(LWTextLayout *)textLayout frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    textStorage.textLayout = textLayout;
    return textStorage;
}

+ (LWTextStorage *)LW_textStrageWithText:(NSAttributedString *)text frame:(CGRect)frame {
    LWTextStorage* textStorage = [[LWTextStorage alloc] initWithFrame:frame];
    textStorage.attributedText = [text mutableCopy];
    textStorage.textLayout = [textStorage _creatTextLayout];
    return textStorage;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.linespace = 2.0f;
        self.characterSpacing = 1.0f;
        self.underlineStyle = NSUnderlineStyleNone;
        self.widthToFit = YES;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.text = nil;
        self.attributedText = nil;
        self.textColor = [UIColor blackColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.frame = CGRectZero;
        self.linespace = 2.0f;
        self.characterSpacing = 1.0f;
        self.underlineStyle = NSUnderlineStyleNone;
        self.widthToFit = YES;
    }
    return self;
}


- (void)setText:(NSString *)text {

}

- (LWTextLayout *)_creatTextLayout {
    if (!self.attributedText) {
        return nil;
    }
    LWTextContainer* textContainer = [LWTextContainer lw_textContainerWithSize:self.frame.size];
    LWTextLayout* textLayout = [LWTextLayout lw_layoutWithContainer:textContainer text:self.attributedText];
    return textLayout;
}


@end
