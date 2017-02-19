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


/**
 *  对UIImage的扩展
 *
 */

@interface UIImage (Gallop)

/**
 *  将一张图片按照contentMode和指定的size处理
 *
 */
- (UIImage *)lw_processedImageWithContentMode:(UIViewContentMode)contentMode size:(CGSize)size;


/**
 *  在指定区域内按照UIViewContentMode的样式和是否clips绘制
 *
 */
- (void)lw_drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips;


/**
 *  纠正图片的方向
 *
 */
- (UIImage *)lw_fixOrientation;


/**
 *  根据颜色生成纯色图片
 *
 */
+ (UIImage *)lw_imageWithColor:(UIColor *)color;

/**
 *  取图片某一像素的颜色
 *
 */
- (UIColor *)lw_colorAtPixel:(CGPoint)point;

/**
 *  获得灰度图
 *
 */
- (UIImage *)lw_convertToGrayImage;


/**
 *  用一个Gif生成UIImage
 *
 *  @param theData 传入一个GIFData对象
 */
+ (UIImage *)lw_animatedImageWithAnimatedGIFData:(NSData *)theData;

/**
 *  用一个Gif生成UIImage
 *
 *  @param theURL 传入一个GIF路径
 */
+ (UIImage *)lw_animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

/**
 *  按给定的方向旋转图片
 *
 */
- (UIImage*)lw_rotate:(UIImageOrientation)orient;

/**
 *  垂直翻转
 *
 */
- (UIImage *)lw_flipVertical;

/**
 *  水平翻转
 *
 */
- (UIImage *)lw_flipHorizontal;


/**
 *  将图片旋转degrees角度
 *
 */
- (UIImage *)lw_imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  将图片旋转radians弧度
 *
 */
- (UIImage *)lw_imageRotatedByRadians:(CGFloat)radians;

/**
 * 截取当前image对象rect区域内的图像
 *
 */
- (UIImage *)lw_subImageWithRect:(CGRect)rect;

/**
 * 压缩图片至指定尺寸
 *
 */
- (UIImage *)lw_rescaleImageToSize:(CGSize)size;

/**
 * 压缩图片至指定像素
 *
 */
- (UIImage *)lw_rescaleImageToPX:(CGFloat)toPX;

/**
 * 在指定的size里面生成一个平铺的图片
 *
 */
- (UIImage *)lw_getTiledImageWithSize:(CGSize)size;


/**
 * UIView转化为UIImage
 *
 */
+ (UIImage *)lw_imageFromView:(UIView *)view;

/**
 * 将两个图片生成一张图片
 *
 */
+ (UIImage*)lw_mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;

/**
 * 图片模糊处理
 *
 */
- (UIImage *)lw_applyBlurWithRadius:(CGFloat)blurRadius
                          tintColor:(UIColor *)tintColor
              saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                          maskImage:(UIImage *)maskImage;

@end
