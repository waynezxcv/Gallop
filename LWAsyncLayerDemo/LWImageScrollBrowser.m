//
//  LWImageScrollBrowser.m
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//




#import "LWImageScrollBrowser.h"
#import "LWImageItem.h"


@interface LWImageScrollBrowser ()<LWImageItemEventDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong) NSMutableArray* itemsArray;


@property (nonatomic,assign) BOOL isAnimated;

@end


@implementation LWImageScrollBrowser

- (id)initWithModelArray:(NSArray *)modelArray currentIndex:(NSInteger)currentIndex {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.modelArray = modelArray;
        self.currentIndex = currentIndex;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        [self.scrollView setContentOffset:CGPointMake(self.currentIndex * KImageBrowserWidth, 0.0f)];
    }
    return self;
}

- (void)setModelArray:(NSArray *)modelArray {
    if (_modelArray != modelArray) {
        _modelArray = modelArray;
    }
    for (NSInteger i = 0; i < self.modelArray.count; i ++) {
        LWImageItem* item = [[LWImageItem alloc] initWithFrame:CGRectMake(i * KImageBrowserWidth, 0.0f, SCREENWIDTH, SCREENHEIGHT) imageModel:[self.modelArray objectAtIndex:i]];
        item.eventDelegate = self;
        [self.scrollView addSubview:item];
        [self.itemsArray addObject:item];
    }
}

#pragma mark - Action
- (void)show {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    LWImageItem* currentItem = [self.itemsArray objectAtIndex:self.currentIndex];
    [currentItem loadHdImageWith:self.currentIndex animate:YES];
    if (self.currentIndex + 1 < self.modelArray.count) {
        LWImageItem* nextItem = [self.itemsArray objectAtIndex:self.currentIndex + 1];
        if (!nextItem.isLoaded) {
            [nextItem loadHdImageWith:self.currentIndex + 1 animate:NO];
        }
    }
    if (self.currentIndex - 1 >= 0) {
        LWImageItem* backItem = [self.itemsArray objectAtIndex:self.currentIndex - 1];
        if (!backItem.isLoaded) {
            [backItem loadHdImageWith:self.currentIndex - 1 animate:NO];
        }
    }

}

#pragma mark - Getter

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        LWImageItem* currentItem = [self.itemsArray objectAtIndex:currentIndex];
        if (!currentItem.isLoaded) {
            [currentItem loadHdImageWith:self.currentIndex animate:NO];
        }
        if (self.currentIndex + 1 < self.modelArray.count) {
            LWImageItem* nextItem = [self.itemsArray objectAtIndex:self.currentIndex + 1];
            if (!nextItem.isLoaded) {
                [nextItem loadHdImageWith:self.currentIndex + 1 animate:NO];
            }
        }
        if (self.currentIndex - 1 >= 0) {
            LWImageItem* backItem = [self.itemsArray objectAtIndex:self.currentIndex - 1];
            if (!backItem.isLoaded) {
                [backItem loadHdImageWith:self.currentIndex - 1 animate:NO];
            }
        }
    }
}


- (NSMutableArray *)itemsArray {
    if (!_itemsArray) {
        _itemsArray = [[NSMutableArray alloc] init];
    }
    return _itemsArray;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KImageBrowserWidth, KImageBrowserHeight)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height - KPageControlHeight - 10.0f,self.bounds.size.width, KPageControlHeight)];
        _pageControl.numberOfPages = self.modelArray.count;
        _pageControl.currentPage = self.currentIndex;
    }
    return _pageControl;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/SCREENWIDTH;
    self.currentIndex = index;
    self.pageControl.currentPage = self.currentIndex;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat offset = scrollView.contentOffset.x;
    
    if (self.itemModel.showPhotoCount < self.itemModel.totalPhotoCount) {
        if (offset > (self.itemModel.showPhotoCount - 1) * SCREENWIDTH) {
//            if ([[NSUserDefaults standardUserDefaults] stringForKey:@"uid"] == nil) {
//                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你目前是游客身份,登陆才能查看更多照片哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alertView show];
//            } else {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你目前是普通会员,升级VIP才能查看更多照片哦~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
//            }
            
        }
    }
}



- (void)didClickedItemToHide {
    __weak LWImageScrollBrowser* weakSelf = self;
    LWImageItem* item = (LWImageItem *)[self.itemsArray objectAtIndex:self.currentIndex];
    if (item.zoomScale != 1.0f) {
        item.zoomScale = 1.0f;
    }
    self.backgroundColor = [UIColor clearColor];
    CGRect originRect = item.imageModel.originFrame;
    CGRect destinationRect = [self convertRect:originRect fromView:item];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        item.imageView.frame = destinationRect;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];

}


- (void)didFinishRefreshThumbnailImageIfNeed {
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed)]) {
        [self.delegate imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed];
    }
}


@end
