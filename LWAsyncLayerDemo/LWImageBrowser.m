//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserAnimator.h"
#import "LWImageBrowserFlowLayout.h"
#import "LWImageBrowserCell.h"

#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height
#define kCellIdentifier @"LWImageBroserCellIdentifier"

@interface LWImageBrowser () <UIViewControllerTransitioningDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
LWImageItemEventDelegate>

@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,strong) UIImage* screenshot;
@property (nonatomic,strong) LWImageBrowserFlowLayout* flowLayout;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;

@end

@implementation LWImageBrowser

#pragma mark - Initialization

- (id)initWithParentViewController:(UIViewController *)parentVC
                             style:(LWImageBrowserStyle)style
                       imageModels:(NSArray *)imageModels
                      currentIndex:(NSInteger)index {
    self  = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.style = style;
        self.imageModels = imageModels;
        self.currentIndex = index;
    }
    return self;
}

- (void)show {
    switch (self.style) {
        case LWImageBrowserStyleDetail: {
            self.screenshot = [self _screenshotFromView:self.parentVC.view];
            [self.parentVC.navigationController pushViewController:self animated:YES];
        }
            break;
        default: {
            self.screenshot = [self _screenshotFromView:self.parentVC.view];
            [self.parentVC presentViewController:self animated:YES completion:^{}];
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
        _collectionView = [[UICollectionView alloc] initWithFrame:SCREEN_BOUNDS collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
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
    self.view.backgroundColor = [UIColor blackColor];
    self.transitioningDelegate = self;
    [self.view addSubview:self.screenshotImageView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * SCREEN_WIDTH, 0.0f) animated:NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LWImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
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

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                            presentingController:(UIViewController *)presenting
                                                                                sourceController:(UIViewController *)source {
    LWImageBrowserPresentAnimator* animator = [[LWImageBrowserPresentAnimator alloc] init];
    return animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    LWImageBrowserDismissAnimator* animator = [[LWImageBrowserDismissAnimator alloc] init];
    return animator;
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
    switch (self.style) {
        case LWImageBrowserStyleDetail: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default: {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
            break;
    }
}

- (void)_setCurrentItem {
    NSArray* cells = [self.collectionView visibleCells];
    if (cells.count != 0) {
        LWImageBrowserCell* cell = [cells objectAtIndex:0];
        self.currentImageItem = cell.imageItem;
    }
}

@end
