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


#import "LWImageProcessor.h"
#import "GallopUtils.h"
#import "GallopDefine.h"
#import "UIImage+Gallop.h"




@implementation LWImageProcessor

+ (void)getRGBComponents:(CGFloat [4])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context =
    CGBitmapContextCreate(&resultingPixel,
                          1,
                          1,
                          8,
                          4,
                          rgbColorSpace,
                          (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 4; component++) {
        components[component] = resultingPixel[component];
    }
}


+ (NSString *)lw_imageTransformCacheKeyForURL:(NSURL *)url
                                 cornerRadius:(CGFloat)cornerRadius
                                         size:(CGSize)size
                        cornerBackgroundColor:(UIColor *)cornerBackgroundColor
                                  borderColor:(UIColor *)borderColor
                                  borderWidth:(CGFloat)borderWidth
                                  contentMode:(UIViewContentMode)contentMode
                                       isBlur:(BOOL)isBlur {
    //将圆角和模糊的相关属性值写入到一个字符串中，以kLWImageProcessorPrefixKey开头。
    if (!url) {
        return nil;
    }
    CGFloat cr = -1;
    CGFloat cg = -1;
    CGFloat cb = -1;
    CGFloat ca = -1;
    if (cornerBackgroundColor) {
        CGFloat cornerComponents[4];
        [self getRGBComponents:cornerComponents
                      forColor:cornerBackgroundColor];
        cr = cornerComponents[0];
        cg = cornerComponents[1];
        cb = cornerComponents[2];
        ca = cornerComponents[3];
    }
    
    CGFloat br = -1;
    CGFloat bg = -1;
    CGFloat bb = -1;
    CGFloat ba = -1;
    
    if (borderColor) {
        CGFloat borderCompnents[4];
        [self getRGBComponents:borderCompnents
                      forColor:borderColor];
        br = borderCompnents[0];
        bg = borderCompnents[1];
        bb = borderCompnents[2];
        ba = borderCompnents[3];
    }
    
    
    int blur = 0;
    if (isBlur) {
        blur = 1;
    }
    
    //生成绘制信息标识的字符串
    NSString* imageStransformCacheKey =
    [NSString stringWithFormat:
     @"%@%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%ld,%@",
     kLWImageProcessorPrefixKey,
     cornerRadius,
     size.width,
     size.height,
     cr,
     cg,
     cb,
     ca,
     br,
     bg,
     bb,
     ba,
     borderWidth,
     blur,
     (long)contentMode,
     url.absoluteString];
    return imageStransformCacheKey;
}

+ (UIImage *)lw_cornerRadiusImageWithImage:(UIImage*)img withKey:(NSString *)key {
    
    //从标识字符串中，依次去除圆角半径和模式的相关属性值，对原图进行处理
    if (key && [key hasPrefix:[NSString stringWithFormat:@"%@",
                               kLWImageProcessorPrefixKey]]) {
        NSString* infoString =
        [key substringFromIndex:kLWImageProcessorPrefixKey.length];
        NSArray* arr = [infoString componentsSeparatedByString:@","];
        CGFloat w;
        CGFloat h;
        CGFloat bw;
        CGFloat cr;
        CGFloat cg;
        CGFloat cb;
        CGFloat ca;
        CGFloat br;
        CGFloat bg;
        CGFloat bb;
        CGFloat ba;
        
        UIColor* cornerBackgroundColor = nil;
        UIColor* borderColor = nil;
        
        int blur = 0;
        
        UIViewContentMode contentMode = 0;
        
        CGFloat r = [arr[0] floatValue];
        w = [arr[1] floatValue];
        h = [arr[2] floatValue];
        cr = [arr[3] floatValue];
        cg = [arr[4] floatValue];
        cb = [arr[5] floatValue];
        ca = [arr[6] floatValue];
        br = [arr[7] floatValue];
        bg = [arr[8] floatValue];
        bb = [arr[9] floatValue];
        ba = [arr[10] floatValue];
        bw = [arr[11] floatValue];
        blur = [arr[12] intValue];
        contentMode = [arr[13] integerValue];
        
        if (cr != -1 && cg != -1 && cb != -1 && ca != -1) {
            CGFloat alpha = ca/255.0f;
            cornerBackgroundColor = RGB(cr, cg, cb, alpha);
            
        }
        
        if (br != -1 && bg != -1 && bb != -1 && ba != -1) {
            CGFloat alpha = ba/255.0f;
            borderColor = RGB(br, bg, bb, alpha);
        }
        if (w < 0 || h < 0) {
            return nil;
        }
        
        CGFloat width = w * [GallopUtils contentsScale];
        CGFloat height = h * [GallopUtils contentsScale];
        CGFloat cornerRadius = r * [GallopUtils contentsScale];
        CGFloat borderWidth = bw * [GallopUtils contentsScale];
        
        UIImage* processedImg = [img lw_processedImageWithContentMode:contentMode
                                                                 size:CGSizeMake(width, height)];
        
        if (blur) {
            processedImg = [processedImg lw_applyBlurWithRadius:20
                                                      tintColor:RGB(0, 0, 0, 0.15f)
                                          saturationDeltaFactor:1.4
                                                      maskImage:nil];
        }
        
        
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     (int)width,
                                                     (int)height,
                                                     8,
                                                     4 * (int)width,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedFirst);
        CGRect rect = {
            {0,0},
            {width,height}
        };
        
        CGRect imgRect = {
            {borderWidth,borderWidth},
            {width - 2 * borderWidth,height - 2 * borderWidth}
        };
        
        if (cornerBackgroundColor) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextSetFillColorWithColor(context,cornerBackgroundColor.CGColor);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }
        
        {
            CGContextSaveGState(context);
            if (cornerRadius) {
                UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                                      cornerRadius:cornerRadius];
                CGContextAddPath(context, bezierPath.CGPath);
                CGContextClip(context);
            }
            CGContextDrawImage(context, imgRect, processedImg.CGImage);
            CGContextRestoreGState(context);
        }
        
        if (borderColor && borderWidth != 0) {
            CGContextSaveGState(context);
            UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                                  cornerRadius:cornerRadius];
            CGContextAddPath(context, bezierPath.CGPath);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextSetLineWidth(context, borderWidth);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
        
        CGImageRef imageMasked = CGBitmapContextCreateImage(context);
        UIImage* results = [UIImage imageWithCGImage:imageMasked];
        
        CGImageRelease(imageMasked);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        return results;
    }
    return img;
}


@end
