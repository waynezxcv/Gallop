//
//  LWImageBrowserAnimator.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/16.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  present时的转场动画
 */
@interface LWImageBrowserPresentAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) NSTimeInterval transitionDuration;

@end


/**
 *  dismiss时的转场动画
 */
@interface LWImageBrowserDismissAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) NSTimeInterval transitionDuration;

@end