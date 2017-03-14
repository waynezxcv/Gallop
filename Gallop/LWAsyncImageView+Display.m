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


#import "LWAsyncImageView+Display.h"
#import "LWAsyncImageView+WebCache.h"
#import "CALayer+LWTransaction.h"
#import "UIImage+Gallop.h"



static CGSize _sizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints);
static CGSize _sizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize);
static void _croppedImageBackingSizeAndDrawRectInBounds(CGSize sourceImageSize,CGSize boundsSize,UIViewContentMode contentMode,CGRect cropRect,BOOL forceUpscaling,CGSize* outBackingSize,CGRect* outDrawRect);



@implementation LWAsyncImageView (Display)


- (void)lw_setImageWihtImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    
    if ([imageStorage.contents isKindOfClass:[UIImage class]]) {
        [self _setLocalImageWithImageStorage:imageStorage resize:resizeBlock completion:completion];
    } else {
        [self _setWebImageWithImageStorage:imageStorage resize:resizeBlock completion:completion];
    }
}

- (void)_setLocalImageWithImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    if (imageStorage.needRerendering) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage* processedImage = [self _reRenderingImageWitImageStorage:imageStorage];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = processedImage;
                if (resizeBlock) {
                    resizeBlock(imageStorage,0);
                }
                if (completion) {
                    completion();
                }
            });
        });
        
    } else {
        UIImage* image = (UIImage *)imageStorage.contents;
        self.image = image;
        if (resizeBlock) {
            resizeBlock(imageStorage,0);
        }
        if (completion) {
            completion();
        }
    }
}

- (UIImage *)_reRenderingImageWitImageStorage:(LWImageStorage *)imageStorage {
    
    UIImage* image = (UIImage *)imageStorage.contents;
    if (!image) {
        return nil;
    }
    
    @autoreleasepool {
        
        if (imageStorage.isBlur) {
            image = [image lw_applyBlurWithRadius:20
                                        tintColor:RGB(0, 0, 0, 0.15f)
                            saturationDeltaFactor:1.4
                                        maskImage:nil];
        }
        
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
            return nil;
        }
        
        if (!cropEnabled || !contentModeSupported) {
            backingSize = imageSizeInPixels;
            imageDrawRect = (CGRect){.size = backingSize};
            
        } else {
            _croppedImageBackingSizeAndDrawRectInBounds(imageSizeInPixels,
                                                        boundsSizeInPixels,
                                                        contentMode,
                                                        cropRect,
                                                        forceUpscaling,
                                                        &backingSize,
                                                        &imageDrawRect);
        }
        if (backingSize.width <= 0.0f || backingSize.height <= 0.0f ||
            imageDrawRect.size.width <= 0.0f || imageDrawRect.size.height <= 0.0f) {
            return nil;
        }
        
        UIGraphicsBeginImageContextWithOptions(backingSize,isOpaque,contentsScale);
        if (nil == UIGraphicsGetCurrentContext()) {
            return nil;
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
        return [UIImage imageWithCGImage:processedImageRef];
    }
}

