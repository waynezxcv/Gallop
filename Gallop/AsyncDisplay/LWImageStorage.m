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
#import "UIImageView+WebCache.h"
#import "CALayer+GallopAddtions.h"
#import "LWRunLoopTransactions.h"

@implementation LWImageStorage

#pragma mark - Methods

- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    if ([self.contents isKindOfClass:[UIImage class]]) {
        self.contents = [(UIImage *)self.contents stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
}

/*** 绘制 ***/
- (void)lw_drawInContext:(CGContextRef)context isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    if (isCancelld()) {
        return;
    }
    if ([self.contents isKindOfClass:[UIImage class]]) {
        CGContextSaveGState(context);
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.frame
                                                              cornerRadius:self.cornerRadius];
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:self.frame];
        [self.cornerBackgroundColor setFill];
        [backgroundRect fill];
        [cornerPath addClip];
        [self.contents drawInRect:self.frame];
        [self.cornerBorderColor setStroke];
        [cornerPath stroke];
        [cornerPath setLineWidth:self.cornerBorderWidth];
        CGContextRestoreGState(context);
    }
}

#pragma mark - LifeCycle
- (id)init {
    self = [super init];
    if (self) {
        self.contents = nil;
        self.userInteractionEnabled = YES;
        self.placeholder = nil;
        self.fadeShow = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    LWImageStorage* imamgeStorage = [super copyWithZone:zone];
    imamgeStorage.contents = [self.contents copy];
    imamgeStorage.placeholder = [self.placeholder copy];
    imamgeStorage.fadeShow = self.fadeShow;
    imamgeStorage.userInteractionEnabled = self.userInteractionEnabled;
    return imamgeStorage;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end


@implementation UIImageView (LWImageStorage)

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage {
    self.clipsToBounds = imageStorage.clipsToBounds;
    self.contentMode = imageStorage.contentMode;
    self.userInteractionEnabled = imageStorage.userInteractionEnabled;
    if (imageStorage.placeholder) {
        self.image = imageStorage.placeholder;
    }
    if ([imageStorage.contents isKindOfClass:[NSURL class]]) {
        __weak typeof(self) weakSelf = self;
        [self sd_setImageWithURL:(NSURL *)imageStorage.contents
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           if (image) {
                               [weakSelf layoutWithStorage:imageStorage];
                           }
                       }];
    }
}


- (void)layoutWithStorage:(LWImageStorage *)imageStorage {
    self.frame = imageStorage.frame;
    self.hidden = NO;
}

- (void)cleanup {
    self.image = nil;
    self.hidden = YES;
}

@end