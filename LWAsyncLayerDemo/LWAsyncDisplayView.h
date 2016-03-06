//
//  LWLabel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextLayout.h"


@class LWAsyncDisplayView;

@protocol LWLabelDelegate <NSObject>

@optional
/**
 *  点击链接回调
 *
 */
- (void)lwAsyncDicsPlayView:(LWAsyncDisplayView *)lwLabel didCilickedLinkWithfData:(id)data;

/**
 *  额外的绘制任务在这里实现
 *
 */
- (void)extraAsyncDisplayIncontext:(CGContextRef)context size:(CGSize)size;

@end

/**
 *  LWLabel 支持属性文本、图文混排、点击链接、异步绘制。
 */
@interface LWAsyncDisplayView : UIView

@property (nonatomic,weak) id <LWLabelDelegate> delegate;

/**
 *  存放文字排版的数组
 */
@property (nonatomic,copy) NSArray* layouts;

@end