- (void)_setWebImageWithImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    
    NSURL* url;
    id placeholder = imageStorage.placeholder;
    BOOL needResize = imageStorage.needResize;
    CGFloat cornerRaiuds = imageStorage.cornerRadius;
    UIColor* cornerBgColor = imageStorage.cornerBackgroundColor;
    UIColor* borderColor = imageStorage.cornerBorderColor;
    CGFloat borderWidth = imageStorage.cornerBorderWidth;
    CGSize imageSize = imageStorage.frame.size;
    UIViewContentMode contentMode = imageStorage.contentMode;
    BOOL isBlur = imageStorage.isBlur;
    BOOL isFadeShow = imageStorage.isFadeShow;
    
    if (isFadeShow) {
        [self.layer removeAnimationForKey:@"fadeshowAnimation"];
    }
    
    if ([imageStorage.contents isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:imageStorage.contents];
    } else if ([imageStorage.contents isKindOfClass:[NSURL class]]) {
        url = (NSURL *)imageStorage.contents;
    } else {
        resizeBlock(imageStorage,0);
        if (completion) {
            completion();
        }
        return;
    }
    
    SDWebImageOptions options = 0;
    
    if ([[url.absoluteString lowercaseString] hasSuffix:@".gif"]) {
        options |= SDWebImageProgressiveDownload;
    }
    
    __weak typeof(self) weakSelf = self;
    [self lw_asyncSetImageWithURL:url
                 placeholderImage:placeholder
                     cornerRadius:cornerRaiuds
            cornerBackgroundColor:cornerBgColor
                      borderColor:borderColor
                      borderWidth:borderWidth
                             size:imageSize
                      contentMode:contentMode
                           isBlur:isBlur
                          options:options
                         progress:^(NSInteger receivedSize,
                                    NSInteger expectedSize,
                                    NSURL *targetURL) {
                         } completed:^(UIImage* image,
                                       NSData* data,
                                       NSError* error) {
                             
                             if (!image) {
                                 if (completion) {
                                     completion();
                                 }
                                 return ;
                             }
                             
                             //LWHTMLDisplayView会根据图片大小自适应，这里根据图片的宽高比例计算出高度需要调整的差值delta
                             __strong typeof(weakSelf) sself = weakSelf;
                             if (needResize) {
                                 CGFloat delta = [sself _resizeImageStorage:imageStorage image:image];
                                 sself.frame = imageStorage.frame;
                                 resizeBlock(imageStorage,delta);
                             }
                             
                             if (isFadeShow) {
                                 
                                 [self.layer removeAnimationForKey:@"fadeshowAnimation"];
                                 CATransition* transition = [CATransition animation];
                                 transition.duration = 0.15;
                                 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                                 transition.type = kCATransitionFade;
                                 [self.layer addAnimation:transition forKey:@"fadeshowAnimation"];
                                 
                             }
                             
                             if (completion) {
                                 completion();
                             }
                         }];
}

- (CGFloat)_resizeImageStorage:(LWImageStorage *)imageStorage image:(UIImage *)image {
    CGSize imageSize = image.size;
    CGFloat imageScale = imageSize.height/imageSize.width;
    CGSize reSize = CGSizeMake(imageStorage.bounds.size.width,imageStorage.bounds.size.width * imageScale);
    CGFloat delta = reSize.height - imageStorage.frame.size.height;
    imageStorage.frame = CGRectMake(imageStorage.frame.origin.x,
                                    imageStorage.frame.origin.y,
                                    imageStorage.frame.size.width,
                                    imageStorage.frame.size.height + delta);
    return delta;
}


@end



static void _croppedImageBackingSizeAndDrawRectInBounds(CGSize sourceImageSize,
                                                        CGSize boundsSize,
                                                        UIViewContentMode contentMode,
                                                        CGRect cropRect,
                                                        BOOL forceUpscaling,
                                                        CGSize* outBackingSize,
                                                        CGRect* outDrawRect) {
    size_t destinationWidth = boundsSize.width;
    size_t destinationHeight = boundsSize.height;
    CGFloat boundsAspectRatio = (float)destinationWidth / (float)destinationHeight;
    
    CGSize scaledSizeForImage = sourceImageSize;
    BOOL cropToRectDimensions = !CGRectIsEmpty(cropRect);
    
    if (cropToRectDimensions) {
        scaledSizeForImage = CGSizeMake(boundsSize.width / cropRect.size.width, boundsSize.height / cropRect.size.height);
    } else {
        if (contentMode == UIViewContentModeScaleAspectFill)
            scaledSizeForImage = _sizeFillWithAspectRatio(boundsAspectRatio, sourceImageSize);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForImage = _sizeFitWithAspectRatio(boundsAspectRatio, sourceImageSize);
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
            scaledSizeForDestination = _sizeFillWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
        else if (contentMode == UIViewContentModeScaleAspectFit)
            scaledSizeForDestination = _sizeFitWithAspectRatio(sourceImageAspectRatio, scaledSizeForDestination);
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

static CGSize _sizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize) {
    CGFloat destinationAspectRatio = destinationSize.width / destinationSize.height;
    if (sizeToScaleAspectRatio > destinationAspectRatio) {
        return CGSizeMake(destinationSize.height * sizeToScaleAspectRatio, destinationSize.height);
    } else {
        return CGSizeMake(destinationSize.width, floorf(destinationSize.width / sizeToScaleAspectRatio));
    }
}

static CGSize _sizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints) {
    CGFloat constraintAspectRatio = constraints.width / constraints.height;
    if (aspectRatio > constraintAspectRatio) {
        return CGSizeMake(constraints.width, constraints.width / aspectRatio);
    } else {
        return CGSizeMake(constraints.height * aspectRatio, constraints.height);
    }
}

