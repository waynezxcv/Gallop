//
//  DiscoverHeader.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileModel;

@interface DiscoverHeader : UIView

@property (nonatomic,strong) ProfileModel* profileModel;

- (void)loadingViewAnimateWithScrollViewContentOffset:(CGFloat)offset;

- (void)refreshingAnimateBegin;
- (void)refreshingAnimateStop;

@end
