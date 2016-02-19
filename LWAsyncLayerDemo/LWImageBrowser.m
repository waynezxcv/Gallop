//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserAnimator.h"

#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSUInteger, LWImageBrowserScrollDirection) {
    LWImageBrowserScrollDirectionLeft,
    LWImageBrowserScrollDirectionRight,
};


@interface LWImageBrowser ()<UIViewControllerTransitioningDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;
@property (nonatomic,assign) NSInteger lastPosition;
@property (nonatomic,assign) LWImageBrowserScrollDirection scrollDirection;

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
            [self.parentVC.navigationController pushViewController:self animated:YES];
        }
            break;
        default: {
            [self.parentVC presentViewController:self animated:YES completion:^{}];
        }
            break;
    }
}


#pragma mark - Setter & Getter

- (LWImageItem *)previousImageView {
    if (!_previousImageView) {
        _previousImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           SCREEN_WIDTH,
                                                                           SCREEN_HEIGHT)];
    }
    return _previousImageView;
}

- (LWImageItem *)currentImageView {
    if (!_currentImageView) {
        _currentImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(kImageBrowserWidth,
                                                                          0.0f,
                                                                          SCREEN_WIDTH,
                                                                          SCREEN_HEIGHT)];
    }
    return _currentImageView;
}

- (LWImageItem *)nextImageView {
    if (!_nextImageView) {
        _nextImageView = [[LWImageItem alloc] initWithFrame:CGRectMake(2 * kImageBrowserWidth,
                                                                       0.0f,
                                                                       SCREEN_WIDTH,
                                                                       SCREEN_HEIGHT)];
    }
    return _nextImageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     kImageBrowserWidth,
                                                                     kImageBrowserHeight)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        if (self.imageModels.count <3) {
            _scrollView.contentSize = CGSizeMake(kImageBrowserWidth * self.imageModels.count, kImageBrowserHeight);
        }
        else {
            _scrollView.contentSize = CGSizeMake(3 * kImageBrowserWidth, kImageBrowserHeight);
        }
        [_scrollView addSubview:self.previousImageView];
        [_scrollView addSubview:self.currentImageView];
        [_scrollView addSubview:self.nextImageView];
    }
    return _scrollView;
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


#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.transitioningDelegate = self;
    [self.view addSubview:self.scrollView];
    if (self.style == LWImageBrowserStyleDefault) {
        [self.view addSubview:self.pageControl];
    }
    if (self.imageModels.count > 3) {
        [self.scrollView setContentOffset:CGPointMake(kImageBrowserWidth, 0.0f)];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(self.currentIndex * kImageBrowserWidth, 0.0f)];
    }
}


#pragma mark - UIScrollViewDelegate


/***
 第二种方式：
 利用中间的两个变量来当前的View及缓冲的View，最多创建三个View，将当前的View放在中间。判断滑动的位置，优先去缓冲的View找
 优点：对内存消耗少，缺点：代码相比要复杂一丝丝
 */
//- (void) realizeScrollLoop2{
//
//    status = ScrollViewLoopStatusResuing;
//
//    UIScrollView *scrollView = [[UIScrollView alloc] init];
//    scrollView.pagingEnabled = YES;
//    scrollView.frame = self.view.bounds ;
//    scrollView.delegate = self;
//    [self.view addSubview:scrollView];
//    self.scrollView = scrollView;
//
//    CGSize scrollViewSize = scrollView.frame.size;
//    scrollView.contentSize = CGSizeMake(3 * scrollViewSize.width, 0);
//    scrollView.contentOffset = CGPointMake(scrollViewSize.width, 0);
//
//    UIImageView *currentView = [[UIImageView alloc] init];
//    currentView.tag = 0;
//    currentView.frame = CGRectMake(scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height);
//    currentView.image = [UIImage imageNamed:@"00.jpg"];
//    [scrollView addSubview:currentView];
//    self.currentView = currentView;
//
//    [self resuingView];
//    self.index = 0;
//
//}
//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x > self.currentImageView.frame.origin.x) {
        NSInteger index = self.currentIndex + 1;
        if (self.currentIndex >= [self.imageModels count] - 1) {
            index = 0;
        }
        self.scrollDirection = LWImageBrowserScrollDirectionLeft;
        // 取缓冲区的View
        ////        self.resuingView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%zd.jpg",val]];
        //        self.resuingView.x = CGRectGetMinX(_currentView.frame) + _currentView.width;
        //        self.isLastScrollDirection = YES;
    }else{
        NSInteger index = self.currentIndex - 1;
        if (index < 0) {
            index = [self.imageModels count] - 1;
        }
        self.scrollDirection = LWImageBrowserScrollDirectionRight;
        //        self.resuingView.image = [UIImage imageNamed:[NSString stringWithFormat:@"0%zd.jpg",val]];
        //        self.resuingView.x = 0;
        //        self.isLastScrollDirection = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 是否是往右边滑动
    if (self.scrollDirection == LWImageBrowserScrollDirectionLeft) {
        if (self.currentIndex + 1 < self.imageModels.count) {
            self.currentIndex ++;
        }
    }else{
        if (self.currentIndex - 1 > 0) {
            self.currentIndex --;
        }
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    //    [self _loadImage];
    NSLog(@"currentIndex:%ld",self.currentIndex);
}

#pragma mark - Private

- (void)_loadImage {
    if (self.imageModels.count > 3) {
        //前一张图片
        if (self.currentIndex - 1 > 0) {
            self.previousImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex - 1];
        }
        //中间的图片
        self.currentImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex];
        //下一张图片
        if (self.currentIndex + 1 < self.imageModels.count - 1) {
            self.nextImageView.imageModel = [self.imageModels objectAtIndex:self.currentIndex + 1];
        }
    }
    else {

    }
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


@end
