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

#import <UIKit/UIKit.h>

static const NSString* kLWImageProcessorPrefixKey = @"kLWImageProcessorPrefixKey";

/**
 *  这个类用于处理图片，生成缓存的key
 */

@interface LWImageProcessor : NSObject


/**
 *  将绘制圆角半径图片信息保存到key中
 *
 *  @param url          图片的URL
 *  @param cornerRadius 圆角半径值
 *  @param size         图片的大小
 *
 *  @return 包含了用于绘制圆角半径图片信息的字符串
 */
+ (NSString *)lw_imageTransformCacheKeyForURL:(NSURL *)url
                                 cornerRadius:(CGFloat)cornerRadius
                                         size:(CGSize)size
                        cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                                  borderColor:(UIColor *)borderColor
                                  borderWidth:(CGFloat)borderWidth
                                  contentMode:(UIViewContentMode)contentMode
                                       isBlur:(BOOL)isBlu;

/**
 *  通过Key来返回一个圆角半径图片
 *
 *  @param image 原始图片
 *  @param key   包含了用于绘制圆角半径图片信息的字符串
 *
 *  @return 经过圆角半径绘制后的图片
 */
+ (UIImage *)lw_cornerRadiusImageWithImage:(UIImage*)image withKey:(NSString *)key;

@end
