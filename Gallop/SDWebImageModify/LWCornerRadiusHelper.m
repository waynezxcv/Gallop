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

@implementation LWCornerRadiusHelper


+ (NSString *)lw_imageTransformCacheKeyForURL:(NSURL *)url
                                 cornerRadius:(CGFloat)cornerRadius
                                         size:(CGSize)size {
    if (!url) {
        return nil;
    }
    NSString* imageStransformCacheKey = [NSString stringWithFormat:@"%@%f,%f,%f,%@",
                                         LWCornerRadiusPrefixKey,
                                         cornerRadius,
                                         size.width,
                                         size.height,
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
        if (arr.count > 3) {
            cornerRadius = [arr[0] floatValue];
            width = [arr[1] floatValue];
            height = [arr[2] floatValue];
            if (width > 0 && height > 0) {
                if (width>height) {
                    imageSize = CGSizeMake(width * [GallopUtils contentsScale], width * [GallopUtils contentsScale]);
                }else{
                    imageSize = CGSizeMake(height * [GallopUtils contentsScale], height * [GallopUtils contentsScale]);
                }
            }else{
                imageSize = CGSizeMake(100.0f, 100.0f);
            }
        } else {
            if (image.size.height > image.size.width) {
                imageSize = CGSizeMake(image.size.height, image.size.height);
            }else{
                imageSize = CGSizeMake(image.size.width, image.size.width);
            }
            if (imageSize.height > 100.0f) {
                imageSize = CGSizeMake(100.0f, 100.0f);
            }
        }
        int w = imageSize.width;
        int h = imageSize.height;
        int radius = cornerRadius * [GallopUtils contentsScale];
        UIImage* img = image;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGRect rect = CGRectMake(0, 0, w, h);
        CGContextBeginPath(context);
        _addRadiusdRectToPath(context, rect, radius, radius);
        CGContextClosePath(context);
        CGContextClip(context);
        CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
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
