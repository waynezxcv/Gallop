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

#import "LWImageItem.h"
#import "LWProgeressHUD.h"
#import "LWImageBrowserDefine.h"


const CGFloat kMaximumZoomScale = 3.0f;
const CGFloat kMinimumZoomScale = 1.0f;
const CGFloat kDuration = 0.3f;

@interface LWImageItem ()<UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic,assign) CGPoint originalPoint;

@end

@implementation LWImageItem{
    CGFloat _yFromCenter;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.maximumZoomScale = kMaximumZoomScale;
        self.minimumZoomScale = kMinimumZoomScale;
        self.zoomScale = 1.0f;
        [self addSubview:self.imageView];
        [self setupGestures];
    }
    return self;
}

- (void)setupGestures {
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSingleTap:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer* twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleTwoFingerTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;
    twoFingerTap.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}


- (void)setImageModel:(LWImageBrowserModel *)imageModel {
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
    }
    self.zoomScale = 1.0f;
    [self loadHdImage:self.isFirstShow];
}

- (void)loadHdImage:(BOOL)animated {
    if (!self.imageModel.thumbnailImage) {
        self.imageView.image = self.imageModel.placeholder;
        if (!self.imageModel.placeholder) {
            return;
        }
        self.imageView.frame = [self calculateDestinationFrameWithSize:self.imageModel.placeholder.size];
        return;
    }

    CGRect destinationRect = [self calculateDestinationFrameWithSize:self.imageModel.thumbnailImage.size];
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [manager cachedImageExistsForURL:self.imageModel.HDURL completion:^(BOOL isInCache) {
        __strong typeof(weakSelf) sself = weakSelf;
        //还未下载的图片
        if (!isInCache) {
            sself.imageView.image = sself.imageModel.thumbnailImage;
            if (animated) {
                sself.imageView.frame = sself.imageModel.originPosition;
                [UIView animateWithDuration:0.18f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     sself.imageView.center = sself.center;
                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         [sself downloadImageWithDestinationRect:destinationRect];
                                     }
                                 }];
            } else {
                sself.imageView.center = sself.center;
                [sself downloadImageWithDestinationRect:destinationRect];
            }
        }
        
        //已经下载的图片
        else {
            
            if (animated) {
                sself.imageView.frame = sself.imageModel.originPosition;
                [sself.imageView sd_setImageWithURL:sself.imageModel.HDURL];
                [UIView animateWithDuration:kDuration
                                      delay:0.0f
                     usingSpringWithDamping:0.7
                      initialSpringVelocity:0.0f
                                    options:0 animations:^{
                                        sself.imageView.frame = destinationRect;
                                    } completion:^(BOOL finished) {
                                        
                                    }];
            } else {
                [sself.imageView sd_setImageWithURL:sself.imageModel.HDURL];
                sself.imageView.frame = destinationRect;
            }
        }
    }];;
}

- (void)downloadImageWithDestinationRect:(CGRect)destinationRect {
    
    __weak typeof(self) weakSelf = self;
    LWProgeressHUD* progressHUD = [LWProgeressHUD showHUDAddedTo:self];
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager loadImageWithURL:self.imageModel.HDURL
                          options:options
                         progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                             progressHUD.progress = (float)receivedSize/expectedSize;
                         } completed:^(UIImage * _Nullable image,
                                       NSData * _Nullable data,
                                       NSError * _Nullable error,
                                       SDImageCacheType cacheType,
                                       BOOL finished,
                                       NSURL * _Nullable imageURL) {
                             
                             __strong typeof(weakSelf) sself = weakSelf;
                             if (finished && image) {
                                 [LWProgeressHUD hideAllHUDForView:sself];
                                 sself.imageView.image = image;
                                 sself.imageModel.thumbnailImage = image;
                                 if ([sself.eventDelegate respondsToSelector:@selector(didFinishedDownLoadHDImage)]) {
                                     [sself.eventDelegate didFinishedDownLoadHDImage];
                                 }
                                 [UIView animateWithDuration:kDuration
                                                       delay:0.0f
                                      usingSpringWithDamping:0.7
                                       initialSpringVelocity:0.0f
                                                     options:0 animations:^{
                                                         sself.imageView.frame = destinationRect;
                                                     } completion:^(BOOL finished) {
                                                     }];
                             }
                         }];
    });
}


#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (CGRect)calculateDestinationFrameWithSize:(CGSize)size{
    CGRect rect;
    rect = CGRectMake(0.0f,
                      (SCREEN_HEIGHT - size.height * SCREEN_WIDTH/size.width)/2,
                      SCREEN_WIDTH,
                      size.height * SCREEN_WIDTH/size.width);
    if (rect.size.height > SCREEN_HEIGHT) {
        rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    }
    self.contentSize = rect.size;
    return rect;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UIGestureRecognizerHandler

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        if ([self.eventDelegate respondsToSelector:@selector(didClickedItemToHide)]) {
            [self.eventDelegate didClickedItemToHide];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(self.zoomScale == 1){
            float newScale = [self zoomScale] * 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        } else {
            float newScale = [self zoomScale] / 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

- (void)handleTwoFingerTap:(UITapGestureRecognizer *)gestureRecongnizer{
    float newScale = [self zoomScale]/2;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecongnizer locationInView:self]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width = [self frame].size.width / scale;
    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;
    return zoomRect;
}

@end
