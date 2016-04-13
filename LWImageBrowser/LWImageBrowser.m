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
#import "UIImage+ImageEffects.h"
#import "LWImageBrowserButton.h"
#import "LWActionSheetView.h"
#import "LWDefine.h"


#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height
#define kCellIdentifier @"LWImageBroserCellIdentifier"


@interface LWImageBrowser ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
LWImageItemEventDelegate,
LWActionSheetViewDelegate>

@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,strong) UIImageView* blurImageView;
@property (nonatomic,strong) UIImage* screenshot;
@property (nonatomic,strong) LWImageBrowserFlowLayout* flowLayout;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;
@property (nonatomic,strong) LWImageBrowserButton* button;

@end

@implementation LWImageBrowser

#pragma mark - Initialization

- (id)initWithParentViewController:(UIViewController *)parentVC
                             style:(LWImageBrowserShowAnimationStyle)style
                       imageModels:(NSArray *)imageModels
                      currentIndex:(NSInteger)index {

    self  = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.style = style;
        self.imageModels = imageModels;
        self.currentIndex = index;
        switch (self.style) {
            case LWImageBrowserAnimationStyleScale:
                self.screenshot = [self _screenshotFromView:[UIApplication sharedApplication].keyWindow];
                self.firstShow = YES;
                break;
            default:
                self.firstShow = NO;
                break;
        }
    }
    return self;
}

- (void)show {
    switch (self.style) {
        case LWImageBrowserAnimationStylePush: {
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
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH + 10.0f,self.view.bounds.size.height)
                                             collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[LWImageBrowserCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
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
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (LWImageBrowserButton *)button {
    if (!_button) {
        _button = [[LWImageBrowserButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60.0f,
                                                                         SCREEN_HEIGHT - 50.0f,
                                                                         60.0f,
                                                                         40.0f)];
        [_button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapMenuButton)]];
    }
    return _button;
}

- (UIImageView *)screenshotImageView {
    if (!_screenshotImageView) {
        _screenshotImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        _screenshotImageView.image = self.screenshot;
    }
    return _screenshotImageView;
}

- (UIImageView *)blurImageView {
    if (!_blurImageView) {
        _blurImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        _blurImageView.alpha = 0.0f;
    }
    return _blurImageView;
}

#pragma mark - ViewControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.style == LWImageBrowserAnimationStylePush) {
        self.view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.collectionView];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 50, 40);
        rightButton.backgroundColor = [UIColor clearColor];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightButton setTitle:@"•••" forState:UIControlStateNormal];
        UIBarButtonItem* rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        [rightButton addTarget:self action:@selector(_didClickedRightButton) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.screenshotImageView];
        [self.view addSubview:self.blurImageView];
        [self.view addSubview:self.collectionView];
        [self.view addSubview:self.pageControl];
        [self.view addSubview:self.button];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage* blurImage = [self.screenshot applyBlurWithRadius:20
                                                        tintColor:RGB(0, 0, 0, 0.6)
                                            saturationDeltaFactor:1.4
                                                        maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            _blurImageView.image = blurImage;
            [UIView animateWithDuration:0.1f animations:^{
                _blurImageView.alpha = 1.0f;
            }];
        });
    });
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * (SCREEN_WIDTH + 10.0f), 0.0f) animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.style == LWImageBrowserAnimationStyleScale) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
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
    if (self.style == LWImageBrowserAnimationStylePush) {
        self.title = [NSString stringWithFormat:@"%ld/%ld",
                      (NSInteger)(self.collectionView.contentOffset.x / SCREEN_WIDTH) + 1,
                      self.imageModels.count];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _setCurrentItem];
}

#pragma mark - LWImageItemDelegate

- (void)didClickedItemToHide {
    if (self.style == LWImageBrowserAnimationStyleScale) {
        [self _hide];
    }
    else {
        [self _hideNavigationBar];
    }
}

- (void)didFinishRefreshThumbnailImageIfNeed {
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed)]
        && [self.delegate conformsToProtocol:@protocol(LWImageBrowserDelegate)]) {
        [self.delegate imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed];
    }
}

#pragma mark - Private

- (void)_didClickedLeftButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_didClickedRightButton {
    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithArray:[self.imageModels copy]];
    [tmpArray removeObjectAtIndex:self.currentIndex];
    self.imageModels = tmpArray;
    [self _setCurrentItem];
    [self.collectionView reloadData];
    if (self.style == LWImageBrowserAnimationStylePush) {
        self.title = [NSString stringWithFormat:@"%ld/%ld",
                      (NSInteger)(self.collectionView.contentOffset.x / SCREEN_WIDTH) + 1,
                      self.imageModels.count];
    }
}

- (UIImage *)_screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,NO,[UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (void)_hide {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    __weak typeof(self) weakSelf = self;
    switch (self.style) {
        case LWImageBrowserAnimationStylePush: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default: {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            if (self.currentImageItem.zoomScale != 1.0f) {
                self.currentImageItem.zoomScale = 1.0f;
            }
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakSelf.blurImageView.alpha = 0.0f;
                                 weakSelf.currentImageItem.imageView.frame = weakSelf.currentImageItem.imageModel.originPosition;
                             } completion:^(BOOL finished) {
                                 [weakSelf dismissViewControllerAnimated:NO completion:^{}];
                             }];
        }
            break;
    }
}

- (void)_hideNavigationBar {
    if (self.navigationController.navigationBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        [self.navigationController setNavigationBarHidden:YES animated:YES];

    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
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

/**
 *  预加载当前Index的前后两张图片
 *
 *  @param index 当前的Index
 */
- (void)_preDownLoadImageWithIndex:(NSInteger)index {
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    if (index + 1 < self.imageModels.count) {
        LWImageBrowserModel* nextModel = [self.imageModels objectAtIndex:index + 1];
        [manager downloadImageWithURL:nextModel.HDURL
                              options:0
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
    if (index - 1 >= 0) {
        LWImageBrowserModel* previousModel = [self.imageModels objectAtIndex:index - 1];
        [manager downloadImageWithURL:previousModel.HDURL
                              options:0
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
}

- (void)_tapMenuButton {
    LWActionSheetView* actionSheet = [[LWActionSheetView alloc] initTilesArray:@[@"分享",@"举报",@"保存到本地",@"取消"] delegate:self];
    [actionSheet show];
}

#pragma mark - LWActionSheetViewDelegate

- (void)lwActionSheet:(LWActionSheetView *)actionSheet didSelectedButtonWithIndex:(NSInteger)index {
    NSLog(@"%ld",index);


}

@end
