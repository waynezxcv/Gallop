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


#import "UIImageView+GallopAddtions.h"
#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"
#import "LWRunLoopTransactions.h"
#import "GallopUtils.h"


static char imageURLKey;
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

@implementation UIImageView(GallopAddtions)

- (void)lw_setImageWithURL:(NSURL *)URL completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:URL completed:completedBlock];
}

- (void)lw_setImageWithImageStorage:(LWImageStorage *)imageStorage completed:(SDWebImageCompletionBlock)completedBlock {
    [self lw_setImageWithImageStorage:imageStorage placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)lw_setImageWithImageStorage:(LWImageStorage *)imageStorage placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSURL* url;
    if ([imageStorage.contents isKindOfClass:[NSURL class]]) {
        url = imageStorage.contents;
    }
    else {
        return;
    }
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    if (url) {
        // check if activityView is enabled or not
        if ([self showActivityIndicatorView]) {
            [self addActivityIndicator];
        }
        __weak __typeof(self)wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    if (imageStorage.cornerRadius != 0) {
                        CGFloat scale = [GallopUtils contentsScale];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIGraphicsBeginImageContextWithOptions(imageStorage.frame.size, YES, scale);
                            if (nil == UIGraphicsGetCurrentContext()) {
                                return;
                            }
                            UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,imageStorage.frame.size.width,imageStorage.frame.size.height)
                                                                                  cornerRadius:imageStorage.cornerRadius];
                            UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageStorage.frame.size.width, imageStorage.frame.size.height)];
                            [imageStorage.cornerBackgroundColor setFill];
                            [backgroundRect fill];
                            [cornerPath addClip];
                            [image drawInRect:CGRectMake(0, 0, imageStorage.frame.size.width, imageStorage.frame.size.height)];
                            [imageStorage.cornerBorderColor setStroke];
                            [cornerPath stroke];
                            [cornerPath setLineWidth:imageStorage.cornerBorderWidth];
                            UIImage* processedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            dispatch_async(dispatch_get_main_queue(), ^{
                                wself.image = processedImage;
                            });
                        });
                    }
                    else {
                        wself.image = image;
                    }
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:SDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)sd_cancelCurrentAnimationImagesLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

#pragma mark -
- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)setShowActivityIndicatorView:(BOOL)show{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, [NSNumber numberWithBool:show], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)showActivityIndicatorView{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

- (void)addActivityIndicator {
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self getIndicatorStyle]];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        dispatch_main_async_safe(^{
            [self addSubview:self.activityIndicator];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        });
    }

    dispatch_main_async_safe(^{
        [self.activityIndicator startAnimating];
    });

}

- (void)removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

- (void)delaySetImage:(UIImage *)image {
    LWRunLoopTransactions* transactions = [LWRunLoopTransactions
                                           transactionsWithTarget:self
                                           selector:@selector(setImage:)
                                           object:image];
    [transactions commit];
}

@end
