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
#import "LWRunLoopTransactions.h"
#import "CALayer+WebCache.h"
#import <objc/runtime.h>
#import "GallopUtils.h"

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
    if ([self.contents isKindOfClass:[NSURL class]]) {
        return;
    }
    if ([self.contents isKindOfClass:[UIImage class]]) {
        CGContextSaveGState(context);
        if (self.cornerRadius != 0) {
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
        else {
            [self.contents drawInRect:self.frame];
        }
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

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()


@end

@implementation UIView (LWImageStorage)

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage {
    if ([imageStorage.contents isKindOfClass:[UIImage class]]) {
        return;
    }
    if ([imageStorage.contents isKindOfClass:[NSString class]]) {
        imageStorage.contents = [NSURL URLWithString:imageStorage.contents];
    }
    [self layoutWithStorage:imageStorage];
    [self.layer removeAnimationForKey:@"fadeshowAnimation"];
    __weak typeof(self) weakSelf = self;
    [self.layer sd_setImageWithURL:(NSURL *)imageStorage.contents
                  placeholderImage:imageStorage.placeholder
                           options:SDWebImageAvoidAutoSetImage
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             if (image) {
                                 int width = imageStorage.frame.size.width;
                                 int height = imageStorage.frame.size.height;
                                 CGFloat scale = (height / width) / (strongSelf.bounds.size.height / strongSelf.bounds.size.width);
                                 if (scale < 0.99 || isnan(scale)) {
                                     strongSelf.contentMode = UIViewContentModeScaleAspectFill;
                                     strongSelf.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                                 } else {
                                     strongSelf.contentMode = UIViewContentModeScaleAspectFill;
                                     strongSelf.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                                 }
                                 if (imageStorage.cornerRadius != 0) {
                                     CGFloat scale = [GallopUtils contentsScale];
                                     CGSize size = imageStorage.frame.size;
                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                         UIGraphicsBeginImageContextWithOptions(size,YES,scale);
                                         if (nil == UIGraphicsGetCurrentContext()) {
                                             return;
                                         }
                                         UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                                                               cornerRadius:imageStorage.cornerRadius];
                                         UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
                                         if (imageStorage.cornerBackgroundColor) {
                                             [imageStorage.cornerBackgroundColor setFill];
                                         }
                                         [backgroundRect fill];
                                         [cornerPath addClip];
                                         [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                                         if (imageStorage.cornerBorderColor) {
                                             [imageStorage.cornerBorderColor setStroke];
                                         }
                                         [cornerPath stroke];
                                         [cornerPath setLineWidth:imageStorage.cornerBorderWidth];
                                         id processedImageRef = (__bridge id _Nullable)(UIGraphicsGetImageFromCurrentImageContext().CGImage);
                                         UIGraphicsEndImageContext();
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             strongSelf.layer.contents = processedImageRef;
                                         });
                                     });
                                 } else {
                                     strongSelf.layer.contents = (__bridge id _Nullable)(image.CGImage);
                                 }
                                 if (imageStorage.fadeShow) {
                                     CATransition* transition = [CATransition animation];
                                     transition.duration = 0.15;
                                     transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                                     transition.type = kCATransitionFade;
                                     [strongSelf.layer addAnimation:transition forKey:@"fadeshowAnimation"];
                                 }
                             }
                         }];
}

- (void)layoutWithStorage:(LWImageStorage *)imageStorage {
    self.frame = imageStorage.frame;
    self.hidden = NO;
}

- (void)cleanup {
    self.layer.contents = nil;
    self.hidden = YES;
}

@end