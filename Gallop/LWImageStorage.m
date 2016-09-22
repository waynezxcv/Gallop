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
#import <objc/runtime.h>
#import "GallopDefine.h"
#import "LWTransaction.h"
#import "CALayer+LWTransaction.h"
#import "LWAsyncDisplayLayer.h"
#import "UIImage+Gallop.h"



@interface LWImageStorage()
@property (nonatomic,assign) BOOL needRerendering;

@end



static CGSize _LWSizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize) {
    CGFloat destinationAspectRatio = destinationSize.width / destinationSize.height;
    if (sizeToScaleAspectRatio > destinationAspectRatio) {
        return CGSizeMake(destinationSize.height * sizeToScaleAspectRatio, destinationSize.height);
    } else {
        return CGSizeMake(destinationSize.width, floorf(destinationSize.width / sizeToScaleAspectRatio));
    }
}

static CGSize _LWSSizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints) {
    CGFloat constraintAspectRatio = constraints.width / constraints.height;
    if (aspectRatio > constraintAspectRatio) {
        return CGSizeMake(constraints.width, constraints.width / aspectRatio);
    } else {
        return CGSizeMake(constraints.height * aspectRatio, constraints.height);
    }
}

static void _LWCroppedImageBackingSizeAndDrawRectInBounds(CGSize sourceImageSize,
                                                          CGSize boundsSize,
                                                          UIViewContentMode contentMode,
                                                          CGRect cropRect,
                                                          BOOL forceUpscaling,
                                                          CGSize *outBackingSize,
                                                          CGRect *outDrawRect) {
    size_t destinationWidth = boundsSize.width;
    size_t destinationHeight = boundsSize.height;
    CGFloat boundsAspectRatio = (float)destinationWidth / (float)destinationHeight;

    CGSize scaledSizeForImage = sourceImageSize;
    BOOL cropToRectDimensions = !CGRectIsEmpty(cropRect);

    if (cropToRectDimensions) {
        scaledSizeForImage = CGSizeMake(boundsSize.width / cropRect.size.width, boundsSize.height / cropRect.size.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill)
            scaledSizeForImage = _LWSizeFillWithAspectRatio(boundsAspectRatio, sourceImageSize);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForImage = _LWSSizeFitWithAspectRatio(boundsAspectRatio, sourceImageSize);
    }
    if (forceUpscaling == NO && (scaledSizeForImage.width * scaledSizeForImage.height) < (destinationWidth * destinationHeight)) {
        destinationWidth = (size_t)roundf(scaledSizeForImage.width);
        destinationHeight = (size_t)roundf(scaledSizeForImage.height);
        if (destinationWidth == 0 || destinationHeight == 0) {
            *outBackingSize = CGSizeZero;
            *outDrawRect = CGRectZero;
            return;
        }
    }
    CGFloat sourceImageAspectRatio = sourceImageSize.width / sourceImageSize.height;
    CGSize scaledSizeForDestination = CGSizeMake(destinationWidth, destinationHeight);
    if (cropToRectDimensions) {
        scaledSizeForDestination = CGSizeMake(boundsSize.width / cropRect.size.width, boundsSize.height / cropRect.size.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill)
            scaledSizeForDestination = _LWSizeFillWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForDestination = _LWSSizeFitWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
    }
    CGRect drawRect = CGRectZero;
    if (cropToRectDimensions) {
        drawRect = CGRectMake(-cropRect.origin.x * scaledSizeForDestination.width,
                              -cropRect.origin.y * scaledSizeForDestination.height,
                              scaledSizeForDestination.width,
                              scaledSizeForDestination.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill) {
            drawRect = CGRectMake(((destinationWidth - scaledSizeForDestination.width) * cropRect.origin.x),
                                  ((destinationHeight - scaledSizeForDestination.height) * cropRect.origin.y),
                                  scaledSizeForDestination.width,
                                  scaledSizeForDestination.height);

        } else {
            drawRect = CGRectMake(((destinationWidth - scaledSizeForDestination.width) / 2.0),
                                  ((destinationHeight - scaledSizeForDestination.height) / 2.0),
                                  scaledSizeForDestination.width,
                                  scaledSizeForDestination.height);
        }
    }
    *outDrawRect = drawRect;
    *outBackingSize = CGSizeMake(destinationWidth, destinationHeight);
}


@implementation LWImageStorage

@synthesize cornerRadius = _cornerRadius;
@synthesize cornerBorderWidth = _cornerBorderWidth;

#pragma mark - LifeCycle

