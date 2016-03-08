//
//  LWImageItem.h
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//


#import <UIKit/UIKit.h>
#import "LWImageBrowserModel.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"


@protocol LWImageItemEventDelegate <NSObject>

- (void)didClickedItemToHide;
- (void)didFinishRefreshThumbnailImageIfNeed;

@end

@interface LWImageItem : UIScrollView

@property (nonatomic,weak) id <LWImageItemEventDelegate> eventDelegate;

@property (nonatomic,strong) LWImageBrowserModel* imageModel;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;

- (void)loadHdImage:(BOOL)animated;

@end
