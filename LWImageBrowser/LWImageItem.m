//
//  LWImageItem.m
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import "LWImageItem.h"
#import "LWDefine.h"

const CGFloat kMaximumZoomScale = 3.0f;
const CGFloat kMinimumZoomScale = 1.0f;
const CGFloat kDuration = 0.18f;

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
    if (self.isFirstShow) {
        [self loadHdImage:YES];
    }
    else {
        [self loadHdImage:NO];
    }
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
    BOOL isImageCached = [manager cachedImageExistsForURL:self.imageModel.HDURL];
    __weak typeof(self) weakSelf = self;
    //还未下载的图片
    if (!isImageCached) {
        self.imageView.image = self.imageModel.thumbnailImage;
        if (animated) {
            self.imageView.frame = self.imageModel.originPosition;
            [UIView animateWithDuration:0.18f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 weakSelf.imageView.center = weakSelf.center;
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     [weakSelf downloadImageWithDestinationRect:destinationRect];
                                 }
                             }];
        } else {
            weakSelf.imageView.center = weakSelf.center;
            [self downloadImageWithDestinationRect:destinationRect];
        }
    }
    //已经下载的图片
    else {
        if (animated) {
            self.imageView.frame = self.imageModel.originPosition;
            [self.imageView sd_setImageWithURL:self.imageModel.HDURL];
            [UIView animateWithDuration:kDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakSelf.imageView.frame = destinationRect;
                             } completion:^(BOOL finished) {
                             }];
        } else {
            [self.imageView sd_setImageWithURL:self.imageModel.HDURL];
            self.imageView.frame = destinationRect;
        }
    }
}

- (void)downloadImageWithDestinationRect:(CGRect)destinationRect {
    __weak typeof(self) weakSelf = self;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager downloadImageWithURL:self.imageModel.HDURL
                              options:options
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 //TODO:加载动画

                             } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                 if (finished) {
                                     weakSelf.imageView.image = image;
                                     weakSelf.imageModel.thumbnailImage = image;
                                     // 通知刷新
                                     if ([self.eventDelegate respondsToSelector:@selector(didFinishRefreshThumbnailImageIfNeed)]) {
                                         [self.eventDelegate didFinishRefreshThumbnailImageIfNeed];
                                     }
                                     [UIView animateWithDuration:0.2f animations:^{
                                         weakSelf.imageView.frame = destinationRect;
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
    CGRect rect = CGRectMake(0.0f,
                             (SCREEN_HEIGHT - size.height * SCREEN_WIDTH/size.width)/2,
                             SCREEN_WIDTH,
                             size.height * SCREEN_WIDTH/size.width);
    return rect;
}


#pragma mark - UIScrollViewDelegate
/**
 *  缩放对象
 *
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

/**
 *  缩放结束
 *
 */
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

/**
 *  让UIImageView在UIScrollView缩放后居中显示
 *
 */
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UIGestureRecognizerHandler
/**
 *  单击
 *
 */
- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        if ([self.eventDelegate respondsToSelector:@selector(didClickedItemToHide)]) {
            [self.eventDelegate didClickedItemToHide];
        }
    }
}

/**
 *  双击
 *
 */
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
