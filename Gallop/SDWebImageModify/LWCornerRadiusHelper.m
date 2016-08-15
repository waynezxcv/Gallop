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

@implementation LWCornerRadiusHelper

+ (void)getRGBComponents:(CGFloat [4])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
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
                                  borderWidth:(CGFloat)borderWidth {
    if (!url) {
        return nil;
    }

    CGFloat cr = -1;
    CGFloat cg = -1;
    CGFloat cb = -1;
    CGFloat ca = -1;

    if (cornerBackgroundColor) {
        CGFloat cornerComponents[4];
        [self getRGBComponents:cornerComponents forColor:cornerBackgroundColor];
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
        [self getRGBComponents:borderCompnents forColor:borderColor];
        br = borderCompnents[0];
        bg = borderCompnents[1];
        bb = borderCompnents[2];
        ba = borderCompnents[3];
    }

    NSString* imageStransformCacheKey = [NSString stringWithFormat:@"%@%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%@",
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
                                         url.absoluteString];
    return imageStransformCacheKey;
}


+ (UIImage *)lw_cornerRadiusImageWithImage:(UIImage*)image withKey:(NSString *)key {

    if (key && [key hasPrefix:[NSString stringWithFormat:@"%@",LWCornerRadiusPrefixKey]]) {
        NSString* infoString = [key substringFromIndex:LWCornerRadiusPrefixKey.length];
        NSArray* arr = [infoString componentsSeparatedByString:@","];

        CGSize imageSize;
        CGFloat width;
        CGFloat height;
        CGFloat cornerRadius;
        UIColor* cornerBackgroundColor = nil;
        UIColor* borderColor = nil;
        CGFloat borderWidth = 0.0f;;

        CGFloat cr;
        CGFloat cg;
        CGFloat cb;
        CGFloat ca;

        CGFloat br;
        CGFloat bg;
        CGFloat bb;
        CGFloat ba;

        cornerRadius = [arr[0] floatValue];
        width = [arr[1] floatValue];
        height = [arr[2] floatValue];
        cr = [arr[3] floatValue];
        cg = [arr[4] floatValue];
        cb = [arr[5] floatValue];
        ca = [arr[6] floatValue];
        br = [arr[7] floatValue];
        bg = [arr[8] floatValue];
        bb = [arr[9] floatValue];
        ba = [arr[10] floatValue];
        borderWidth = [arr[11] floatValue];

        if (cr != -1 && cg != -1 && cb != -1 && ca != -1) {
            CGFloat alpha = ca/255.0f;
            cornerBackgroundColor = RGB(cr, cg, cb, alpha);

        }

        if (br != -1 && bg != -1 && bb != -1 && ba != -1) {
            CGFloat alpha = ba/255.0f;
            borderColor = RGB(br, bg, bb, alpha);
        }

        if (width < 0 || height < 0) {
            return nil;
        }

        if (width > height) {
            imageSize = CGSizeMake(width * [GallopUtils contentsScale],
                                   width * [GallopUtils contentsScale]);
        }

        else {
            imageSize = CGSizeMake(height * [GallopUtils contentsScale],
                                   height * [GallopUtils contentsScale]);
        }

        int w = imageSize.width;
        int h = imageSize.height;
        int radius = cornerRadius * [GallopUtils contentsScale];
        int bw = borderWidth * [GallopUtils contentsScale];

        UIImage* img = image;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     w,
                                                     h,
                                                     8,
                                                     4 * w,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedFirst);
        //rect
        CGRect rect = CGRectMake(0, 0, w, h);
        CGRect imgRect = CGRectMake(bw,
                                    bw,
                                    w - 2 * bw,
                                    h - 2 * bw);

        //draw cornerBackground
        if (cornerBackgroundColor) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextSetFillColorWithColor(context,cornerBackgroundColor.CGColor);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }

        //draw border
        if (borderColor && bw != 0) {
            CGContextSaveGState(context);
            CGContextAddEllipseInRect(context, imgRect);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
            CGContextSetLineWidth(context, bw);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }

        //draw cornerRadius image
        CGContextBeginPath(context);
        _addRadiusdRectToPath(context, imgRect, radius - bw, radius - bw);
        CGContextClosePath(context);
        CGContextClip(context);

        CGContextDrawImage(context,
                           imgRect,
                           img.CGImage);

        CGImageRef imageMasked = CGBitmapContextCreateImage(context);
        img = [UIImage imageWithCGImage:imageMasked];
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(imageMasked);
        return img;
    }
    return image;
}

static void _addRadiusdRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;

    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}



@end
