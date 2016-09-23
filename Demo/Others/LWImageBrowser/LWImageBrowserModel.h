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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWImageBrowserModel : NSObject


@property (nonatomic,strong) UIImage* placeholder;//占位图
@property (nonatomic,strong) NSURL* thumbnailURL;//缩略图的URL
@property (nonatomic,strong) UIImage* thumbnailImage;//缩略图
@property (nonatomic,strong) NSURL* HDURL;//高清图的URL
@property (nonatomic,assign,readonly) BOOL isDownload;//高清图是否已经下载
@property (nonatomic,assign) CGRect originPosition;//原始位置（点击时，该图片位于UIWindow坐标系中的位置）
@property (nonatomic,assign,readonly) CGRect destinationFrame;//动画的目的地位置
@property (nonatomic,assign) NSInteger index;//标号

/**
 *  创建LWImageModel实例对象
 *
 *  @param placeholder  占位图片
 *  @param thumbnailURL 略缩图URL
 *  @param HDURL        高清图URL
 *  @param originRect   原始位置
 *  @param index        标号
 *
 *  @return LWImageModel实例对象
 */
- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
            containerView:(UIView *)containerView
      positionInContainer:(CGRect)positionInContainer
                    index:(NSInteger)index;

@end
