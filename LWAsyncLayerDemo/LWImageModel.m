//
//  LWImageModel.m
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import "LWImageModel.h"
#import <SDWebImageManager.h>


@interface LWImageModel ()

@property (nonatomic,assign) BOOL isDownload;

@end

@implementation LWImageModel

- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSString *)thumbnailURL
                    HDURL:(NSString *)HDURL
               originRect:(CGRect)originRect
                    index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.index = index;
        self.placeholder = placeholder;
        self.thumbnailURL = thumbnailURL;
        self.HDURL = HDURL;
        self.originFrame = originRect;
        self.isDownload = [self isHDImageDonwLoadWithURLString:self.HDURL];
    }
    return self;
}

- (void)setThumbnailURL:(NSString *)thumbnailURL {
    if (_thumbnailURL != thumbnailURL) {
        _thumbnailURL = thumbnailURL;
    }
    if (_thumbnailURL == nil || _thumbnailURL.length == 0) {
        return;
    }
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.thumbnailURL] options:SDWebImageRetryFailed | SDWebImageLowPriority
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (finished) {
                                self.thumbnailImage = image;
                                self.destinationFrame = [self calculateDestinationFrameWithSize:self.thumbnailImage.size index:self.index];
                            }
                        }];
}

#pragma mark - Parser

- (CGRect)calculateDestinationFrameWithSize:(CGSize)size index:(NSInteger)index {
    CGRect rect = CGRectMake(KImageBrowserWidth * index, (KImageBrowserHeight - size.height * [UIScreen mainScreen].bounds.size.width / size.width)/2, [UIScreen mainScreen].bounds.size.width, size.height * [UIScreen mainScreen].bounds.size.width / size.width);
    return rect;
}

- (BOOL)isHDImageDonwLoadWithURLString:(NSString *)URLString {
    BOOL isDonwload = NO;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    isDonwload = [manager cachedImageExistsForURL:[NSURL URLWithString:URLString]];
    return isDonwload;
}

@end
