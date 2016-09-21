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

#import <QuartzCore/QuartzCore.h>
#import "SDWebImageCompat.h"
#import "SDWebImageManager+Gallop.h"


@interface CALayer(WebCache)

/**
 *  通过URL设置一个CAlayer的图片，同时设置占位图、圆角半径相关属性
 *
 *  @param url            图片的URL
 *  @param placeholder    占位图
 *  @param cornerRadius   圆角半径值
 *  @param size           图片的大小
 *  @param options        图片设置选项
 *  @param progressBlock  一个下载进度回调Block
 *  @param completedBlock 一个下载完毕回调Block
 */
- (void)lw_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
              cornerRadius:(CGFloat)cornerRadius
                      size:(CGSize)size
                    isBlur:(BOOL)isBlur
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock;


/**
 *  通过URL设置一个CAlayer的图片，同时设置占位图、圆角半径相关属性
 *
 *  @param url                   图片的URL
 *  @param placeholder           占位图
 *  @param cornerRadius          圆角半径值
 *  @param cornerBackgroundColor 圆角背景颜色
 *  @param borderColor           圆角描边颜色
 *  @param borderWidth           圆角描边宽度
 *  @param size                  图片的大小
 *  @param options               图片设置选项
 *  @param progressBlock         一个下载进度回调Block
 *  @param completedBlock        一个下载完毕回调Block
 */
- (void)lw_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
              cornerRadius:(CGFloat)cornerRadius
     cornerBackgroundColor:(UIColor *)cornerBackgroundColor
               borderColor:(UIColor *)borderColor
               borderWidth:(CGFloat)borderWidth
                      size:(CGSize)size
                    isBlur:(BOOL)isBlur
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  获取当前图片的URL
 *
 */
- (NSURL *)sd_imageURL;

/**
 *  通过URL设置一个CALayer对象的图片
 *
 *  @param url 图片的URL
 */
- (void)sd_setImageWithURL:(NSURL *)url;

/**
 *  通过URL设置一个CALayer对象的图片，并设置一个占位图
 *
 *  @param url         图片的URL
 *  @param placeholder 占位图
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 *  通过URL设置一个CALayer对象的图片，并设置一个占位图和一个图片设置选项
 *
 *  @param url         图片URL
 *  @param placeholder 占位图
 *  @param options     图片设置选项
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;


/**
 *  通过设置URL来设置一个CALayer对象的图片
 *
 *  @param url            图片的URL
 *  @param completedBlock 当图片下载完成时回调Block
 */
- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  通过设置URL来设置一个CALayer对象的图片
 *
 *  @param url            图片的URL
 *  @param placeholder    占位图
 *  @param completedBlock 当图片下载完成时回调Block
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  通过设置URL来设置一个CALayer对象的图片
 *
 *  @param url            图片的URL
 *  @param placeholder    占位图
 *  @param options        图片设置选项
 *  @param completedBlock 当图片下载完成时回调Block
 */
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  通过设置URL来设置一个CALayer对象的图片
 *
 *  @param url            图片的URL
 *  @param placeholder    占位图
 *  @param options        图片设置选项
 *  @param progressBlock  图片现在进度回调Block
 *  @param completedBlock 当图片下载完成时回调Block
 */
- (void)sd_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(SDWebImageCompletionBlock)completedBlock;


/**
 *  通过设置URL来设置一个CALayer对象的图片，这个下载是异步，会先取到先前缓存的图片用来占位
 *
 *  @param url            图片的URL
 *  @param placeholder    占位图
 *  @param options        图片设置选项
 *  @param progressBlock  图片现在进度回调Block
 *  @param completedBlock 当图片下载完成时回调Block
 */
- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url
                                 placeholderImage:(UIImage *)placeholder
                                          options:(SDWebImageOptions)options
                                         progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                        completed:(SDWebImageCompletionBlock)completedBlock;


/**
 *  取消当前的图片下载
 */
- (void)sd_cancelCurrentImageLoad;



@end
