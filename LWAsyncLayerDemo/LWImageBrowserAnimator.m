//
//  LWImageBrowserAnimator.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowserAnimator.h"


@implementation LWImageBrowserAnimator

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
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    if ([self.delegate respondsToSelector:@selector(lwImageBrowserAnimationWillBegin)]) {
        [self.delegate lwImageBrowserAnimationWillBegin];
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //TODO:
        NSLog(@"transition~");
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if (finished && [self.delegate respondsToSelector:@selector(lwImageBrowserAnimationDidFinished)]) {
            [self.delegate lwImageBrowserAnimationDidFinished];
        }
    }];
}

@end
