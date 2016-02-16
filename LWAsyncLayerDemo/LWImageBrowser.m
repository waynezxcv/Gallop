//
//  LWImageBrowser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowser.h"
#import "LWImageBrowserAnimator.h"

@interface LWImageBrowser ()<LWImageBrowserAnimatorDelegate>

@end

@implementation LWImageBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

//- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
////    presented
////    return [[PresentationVc alloc] initWithPresentedViewController:presented presentingViewController:presenting];
//}
//
//-(id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented
//                                                                  presentingController:(UIViewController*)presenting
//                                                                      sourceController:(UIViewController *)source {
//    LWImageBrowserAnimator* animator = [[LWImageBrowserAnimator alloc] init];
//    animator.delegate = self;
//    return animator;
//}
//
//-(id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
//    LWImageBrowserAnimator* animator = [[LWImageBrowserAnimator alloc] init];
//    animator.delegate = self;
//    return animator;
//}
//
//- (void)lwImageBrowserAnimationWillBegin {
//
//}
//
//- (void)lwImageBrowserAnimationDidFinished {
//
//}

@end
