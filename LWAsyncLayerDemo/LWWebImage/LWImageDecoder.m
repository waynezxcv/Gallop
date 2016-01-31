//
//  LWImageDecoder.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/6.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageDecoder.h"

@interface LWImageDecoder ()

@property (nonatomic,assign) CGSize pixelSize;

@end

@implementation LWImageDecoder


#pragma mark - DrawBitMap

+ (LWImageDecoder *)sharedDecoder {
    static LWImageDecoder* decoder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        decoder = [[[self class] alloc] init];
    });
    return decoder;
}

- (id)init {
    self = [super init];
    if (self) {
        self.style = LWImageFormatStyle32BitBGR;
    }
    return self;
}

//图片解码
/*
 图片解码
 一般我们使用的图像是JPG/PNG，这些图像数据不是位图，而是是经过编码压缩后的数据，使用它渲染到屏幕之前需要进行解码转成位图数据，
 这个解码操作是比较耗时的，并且没有GPU硬解码，只能通过CPU，iOS默认会在主线程对图像进行解码。
 把解码操作从主线程移到子线程，让耗时的解码操作不占用主线程的时间。

 字节对齐
 为了性能，底层渲染图像时不是一个像素一个像素渲染，而是一块一块渲染，数据是一块块地取，就可能遇到这一块连续的内存数据里结尾的数据不是图像的内容，
 是内存里其他的数据，可能越界读取导致一些奇怪的东西混入，所以在渲染之前CoreAnimation要把数据拷贝一份进行处理，确保每一块都是图像数据，
 对于不足一块的数据置空。
 这里对图片提前进行字节对齐.主要是在创建上图解码的过程中，CGBitmapContextCreate函数的bytesPerRow参数必须传64的倍数。
 */
- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        return image;
    }
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    self.imageSize = imageSize;
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);

    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);

    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    } else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    CGSize pixelSize = self.pixelSize;
    NSInteger bytesPerPixel = [self bytesPerPixel];
    //bytesPerRow参数为64的倍数
    NSInteger imageRowLength = [self byteAlinWithWith:pixelSize.width * bytesPerPixel alignment:64];
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 imageRowLength,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return image;
    }
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
//    NSLog(@"imageRowLength..%ld",imageRowLength%64);
    return decompressedImage;
}

- (void)setImageSize:(CGSize)imageSize {
    BOOL currentSizeEqualToNewSize = CGSizeEqualToSize(imageSize, _imageSize);
    if (currentSizeEqualToNewSize == NO) {
        _imageSize = imageSize;
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        _pixelSize = CGSizeMake(screenScale * _imageSize.width, screenScale * _imageSize.height);
    }
}

- (NSInteger)bytesPerPixel {
    NSInteger bytesPerPixel;
    switch (self.style) {
        case LWImageFormatStyle32BitBGRA:
        case LWImageFormatStyle32BitBGR:
            bytesPerPixel = 4;
            break;
        case LWImageFormatStyle16BitBGR:
            bytesPerPixel = 2;
            break;
        case LWImageFormatStyle8BitGrayscale:
            bytesPerPixel = 1;
            break;
    }
    return bytesPerPixel;
}

- (size_t)byteAlinWithWith:(size_t)width alignment:(size_t)alignment {
    return ((width + (alignment - 1)) / alignment) * alignment;
}


@end