- (id)init {
    self = [super init];
    if (self) {
        self.contents = nil;
        self.userInteractionEnabled = YES;
        self.placeholder = nil;
        self.fadeShow = YES;
        self.clipsToBounds = NO;
        self.contentsScale = [GallopUtils contentsScale];
        self.needRerendering = NO;
        self.needResize = NO;
        self.localImageType = LWLocalImageDrawInLWAsyncDisplayView;
        self.isBlur = NO;
    }
    return self;
}

- (BOOL)needRerendering {
    if (self.cornerBorderWidth != 0 || self.cornerRadius != 0) {
        return YES;
    }
    else {
        return _needRerendering;
    }
}

#pragma mark - Methods

- (void)stretchableImageWithLeftCapWidth:(CGFloat)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    if ([self.contents isKindOfClass:[UIImage class]] &&
        self.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {
        self.contents = [(UIImage *)self.contents stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
}

- (void)lw_drawInContext:(CGContextRef)context isCancelled:(LWAsyncDisplayIsCanclledBlock)isCancelld {
    if (isCancelld()) {
        return;
    }
    if ([self.contents isKindOfClass:[NSURL class]]) {
        return;
    }
    if ([self.contents isKindOfClass:[UIImage class]] &&
        self.localImageType == LWLocalImageDrawInLWAsyncDisplayView) {

        UIImage* image = (UIImage *)self.contents;
        BOOL isOpaque = self.opaque;
        UIColor* backgroundColor = self.backgroundColor;
        CGRect imageDrawRect = self.frame;
        CGFloat cornerRaiuds = self.cornerRadius;
        UIColor* cornerBackgroundColor = self.cornerBackgroundColor;
        UIColor* cornerBorderColor = self.cornerBorderColor;
        CGFloat cornerBorderWidth = self.cornerBorderWidth;
        if (!image) {
            return;
        }

        if (self.isBlur) {
            image = [image lw_applyBlurWithRadius:20
                                        tintColor:RGB(0, 0, 0, 0.15f)
                            saturationDeltaFactor:1.4
                                        maskImage:nil];
        }

        CGContextSaveGState(context);
        if (isOpaque && backgroundColor) {
            [backgroundColor setFill];
            UIRectFill(imageDrawRect);
        }
        UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:imageDrawRect
                                                              cornerRadius:cornerRaiuds];
        UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:imageDrawRect];
        if (cornerBackgroundColor) {
            [cornerBackgroundColor setFill];
            [backgroundRect fill];
        }
        [cornerPath addClip];
        [image drawInRect:imageDrawRect];
        CGContextRestoreGState(context);
        if (cornerBorderColor && cornerBorderWidth != 0) {
            [cornerPath setLineWidth:cornerBorderWidth];
            [cornerBorderColor setStroke];
            [cornerPath stroke];
        }
    }
}

@end

static const void* reuseIdentifierKey;
static const void* URLKey;

@implementation UIView (LWImageStorage)

- (NSString *)identifier {
    return objc_getAssociatedObject(self, &reuseIdentifierKey);
}

