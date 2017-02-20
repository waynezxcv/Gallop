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

#import "LWAsyncImageView.h"
#import "GallopDefine.h"
#import "SDWebImageCompat.h"
#import "SDWebImageManager+Gallop.h"


/*
 *
 * LWAsyncImageView下载网络图片扩展
 */




@interface LWAsyncImageView (WebCache)


/**
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
- (void)lw_asyncSetImageWithURL:(NSURL *)url
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
                      completed:(LWWebImageDownloaderCompletionBlock)completedBlock;

/**
 *  获取当前图片的URL
 *
 */
- (NSURL *)lw_imageURL;

/**
 *  取消当前的图片下载
 */
- (void)lw_cancelCurrentImageLoad;


@end
