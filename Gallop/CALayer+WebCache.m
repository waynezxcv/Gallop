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




#import "CALayer+WebCache.h"
#import <objc/runtime.h>
#import "CALayer+WebCacheOperation.h"
#import "CALayer+LWTransaction.h"
#import "LWGIFImage.h"
#import "NSData+ImageContentType.h"






static char imageURLKey;

#define CALayerLoadKey @"CALayerLoadKey"


@implementation CALayer (WebCache)

- (void)lw_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
              cornerRadius:(CGFloat)cornerRadius
     cornerBackgroundColor:(UIColor *)cornerBackgroundColor
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
                      size:(CGSize)size
               contentMode:(UIViewContentMode)contentMode
                    isBlur:(BOOL)isBlur
                   options:(SDWebImageOptions)options
                  progress:(LWWebImageDownloaderProgressBlock)progressBlock
                 completed:(LWWebImageDownloaderCompletionBlock)completedBlock {
    
    [self lw_cancelCurrentImageLoad];
    
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //设置占位图
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            [self.lw_asyncTransaction addAsyncOperationWithTarget:self
                                                         selector:@selector(setContents:)
                                                           object:(__bridge id)placeholder.CGImage
                                                       completion:^(BOOL canceled) {}];
        });
    }
    //下载
    if (url) {
        __weak typeof(self) weakSelf = self;
        id <SDWebImageOperation> operation = [[SDWebImageManager sharedManager]
                                              lw_downloadImageWithURL:url
                                              cornerRadius:cornerRadius
                                              cornerBackgroundColor:cornerBackgroundColor
                                              borderColor:borderColor
                                              borderWidth:borderWidth
                                              size:size
                                              contentMode:contentMode
                                              isBlur:isBlur
                                              options:options
                                              progress:progressBlock
                                              completed:^(UIImage * _Nullable image,
                                                          NSData * _Nullable data,
                                                          NSError * _Nullable error,
                                                          SDImageCacheType cacheType,
                                                          BOOL finished,
                                                          NSURL * _Nullable imageURL) {
                                                  __strong typeof(weakSelf) sself = weakSelf;
                                                  if (!sself || !image) {
                                                      completedBlock(image,data,error);
                                                      return;
                                                  }
                                                  //CALayer不支持GIF显示，显示封面图
                                                  dispatch_main_async_safe(^{
                                                      if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock) {
                                                          completedBlock(image,data,error);
                                                          return ;
                                                          
                                                      } else if (image) {
                                                          [sself.lw_asyncTransaction addAsyncOperationWithTarget:self
                                                                                                        selector:@selector(setContents:)
                                                                                                          object:(__bridge id)image.CGImage
                                                                                                      completion:nil];
                                                          [sself setNeedsLayout];
                                                      } else {
                                                          if ((options & SDWebImageDelayPlaceholder)) {
                                                              [sself.lw_asyncTransaction addAsyncOperationWithTarget:self
                                                                                                            selector:@selector(setContents:)
                                                                                                              object:(__bridge id)placeholder.CGImage
                                                                                                          completion:nil];
                                                              [sself setNeedsLayout];
                                                          }
                                                      }
                                                      if (completedBlock && finished) {
                                                          completedBlock(image,data,error);
                                                      }
                                                  });
                                              }];
        
        //把operation设置到LWAsyncImageView的关联对象operationDictionary上，用于取消操作
        [self lw_setImageLoadOperation:operation forKey:CALayerLoadKey];
    } else {
        dispatch_main_async_safe(^{
            NSError* error = [NSError errorWithDomain:SDWebImageErrorDomain
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil,nil,error);
            }
        });
    }
    
}


- (NSURL *)lw_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}


- (void)lw_cancelCurrentImageLoad {
    [self lw_cancelImageLoadOperationWithKey:CALayerLoadKey];
}

@end
