//
//  LWImageDecoder.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/6.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LWImageFormatStyle) {
    LWImageFormatStyle32BitBGRA,
    LWImageFormatStyle32BitBGR,
    LWImageFormatStyle16BitBGR,
    LWImageFormatStyle8BitGrayscale,
};


@interface LWImageDecoder : NSObject

- (UIImage *)decodedImageWithImage:(UIImage *)image;

@property (nonatomic,assign) LWImageFormatStyle style;
@property (nonatomic,assign) CGSize imageSize;

+ (LWImageDecoder *)sharedDecoder;

@end
