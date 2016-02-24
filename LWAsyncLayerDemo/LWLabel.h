//
//  LWLabel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextLayout.h"


@class LWLabel;

@protocol LWLabelDelegate <NSObject>

@optional

- (void)lwLabel:(LWLabel *)lwLabel didCilickedLinkWithfData:(id)data;


@end


/**
 *  LWLabel 支持属性文本、图文混排、点击链接、异步绘制。
 */
@interface LWLabel : UIView

@property (nonatomic,weak) id <LWLabelDelegate> delegate;

/**
 *  存放文字排版的数组
 */
@property (nonatomic,copy) NSArray* layouts;

@end
