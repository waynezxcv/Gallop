//
//  LWImageBrowserAnimator.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol LWImageBrowserAnimatorDelegate <NSObject>

- (void)lwImageBrowserAnimationWillBegin;
- (void)lwImageBrowserAnimationDidFinished;

@end

@interface LWImageBrowserAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,weak) id <LWImageBrowserAnimatorDelegate> delegate;
@property (nonatomic,assign) NSTimeInterval transitionDuration;

@end
