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


#import "LWImageBrowserModel.h"
#import "SDWebImageManager.h"
#import "LWImageBrowserDefine.h"




@interface LWImageBrowserModel ()

@property (nonatomic,assign,readwrite) CGRect destinationFrame;
@property (nonatomic,assign,readwrite) BOOL isDownload;

@end

@implementation LWImageBrowserModel

- (id)initWithplaceholder:(UIImage *)placeholder
             thumbnailURL:(NSURL *)thumbnailURL
                    HDURL:(NSURL *)HDURL
            containerView:(UIView *)containerView
      positionInContainer:(CGRect)positionInContainer
                    index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.placeholder = placeholder;
        self.thumbnailURL = thumbnailURL;
        self.HDURL = HDURL;
        self.index = index;
        if (containerView != nil) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGRect originRect = [containerView convertRect:positionInContainer toView:window];
            self.originPosition = originRect;
        }
        else {
            self.originPosition = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
        }
    }
    return self;
}

- (void)setThumbnailURL:(NSURL *)thumbnailURL {
    if (_thumbnailURL != thumbnailURL) {
        _thumbnailURL = thumbnailURL;
    }
    if (_thumbnailURL == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:self.thumbnailURL
                      options:0
                     progress:nil
                    completed:^(UIImage * _Nullable image,
                                NSData * _Nullable data,
                                NSError * _Nullable error,
                                SDImageCacheType cacheType,
                                BOOL finished,
                                NSURL * _Nullable imageURL) {
                        __strong typeof(weakSelf) sself = weakSelf;

                        if (finished) {
                            sself.thumbnailImage = image;
                            sself.destinationFrame =
                            [sself calculateDestinationFrameWithSize:sself.thumbnailImage.size
                                                               index:sself.index];
                        }
                    }];

}


- (CGRect)calculateDestinationFrameWithSize:(CGSize)size
                                      index:(NSInteger)index {
    CGRect rect = CGRectMake(kImageBrowserWidth * index,
                             (kImageBrowserHeight - size.height * [UIScreen mainScreen].bounds.size.width / size.width)/2,
                             [UIScreen mainScreen].bounds.size.width,
                             size.height * [UIScreen mainScreen].bounds.size.width / size.width);
    return rect;
}

@end
