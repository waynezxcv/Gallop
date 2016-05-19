//
//  TableViewHeader.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewHeader : UIView

- (void)loadingViewAnimateWithScrollViewContentOffset:(CGFloat)offset;
- (void)refreshingAnimateBegin;
- (void)refreshingAnimateStop;

@end
