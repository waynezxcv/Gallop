//
//  UIImage+Transform.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/6.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "UIImage+LWWebImage.h"
#import <Accelerate/Accelerate.h>




@implementation UIImage(LWWebImage)




//图片压缩到指定大小
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize sourceImage:(UIImage *)sourceImage{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / imageWidth;
        CGFloat heightFactor = targetHeight / imageHeight;

        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth= imageWidth * scaleFactor;
        scaledHeight = imageHeight * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();

    if(newImage == nil)
        NSLog(@"could not scale image");
    UIGraphicsEndImageContext();
    return newImage;
}



//#pragma mark -
////模糊效果
//- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
//    //模糊度
//    if ((blur < 0.1f) || (blur > 2.0f)) {
//        blur = 0.5f;
//    }
//    //boxSize必须大于0
//    int boxSize = (int)(blur * 100);
//    boxSize -= (boxSize % 2) + 1;
//    //图像处理
//    CGImageRef img = image.CGImage;
//
//    //图像缓存,输入缓存，输出缓存
//    vImage_Buffer inBuffer, outBuffer;
//    vImage_Error error;
//    //像素缓存
//    void* pixelBuffer;
//    //数据源提供者，Defines an opaque type that supplies Quartz with data.
//    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
//    // provider’s data.
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//    //宽，高，字节/行，data
//    inBuffer.width = CGImageGetWidth(img);
//    inBuffer.height = CGImageGetHeight(img);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
//
//    //像数缓存，字节行*图片高
//    pixelBuffer = malloc(CGImageGetBytesPerRow(img)* CGImageGetHeight(img));
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(img);
//    outBuffer.height = CGImageGetHeight(img);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
//
//    //第三个中间的缓存区,抗锯齿的效果
//    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
//    vImage_Buffer outBuffer2;
//    outBuffer2.data = pixelBuffer2;
//    outBuffer2.width = CGImageGetWidth(img);
//    outBuffer2.height = CGImageGetHeight(img);
//    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
//
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    //颜色空间DeviceRGB
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
//    CGContextRef ctx = CGBitmapContextCreate(
//                                             outBuffer.data,
//                                             outBuffer.width,
//                                             outBuffer.height,
//                                             8,
//                                             outBuffer.rowBytes,
//                                             colorSpace,
//                                             CGImageGetBitmapInfo(image.CGImage));
//    //根据上下文，处理过的图片，重新组件
//    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
//    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//    //clean up
//    CGContextRelease(ctx);
//    CGColorSpaceRelease(colorSpace);
//    free(pixelBuffer);
//    free(pixelBuffer2);
//    CFRelease(inBitmapData);
//    //    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageRef);
//    return returnImage;
//}


//绘制圆角图片

//CGFloat padding = 0;
////绘制圆形图片
//CGSize originsize = image.size;
//
//CGFloat radius = MIN(self.imageView.bounds.size.width,self.imageView.bounds.size.height);
//CGRect originRect = CGRectMake (0,0,radius,radius);
//
//UIGraphicsBeginImageContext (originsize);
//CGContextRef ctx = UIGraphicsGetCurrentContext ();
//// 目标区域。
//CGRect desRect =  CGRectMake (padding, padding,originsize. width -(padding* 2 ), originsize. height -(padding* 2 ));
//// 设置填充背景色。
//CGContextSetFillColorWithColor (ctx, [UIColor clearColor].CGColor);
//UIRectFill (originRect); // 真正的填充
//// 设置椭圆变形区域。
//CGContextAddEllipseInRect (ctx,desRect);
//CGContextClip (ctx); // 截取椭圆区域。
//[image drawInRect :originRect]; // 将图像画在目标区域。
//UIImage * desImage = UIGraphicsGetImageFromCurrentImageContext ();
//UIGraphicsEndImageContext ();
//return desImage;
////                            UIImage* newImage = [self blurryImage:image withBlurLevel:0.5f];
////                            return newImage;
//
//

//
//
////创建略缩图
//CGImageRef MyCreateThumbnailImageFromData (CGImageSourceRef myImageSource, int imageSize) {
//    CGImageRef        myThumbnailImage = NULL;
//    //    CGImageSourceRef  myImageSource;
//    CFDictionaryRef   myOptions = NULL;
//    CFStringRef       myKeys[3];
//    CFTypeRef         myValues[3];
//    CFNumberRef       thumbnailSize;
//
//    //    // Create an image source from NSData; no options.
//    //    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
//    //                                                NULL);
//    // Make sure the image source exists before continuing.
//    if (myImageSource == NULL){
//        fprintf(stderr, "Image source is NULL.");
//        return  NULL;
//    }
//
//    // Package the integer as a  CFNumber object. Using CFTypes allows you
//    // to more easily create the options dictionary later.
//    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
//
//    // Set up the thumbnail options.
//    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
//    myValues[0] = (CFTypeRef)kCFBooleanTrue;
//    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
//    myValues[1] = (CFTypeRef)kCFBooleanTrue;
//    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
//    myValues[2] = (CFTypeRef)thumbnailSize;
//
//    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
//                                   (const void **) myValues, 2,
//                                   &kCFTypeDictionaryKeyCallBacks,
//                                   & kCFTypeDictionaryValueCallBacks);
//
//    // Create the thumbnail image using the specified options.
//    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
//                                                           0,
//                                                           myOptions);
//    // Release the options dictionary and the image source
//    // when you no longer need them.
//    CFRelease(thumbnailSize);
//    CFRelease(myOptions);
//    //    CFRelease(myImageSource);
//
//    // Make sure the thumbnail image exists before continuing.
//    if (myThumbnailImage == NULL){
//        fprintf(stderr, "Thumbnail image not created from image source.");
//        return NULL;
//    }
//
//    return myThumbnailImage;
//}
//
//
//
////图片压缩到指定大小
//- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize sourceImage:(UIImage *)sourceImage{
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat imageWidth = imageSize.width;
//    CGFloat imageHeight = imageSize.height;
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
//
//    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
//        CGFloat widthFactor = targetWidth / imageWidth;
//        CGFloat heightFactor = targetHeight / imageHeight;
//
//        if (widthFactor > heightFactor)
//            scaleFactor = widthFactor;
//        else
//            scaleFactor = heightFactor;
//        scaledWidth= imageWidth * scaleFactor;
//        scaledHeight = imageHeight * scaleFactor;
//        if (widthFactor > heightFactor)
//        {
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }
//        else if (widthFactor < heightFactor)
//        {
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//
//    UIGraphicsBeginImageContext(targetSize); // this will crop
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width= scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    [sourceImage drawInRect:thumbnailRect];
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    if(newImage == nil)
//        NSLog(@"could not scale image");
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//

@end
