//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserAnimator.h"

@interface LWImageBrowser ()<UIViewControllerTransitioningDelegate>

@end

@implementation LWImageBrowser


#pragma mark - Init

- (id)initWithModelArray:(NSArray *)modelArray currentIndex:(NSInteger)currentIndex {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - ViewControllerLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.transitioningDelegate = self;
}


#pragma mark - Actions

- (void)show {


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
