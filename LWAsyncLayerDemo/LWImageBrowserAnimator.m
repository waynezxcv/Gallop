//
//  LWImageBrowserAnimator.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowserAnimator.h"
#import "LWImageBrowser.h"
#import "LWImageBrowserCell.h"

@implementation LWImageBrowserPresentAnimator

- (id)init {
    self = [super init];
    if (self) {
        self.transitionDuration = 0.35f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    LWImageBrowser* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    LWImageItem* currentImageItem = toViewController.currentImageItem;
    NSLog(@"currentItem:%@",currentImageItem);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //TODO:
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end




@implementation LWImageBrowserDismissAnimator

- (id)init {
    self = [super init];
    if (self) {
        self.transitionDuration = 0.35f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    LWImageBrowser* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    LWImageItem* currentImageItem = fromViewController.currentImageItem;
    if (currentImageItem.zoomScale != 1.0f) {
        currentImageItem.zoomScale = 1.0f;
    }
//
//    CGRect originRect = currentImageItem.imageModel.originPosition;
//    //    CGRect destinationRect = [self convertRect:originRect fromView:currentImageItem];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //TODO:
        NSLog(@"dismiss~");
//        currentImageItem.imageView.frame = destinationRect;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end