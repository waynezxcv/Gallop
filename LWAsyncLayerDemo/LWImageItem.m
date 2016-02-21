//
//  LWImageItem.m
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import "LWImageItem.h"

const CGFloat kMaximumZoomScale = 3.0f;
const CGFloat kMinimumZoomScale = 1.0f;
const CGFloat kDuration = 0.25f;

@interface LWImageItem ()<UIScrollViewDelegate,UIActionSheetDelegate>

@end

@implementation LWImageItem

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
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSingleTap:)];
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleDoubleTap:)];
        UITapGestureRecognizer* twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleTwoFingerTap:)];
        UILongPressGestureRecognizer* longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(handleLongpress:)];
        longpress.minimumPressDuration = 0.4f;
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        twoFingerTap.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:singleTap];
        [self.imageView addGestureRecognizer:doubleTap];
        [self.imageView addGestureRecognizer:twoFingerTap];
        [self.imageView addGestureRecognizer:longpress];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
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
    if (self.imageModel.thumbnailImage == nil) {
        return;
    }
    CGRect destinationRect = [self calculateDestinationFrameWithSize:self.imageModel.thumbnailImage.size];
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    BOOL isImageCached = [manager cachedImageExistsForURL:[NSURL URLWithString:self.imageModel.HDURL]];
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
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageModel.HDURL]];
            [UIView animateWithDuration:kDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakSelf.imageView.frame = destinationRect;
                             } completion:^(BOOL finished) {}];
        } else {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageModel.HDURL]];
            self.imageView.frame = destinationRect;
        }
    }
}


- (void)downloadImageWithDestinationRect:(CGRect)destinationRect {
    __weak typeof(self) weakSelf = self;
    //    MBProgressHUD* progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    //    progressHUD.mode = MBProgressHUDModeDeterminate;
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageLowPriority;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager downloadImageWithURL:[NSURL URLWithString:self.imageModel.HDURL]
                              options:options
                           processing:nil
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 //TODO:加载动画
                             } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                 if (finished) {
                                     //                [MBProgressHUD hideAllHUDsForView:weakSelf animated:NO];
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

- (void)handleLongpress:(UILongPressGestureRecognizer *)longpress {
    switch (longpress.state) {
        case UIGestureRecognizerStateBegan: {
            UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"保存图片"
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"保存到本地", nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
            break;
        default:
            break;
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 8_3) {
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    if (!error) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片已保存到本地!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }
}


@end