- (void)setIdentifier:(NSString *)identifier {
    objc_setAssociatedObject(self, &reuseIdentifierKey, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURL *)URL {
    return objc_getAssociatedObject(self, &URLKey);
}

- (void)setURL:(NSURL *)URL {
    objc_setAssociatedObject(self, &URLKey, URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContentWithImageStorage:(LWImageStorage *)imageStorage
                       resizeBlock:(void(^)(LWImageStorage*imageStorage, CGFloat delta))resizeBlock {

    if ([imageStorage.contents isKindOfClass:[UIImage class]]) {
        switch (imageStorage.localImageType) {
            case LWLocalImageDrawInLWAsyncDisplayView: {
                return;
            }
            case LWLocalImageTypeDrawInSubView: {
                UIImage* image = (UIImage *)imageStorage.contents;
                self.backgroundColor = imageStorage.backgroundColor;
                self.clipsToBounds = imageStorage.clipsToBounds;
                if (!imageStorage.needResize) {
                    [self layoutWithStorage:imageStorage];
                } else {
                    CGSize imageSize = image.size;
                    CGFloat imageScale = imageSize.height/imageSize.width;
                    CGSize reSize = CGSizeMake(imageStorage.bounds.size.width,
                                               imageStorage.bounds.size.width * imageScale);
                    CGFloat delta = reSize.height - imageStorage.frame.size.height;
                    imageStorage.frame = CGRectMake(imageStorage.frame.origin.x,
                                                    imageStorage.frame.origin.y,
                                                    imageStorage.frame.size.width,
                                                    imageStorage.frame.size.height + delta);
                    [self layoutWithStorage:imageStorage];
                    resizeBlock(imageStorage,delta);
                }
                __weak typeof(self)weakSelf = self;
                [self _setContentsImage:image
                           imageStorage:imageStorage
                             completion:^{
                                 __strong typeof(weakSelf) swself = weakSelf;
                                 if (imageStorage.fadeShow) {
                                     [swself fadeShowAnimation];
                                 }
                             }];
                return;
            }
        }
    }

    if ([imageStorage.contents isKindOfClass:[NSString class]]) {
        imageStorage.contents = [NSURL URLWithString:imageStorage.contents];
    }

    if ([[(NSURL *)imageStorage.contents absoluteString] isEqualToString:self.URL.absoluteString]) {
        return;
    }

    self.URL = imageStorage.contents;
    self.backgroundColor = imageStorage.backgroundColor;
    self.clipsToBounds = imageStorage.clipsToBounds;
    if (!imageStorage.needResize) {
        [self layoutWithStorage:imageStorage];
    }
    __weak typeof(self) weakSelf = self;
    [self.layer lw_setImageWithURL:(NSURL *)imageStorage.contents
                  placeholderImage:imageStorage.placeholder
                      cornerRadius:imageStorage.cornerRadius
             cornerBackgroundColor:imageStorage.cornerBackgroundColor
                       borderColor:imageStorage.cornerBorderColor
                       borderWidth:imageStorage.cornerBorderWidth
                              size:imageStorage.frame.size
                            isBlur:imageStorage.isBlur
                           options:SDWebImageAvoidAutoSetImage
                          progress:nil
                         completed:^(UIImage *image,
                                     NSError *error,
                                     SDImageCacheType cacheType,
                                     NSURL *imageURL) {
                             if (!image) {
                                 return ;
                             }
                             if (imageStorage.needResize) {
                                 CGSize imageSize = image.size;
                                 CGFloat imageScale = imageSize.height/imageSize.width;
                                 CGSize reSize = CGSizeMake(imageStorage.bounds.size.width,
                                                            imageStorage.bounds.size.width * imageScale);
                                 CGFloat delta = reSize.height - imageStorage.frame.size.height;
                                 imageStorage.frame = CGRectMake(imageStorage.frame.origin.x,
                                                                 imageStorage.frame.origin.y,
                                                                 imageStorage.frame.size.width,
                                                                 imageStorage.frame.size.height + delta);
                                 [self layoutWithStorage:imageStorage];
                                 resizeBlock(imageStorage,delta);
                             }
                             [weakSelf _setContentsImage:image
                                            imageStorage:imageStorage
                                              completion:^{
                                                  if (imageStorage.fadeShow) {
                                                      [weakSelf fadeShowAnimation];
                                                  }
                                              }];
                         }];
}

- (void)_setContentsImage:(UIImage *)image
             imageStorage:(LWImageStorage *)imageStorage
               completion:(void(^)())completion {
    if (!image || !imageStorage) {
        return;
    }
    int width = imageStorage.frame.size.width;
    int height = imageStorage.frame.size.height;
    CGFloat scale = (height / width) / (self.bounds.size.height / self.bounds.size.width);
    if (scale < 0.99 || isnan(scale)) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
    } else {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
    }


    if (imageStorage.isBlur && [imageStorage.contents isKindOfClass:[UIImage class]]) {

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage* blurImage = [image lw_applyBlurWithRadius:20
                                                     tintColor:RGB(0, 0, 0, 0.15f)
                                         saturationDeltaFactor:1.4
                                                     maskImage:nil];

            dispatch_async(dispatch_get_main_queue(), ^{

                LWTransaction* layerAsyncTransaction = self.layer.lw_asyncTransaction;
                [layerAsyncTransaction
                 addAsyncOperationWithTarget:self.layer
                 selector:@selector(setContents:)
                 object:(__bridge id _Nullable)blurImage.CGImage
                 completion:^(BOOL canceled) {
                     completion();
                 }];

            });
        });

    } else {
        LWTransaction* layerAsyncTransaction = self.layer.lw_asyncTransaction;
        [layerAsyncTransaction
         addAsyncOperationWithTarget:self.layer
         selector:@selector(setContents:)
         object:(__bridge id _Nullable)image.CGImage
         completion:^(BOOL canceled) {
             completion();
         }];
    }
}

