//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserFlowLayout.h"
#import "LWImageBrowserCell.h"
#import <Accelerate/Accelerate.h>



#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height
#define kCellIdentifier @"LWImageBroserCellIdentifier"



@interface LWImageBrowser ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
LWImageItemEventDelegate>

@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,strong) UIImage* screenshot;
@property (nonatomic,strong) LWImageBrowserFlowLayout* flowLayout;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;

@end

@implementation LWImageBrowser

#pragma mark - Initialization

- (id)initWithParentViewController:(UIViewController *)parentVC
                             style:(LWImageBrowserStyle)style
                   backgroundStyle:(LWImageBrowserBackgroundStyle)backgroundStyle
                       imageModels:(NSArray *)imageModels
                      currentIndex:(NSInteger)index {
    self  = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.style = style;
        self.imageModels = imageModels;
        self.currentIndex = index;
        self.firstShow = YES;
        self.backgroundStyle = backgroundStyle;
        switch (self.backgroundStyle) {
            case LWImageBrowserBackgroundStyleBlack:
                self.screenshot = [self _screenshotFromView:self.parentVC.view];
                break;
            default:{
//                UIImage* screenshot = [self _screenshotFromView:self.parentVC.view];
//                if (screenshot) {
                    self.screenshot = [self _blurryImage:[UIImage imageNamed:@"loading"] withBlurLevel:0.5f];
//                }
            }
                break;
        }
    }
    return self;
}

- (void)show {
    switch (self.style) {
        case LWImageBrowserStyleDetail: {
            [self.parentVC.navigationController pushViewController:self animated:YES];
        }
            break;
        default: {
            [self.parentVC presentViewController:self animated:NO completion:^{}];
        }
            break;
    }
}


#pragma mark - Setter & Getter

- (LWImageBrowserFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[LWImageBrowserFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH + 10.0f, SCREEN_HEIGHT)
                                             collectionViewLayout:self.flowLayout];
        if (self.backgroundStyle == LWImageBrowserBackgroundStyleBlack) {
            _collectionView.backgroundColor = [UIColor blackColor];
        }
        else {
            _collectionView.backgroundColor = [UIColor clearColor];
        }
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[LWImageBrowserCell class] forCellWithReuseIdentifier:kCellIdentifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                       SCREEN_HEIGHT - kPageControlHeight - 10.0f,
                                                                       SCREEN_WIDTH,
                                                                       kPageControlHeight)];
        _pageControl.numberOfPages = self.imageModels.count;
        _pageControl.currentPage = self.currentIndex;
    }
    return _pageControl;
}

- (UIImageView *)screenshotImageView {
    if (!_screenshotImageView) {
        _screenshotImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        _screenshotImageView.contentMode = UIViewContentModeScaleAspectFill;
        _screenshotImageView.image = self.screenshot;
    }
    return _screenshotImageView;
}


#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.screenshotImageView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * (SCREEN_WIDTH + 10.0f), 0.0f) animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self _setCurrentItem];
    self.firstShow = NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.imageItem.firstShow = self.isFirstShow;
    cell.imageModel = [self.imageModels objectAtIndex:indexPath.row];
    cell.imageItem.eventDelegate = self;
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset / SCREEN_WIDTH;
    self.currentIndex = index;
    self.pageControl.currentPage = self.currentIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _setCurrentItem];
}

#pragma mark - LWImageItemDelegate

- (void)didClickedItemToHide {
    [self _hide];
}


- (void)didFinishRefreshThumbnailImageIfNeed {
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed)]
        && [self.delegate conformsToProtocol:@protocol(LWImageBrowserDelegate)]) {
        [self.delegate imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed];
    }
}

#pragma mark - Private
- (UIImage *)_screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,aView.opaque, 0.0f);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (void)_hide {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    __weak typeof(self) weakSelf = self;
    switch (self.style) {
        case LWImageBrowserStyleDetail: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default: {
            if (self.currentImageItem.zoomScale != 1.0f) {
                self.currentImageItem.zoomScale = 1.0f;
            }
            self.collectionView.backgroundColor = [UIColor clearColor];
            self.currentImageItem.backgroundColor = [UIColor clearColor];
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                weakSelf.currentImageItem.imageView.frame = weakSelf.currentImageItem.imageModel.originPosition;
            } completion:^(BOOL finished) {
                [weakSelf dismissViewControllerAnimated:NO completion:^{}];
            }];
        }
            break;
    }
}

- (void)_setCurrentItem {
    NSArray* cells = [self.collectionView visibleCells];
    if (cells.count != 0) {
        LWImageBrowserCell* cell = [cells objectAtIndex:0];
        if (self.currentImageItem != cell.imageItem) {
            self.currentImageItem = cell.imageItem;
            [self _preDownLoadImageWithIndex:self.currentIndex];
        }
    }
}

//现在当前Index的前一张和后一张图片
- (void)_preDownLoadImageWithIndex:(NSInteger)index {
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    //下载下一张图片
    if (index + 1 < self.imageModels.count) {
        LWImageBrowserModel* nextModel = [self.imageModels objectAtIndex:index + 1];
        [manager downloadImageWithURL:[NSURL URLWithString:nextModel.HDURL]
                              options:0
                           processing:nil
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
    //下载前一张图片
    if (index - 1 >= 0) {
        LWImageBrowserModel* previousModel = [self.imageModels objectAtIndex:index - 1];
        [manager downloadImageWithURL:[NSURL URLWithString:previousModel.HDURL]
                              options:0
                           processing:nil
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
}

//模糊效果
- (UIImage *)_blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    //模糊度
    if ((blur < 0.1f) || (blur > 2.0f)) {
        blur = 0.5f;
    }
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    //图像处理
    CGImageRef img = image.CGImage;
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void* pixelBuffer;
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img)* CGImageGetHeight(img));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    //第三个中间的缓存区,抗锯齿的效果
    void* pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);

    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage* returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    //    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}

@end
