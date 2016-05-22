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



#import "LWImageStorage.h"
#import "CALayer+WebCache.h"
#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"
#import "UIImageView+WebCache.h"


@implementation LWImageStorage

- (id)init {
    self = [super init];
    if (self) {
        self.type = LWImageStorageWebImage;
        self.image = nil;
        self.URL = nil;
        self.frame = CGRectZero;
        self.contentMode = kCAGravityResizeAspect;
        self.masksToBounds = YES;
        self.placeholder = nil;
        self.fadeShow = NO;
        self.cornerRadius = 0.0f;
        self.cornerBackgroundColor = [UIColor whiteColor];
        self.cornerBorderWidth = 0.0f;
        self.cornerBorderColor = [UIColor whiteColor];
    }
    return self;
}

- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    self.image = [self.image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}


@end

@implementation LWImageContainer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage {
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:imageStorage.URL
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       if (image) {
                           [weakSelf layoutWithStorage:imageStorage];
                       }
                   }];
}


- (void)layoutWithStorage:(LWImageStorage *)imageStorage {
    self.frame = imageStorage.frame;
    self.hidden = NO;
}

- (void)cleanup {
    self.hidden = YES;
}

@end