- (void)_rerenderingImage:(UIImage *)image
             imageStorage:(LWImageStorage *)imageStorage
               completion:(void(^)())compeltion {
    if (!image || !imageStorage) {
        return;
    }
    @autoreleasepool {
        BOOL forceUpscaling = NO;
        BOOL cropEnabled = YES;
        BOOL isOpaque = imageStorage.opaque;
        UIColor* backgroundColor = imageStorage.backgroundColor;
        UIViewContentMode contentMode = imageStorage.contentMode;
        CGFloat contentsScale = imageStorage.contentsScale;
        CGRect cropDisplayBounds = CGRectZero;
        CGRect cropRect = CGRectMake(0.5, 0.5, 0, 0);
        BOOL hasValidCropBounds = cropEnabled && !CGRectIsNull(cropDisplayBounds) && !CGRectIsEmpty(cropDisplayBounds);
        CGRect bounds = (hasValidCropBounds ? cropDisplayBounds : imageStorage.bounds);
        CGSize imageSize = image.size;
        CGSize imageSizeInPixels = CGSizeMake(imageSize.width * image.scale, imageSize.height * image.scale);
        CGSize boundsSizeInPixels = CGSizeMake(floorf(bounds.size.width * contentsScale), floorf(bounds.size.height * contentsScale));
        BOOL contentModeSupported = contentMode == UIViewContentModeScaleAspectFill ||
        contentMode == UIViewContentModeScaleAspectFit ||
        contentMode == UIViewContentModeCenter;
        CGSize backingSize   = CGSizeZero;
        CGRect imageDrawRect = CGRectZero;
        CGFloat cornerRadius = imageStorage.cornerRadius;
        UIColor* cornerBackgroundColor = imageStorage.cornerBackgroundColor;
        UIColor* cornerBorderColor = imageStorage.cornerBorderColor;
        CGFloat cornerBorderWidth = imageStorage.cornerBorderWidth;
        if (boundsSizeInPixels.width * contentsScale < 1.0f || boundsSizeInPixels.height * contentsScale < 1.0f ||
            imageSizeInPixels.width < 1.0f                  || imageSizeInPixels.height < 1.0f) {
            return;
        }
        if (!cropEnabled || !contentModeSupported) {
            backingSize = imageSizeInPixels;
            imageDrawRect = (CGRect){.size = backingSize};
        }
        else {
            _LWCroppedImageBackingSizeAndDrawRectInBounds(imageSizeInPixels,
                                                          boundsSizeInPixels,
                                                          contentMode,
                                                          cropRect,
                                                          forceUpscaling,
                                                          &backingSize,
                                                          &imageDrawRect);
        }
        if (backingSize.width <= 0.0f || backingSize.height <= 0.0f ||
            imageDrawRect.size.width <= 0.0f || imageDrawRect.size.height <= 0.0f) {
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIGraphicsBeginImageContextWithOptions(backingSize,isOpaque,contentsScale);
            if (nil == UIGraphicsGetCurrentContext()) {
                return;
            }
            if (isOpaque && backgroundColor) {
                [backgroundColor setFill];
                UIRectFill(CGRectMake(0, 0, backingSize.width, backingSize.height));
            }

            UIBezierPath* cornerPath = [UIBezierPath bezierPathWithRoundedRect:imageDrawRect
                                                                  cornerRadius:cornerRadius * contentsScale];

            UIBezierPath* backgroundRect = [UIBezierPath bezierPathWithRect:imageDrawRect];
            if (cornerBackgroundColor) {
                [cornerBackgroundColor setFill];
            }
            [backgroundRect fill];
            [cornerPath addClip];
            [image drawInRect:imageDrawRect];
            if (cornerBorderColor) {
                [cornerBorderColor setStroke];
            }
            [cornerPath stroke];
            [cornerPath setLineWidth:cornerBorderWidth];

            CGImageRef processedImageRef = (UIGraphicsGetImageFromCurrentImageContext().CGImage);
            UIGraphicsEndImageContext();
            dispatch_sync(dispatch_get_main_queue(), ^{
                LWTransaction* layerAsyncTransaction = self.layer.lw_asyncTransaction;
                [layerAsyncTransaction
                 addAsyncOperationWithTarget:self.layer
                 selector:@selector(setContents:)
                 object:(__bridge id _Nullable)processedImageRef
                 completion:^(BOOL canceled) {
                     compeltion();
                 }];
            });
        });
    }
}

- (void)layoutWithStorage:(LWImageStorage *)imageStorage {
    if (!CGRectEqualToRect(self.frame, imageStorage.frame)) {
        self.frame = imageStorage.frame;
    }
    self.hidden = NO;
}

- (void)cleanup {
    CGImageRef imageRef = (__bridge_retained CGImageRef)(self.layer.contents);
    id contents = self.layer.contents;
    NSURL* URL = self.URL;
    self.layer.contents = nil;
    self.URL = nil;
    if (imageRef) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [contents class];
            [URL class];
            CFRelease(imageRef);
        });
    }
    self.hidden = YES;
}

- (void)fadeShowAnimation {
    [self.layer removeAnimationForKey:@"fadeshowAnimation"];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.15;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"fadeshowAnimation"];
}

@end



