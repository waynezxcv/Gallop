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

#import "LWStorage.h"
#import "GallopUtils.h"
#import <objc/runtime.h>
#import "GallopUtils.h"


@implementation LWStorage


#pragma mark - Init
- (id)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.opaque = YES;
        self.hidden = NO;
        self.alpha = 1.0f;
        self.frame = CGRectZero;
        self.bounds = CGRectZero;
        self.cornerRadius = 0.0f;
        self.cornerBackgroundColor = [UIColor whiteColor];
        self.cornerBorderColor = [UIColor whiteColor];
        self.cornerBorderWidth = 0.0f;
        self.shadowColor = nil;
        self.shadowOpacity = 0.0f;
        self.shadowOffset = CGSizeZero;
        self.shadowRadius = 0.0f;
        self.contentsScale = [GallopUtils contentsScale];
        self.backgroundColor = [UIColor whiteColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()



#pragma mark - Getter & Setter
- (CGRect)bounds {
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return  self.frame.origin.x + self.width;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.height;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGPoint)center {
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5f,
                       self.frame.origin.y + self.frame.size.height * 0.5f);
}

- (void)setCenter:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5f;
    frame.origin.y = center.y - frame.size.height * 0.5f;
    self.frame = frame;
}

- (void)setBounds:(CGRect)bounds {
    CGRect frame = self.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width, bounds.size.height);
    self.frame = frame;
}

@end
