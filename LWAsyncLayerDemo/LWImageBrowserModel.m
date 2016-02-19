//
//  LWImageBrowserModel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowserModel.h"
#import "SDWebImageManager.h"

#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height

@interface LWImageBrowserModel ()

/**
 *  计算后的位置
 */
@property (nonatomic,assign,readwrite) CGRect destinationFrame;

/**
 *  是否已经下载
 */
@property (nonatomic,assign,readwrite) BOOL isDownload;


@end

@implementation LWImageBrowserModel

- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSString *)thumbnailURL
                    HDURL:(NSString *)HDURL
           originPosition:(CGRect)originPosition
                    index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.placeholder = placeholder;
        self.thumbnailURL = thumbnailURL;
        self.HDURL = HDURL;
        self.originPosition = originPosition;
        self.index = index;
    }
    return self;
}

/**
 *  设置略缩图URL
 *
 */
- (void)setThumbnailURL:(NSString *)thumbnailURL {
    if (_thumbnailURL != thumbnailURL) {
        _thumbnailURL = thumbnailURL;
    }
    if (_thumbnailURL == nil || _thumbnailURL.length == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.thumbnailURL]
                          options:0
                       processing:nil
                         progress:nil
                        completed:^(UIImage *image, NSError *error,
                                    SDImageCacheType cacheType,
                                    BOOL finished,
                                    NSURL *imageURL) {
                            if (finished) {
                                weakSelf.thumbnailImage = image;
                                weakSelf.destinationFrame = [weakSelf calculateDestinationFrameWithSize:weakSelf.thumbnailImage.size
                                                                                                  index:weakSelf.index];
                            }
                        }];
}

/**
 *
 *   设置略缩图的时候计算适配屏幕的大小
 */

- (CGRect)calculateDestinationFrameWithSize:(CGSize)size
                                      index:(NSInteger)index {
    CGRect rect = CGRectMake(kImageBrowserWidth * index,
                             (kImageBrowserHeight - size.height * [UIScreen mainScreen].bounds.size.width / size.width)/2,
                             [UIScreen mainScreen].bounds.size.width,
                             size.height * [UIScreen mainScreen].bounds.size.width / size.width);
    return rect;
}

@end
