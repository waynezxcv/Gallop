//
//  LWImageBrowserModel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/17.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowserModel.h"
#import "SDWebImageManager.h"
#import "LWDefine.h"


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
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
       imageViewSuperView:(UIView *)superView
      positionAtSuperView:(CGRect)positionAtSuperView
                    index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.placeholder = placeholder;
        self.thumbnailURL = thumbnailURL;
        self.HDURL = HDURL;
        self.index = index;
        self.title = @"";
        self.contentDescription = @"";
        if (superView != nil) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGRect originRect = [superView convertRect:positionAtSuperView toView:window];
            self.originPosition = originRect;
        }
        else {
            self.originPosition = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
        }
    }
    return self;
}


- (id)initWithLocalImage:(UIImage *)localImage
      imageViewSuperView:(UIView *)superView
     positionAtSuperView:(CGRect)positionAtSuperView
                   index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.placeholder = localImage;
        self.index = index;
        self.title = @"";
        self.contentDescription = @"";
        if (superView != nil) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGRect originRect = [superView convertRect:positionAtSuperView toView:window];
            self.originPosition = originRect;
        }
        else {
            self.originPosition = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
        }
    }
    return self;
}

/**
 *  设置略缩图URL
 *
 */
- (void)setThumbnailURL:(NSURL *)thumbnailURL {
    if (_thumbnailURL != thumbnailURL) {
        _thumbnailURL = thumbnailURL;
    }
    if (_thumbnailURL == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:self.thumbnailURL
                          options:0
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
