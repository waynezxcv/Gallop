//
//  LWImageItem.h
//  Warmjar2
//
//  Created by 刘微 on 15/10/6.
//  Copyright © 2015年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageModel.h"
#import <SDWebImageManager.h>


@protocol LWImageItemEventDelegate <NSObject>

- (void)didClickedItemToHide;
- (void)didFinishRefreshThumbnailImageIfNeed;


@end

@interface LWImageItem : UIScrollView

@property (nonatomic,weak) id <LWImageItemEventDelegate> eventDelegate;

@property (nonatomic,strong) LWImageModel* imageModel;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,assign) BOOL isLoaded;

- (id)initWithFrame:(CGRect)frame imageModel:(LWImageModel *)imageModel;

- (void)loadHdImageWith:(NSInteger)index animate:(BOOL)animate;

- (void)downloadHDImageWithAnimate:(BOOL)animated;

@end
