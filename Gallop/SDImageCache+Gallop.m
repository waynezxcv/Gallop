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



#import "SDImageCache+Gallop.h"
#import "LWImageProcessor.h"
#import <objc/runtime.h>

@implementation SDImageCache (Gallop)


/**
 *  替换SDImageCache的“storeImage:imageData:forKey:toDisk:completion:”方法。
 *  对圆角图片和模糊图片处理之后再缓存。
 */

+ (void)load {
    [super load];
    Method originMethod = class_getInstanceMethod([self class],
                                                  NSSelectorFromString(@"storeImage:imageData:forKey:toDisk:completion:"));
    
    Method newMethod = class_getInstanceMethod([self class],
                                               NSSelectorFromString(@"lw_storeImage:imageData:forKey:toDisk:completion:"));
    
    if (!class_addMethod([self class],
                         @selector(lw_storeImage:imageData:forKey:toDisk:completion:),
                         method_getImplementation(newMethod),
                         method_getTypeEncoding(newMethod))) {
        
        method_exchangeImplementations(newMethod, originMethod);
    }
}

- (void)lw_storeImage:(nullable UIImage *)image
            imageData:(nullable NSData *)imageData
               forKey:(nullable NSString *)key
               toDisk:(BOOL)toDisk
           completion:(nullable SDWebImageNoParamsBlock)completionBlock {
    
    //根据从key中取出相关绘制信息，处理图片，然后将处理完的图片缓存
    image = [LWImageProcessor lw_cornerRadiusImageWithImage:image withKey:key];
    if (key && [key hasPrefix:[NSString stringWithFormat:@"%@",kLWImageProcessorPrefixKey]]) {
        if (image) {
            imageData = UIImagePNGRepresentation(image);
        }
    }
    [self lw_storeImage:image imageData:imageData forKey:key toDisk:toDisk completion:completionBlock];
}


@end
