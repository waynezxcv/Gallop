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


#import "LWCornerRadiusHelper.h"
#import "GallopUtils.h"
#import "GallopDefine.h"
#import "UIImage+Gallop.h"




@implementation LWCornerRadiusHelper

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
                                       isBlur:(BOOL)isBlur {
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
    
    NSString* imageStransformCacheKey =
    [NSString stringWithFormat:
     @"%@%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%d,%@",
     LWCornerRadiusPrefixKey,
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
     url.absoluteString];
    return imageStransformCacheKey;
}


+ (UIImage *)lw_cornerRadiusImageWithImage:(UIImage*)img withKey:(NSString *)key {
    
    if (key &&
        [key hasPrefix:[NSString stringWithFormat:@"%@",
                        LWCornerRadiusPrefixKey]]) {
        NSString* infoString =
        [key substringFromIndex:LWCornerRadiusPrefixKey.length];
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
        UIImage* originImg = img;
        UIImage* processedImg = nil;
        CGFloat width = w * [GallopUtils contentsScale];
        CGFloat height = h * [GallopUtils contentsScale];
        CGFloat cornerRadius = r * [GallopUtils contentsScale];
        CGFloat borderWidth = bw * [GallopUtils contentsScale];
        if (originImg.size.width >= originImg.size.height) {
            CGFloat scale = originImg.size.width/originImg.size.height;
            processedImg = [originImg
                            lw_subImageWithRect:CGRectMake((originImg.size.width - originImg.size.height * scale)/2.0f,
                                                           0.0f,
                                                           originImg.size.height * scale,
                                                           originImg.size.height)];
        } else {
            CGFloat scale = originImg.size.height/originImg.size.width;
            processedImg = [originImg
                            lw_subImageWithRect:CGRectMake(0.0f,
                                                           (originImg.size.height - originImg.size.width * scale)/2.0f,
                                                           originImg.size.width,
                                                           originImg.size.width * scale)];
        }
        
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
        //total rect
        CGRect rect = {
            {0,0},
            {width,height}
        };
        
        //image rect
        CGRect imgRect = {
            {borderWidth,borderWidth},
            {width - 2 * borderWidth,height - 2 * borderWidth}
        };
        //draw cornerBackground
        if (cornerBackgroundColor) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextSetFillColorWithColor(context,cornerBackgroundColor.CGColor);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }
        //draw border
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
        //draw cornerRadius image
        UIImage* results = nil;
        if (cornerRadius) {
            UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:imgRect
                                                                  cornerRadius:cornerRadius];
            CGContextAddPath(context, bezierPath.CGPath);
            CGContextClip(context);
            CGContextDrawTiledImage(context, imgRect, processedImg.CGImage);
            CGImageRef imageMasked = CGBitmapContextCreateImage(context);
            results = [UIImage imageWithCGImage:imageMasked];
            CGImageRelease(imageMasked);
        } else {
            //draw cornerRadius image
            CGContextDrawTiledImage(context, imgRect, processedImg.CGImage);
            CGImageRef imageMasked = CGBitmapContextCreateImage(context);
            results = [UIImage imageWithCGImage:imageMasked];
            CGImageRelease(imageMasked);
        }
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return results;
    }
    return img;
}

@end
