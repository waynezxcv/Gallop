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




@implementation LWAsyncImageView (Display)


- (void)lw_setImageWihtImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    if ([imageStorage.contents isKindOfClass:[UIImage class]]) {
        [self _setLocalImageWithImageStorage:imageStorage resize:resizeBlock completion:completion];
    } else {
        [self _setWebImageWithImageStorage:imageStorage resize:resizeBlock completion:completion];
    }
}


- (void)_setLocalImageWithImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    UIImage* image = (UIImage *)imageStorage.contents;
    if (imageStorage.isBlur) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage* blurImage = [image lw_applyBlurWithRadius:20
                                                     tintColor:RGB(0, 0, 0, 0.15f)
                                         saturationDeltaFactor:1.4
                                                     maskImage:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = blurImage;
                resizeBlock(imageStorage,0);
                completion();
            });
        });
    } else {
        self.image = image;
        resizeBlock(imageStorage,0);
        completion();
    }
}

- (void)_setWebImageWithImageStorage:(LWImageStorage *)imageStorage resize:(LWHTMLImageResizeBlock)resizeBlock completion:(LWAsyncCompleteBlock)completion {
    NSURL* url;
    UIImage* placeholder = imageStorage.placeholder;
    BOOL needResize = imageStorage.needResize;
    CGFloat cornerRaiuds = imageStorage.cornerRadius;
    UIColor* cornerBgColor = imageStorage.cornerBackgroundColor;
    UIColor* borderColor = imageStorage.cornerBackgroundColor;
    CGFloat borderWidth = imageStorage.cornerBorderWidth;
    CGSize imageSize = imageStorage.frame.size;
    UIViewContentMode contentMode = imageStorage.contentMode;
    BOOL isBlur = imageStorage.isBlur;
    
    if ([imageStorage.contents isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:imageStorage.contents];
    } else if ([imageStorage.contents isKindOfClass:[NSURL class]]) {
        url = (NSURL *)imageStorage.contents;
    } else {
        resizeBlock(imageStorage,0);
        completion();
        return;
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
                          options:0
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
