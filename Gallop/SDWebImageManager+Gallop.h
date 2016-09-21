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

#import "SDWebImageManager.h"

@interface  SDWebImageManager(Gallop)

@property (strong, nonatomic) NSMutableSet *failedURLs;
@property (strong, nonatomic) NSMutableArray *runningOperations;

/**
 *  通过一个URL下载图片并缓存，如果缓存已经存在，则直接读取缓存的图片
 *
 *  @param cornerRadius 圆角半径值
 *  @param cornerBackgroundColor 圆角半径的背景颜色
 *  @param cornerBorderColor 圆角半径的描边颜色
 *  @param cornerBorderWidth 圆角半径的描边宽度
 *  @param url            图片的URL
 *  @param options        图片设置选项
 *  @param size           图片大小
 *  @param isBlur         是否模糊处理
 *  @param progressBlock  进度
 *  @param completedBlock 处理完成回调
 *
 * @return 一个遵循SDWebImageOperation协议的NSObject对象
 */
- (id <SDWebImageOperation>)lw_downloadImageWithURL:(NSURL *)url
                                       cornerRadius:(CGFloat)cornerRadius
                              cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                                        borderColor:(UIColor *)borderColor
                                        borderWidth:(CGFloat)borderWidth
                                               size:(CGSize)size
                                             isBlur:(BOOL)isBlur
                                            options:(SDWebImageOptions)options
                                           progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                          completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

@end
