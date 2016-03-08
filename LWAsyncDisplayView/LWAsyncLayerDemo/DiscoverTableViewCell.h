//
//  DiscoverTableViewCell.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import <UIKit/UIKit.h>
#import "DiscoverLayout.h"
#import "LWAsyncDisplayLayer.h"
#import "LWAsyncDisplayView.h"

@class DiscoverTableViewCell;

@protocol DiscoverTableViewCellDelegate <NSObject>

- (void)discoverTableViewCell:(DiscoverTableViewCell *)cell
    didClickedImageWithLayout:(DiscoverLayout *)layout
                      atIndex:(NSInteger)index;

@end

@interface DiscoverTableViewCell : UITableViewCell

@property (nonatomic,weak) id <DiscoverTableViewCellDelegate> delegate;
@property (nonatomic,strong) DiscoverLayout* layout;
@property (nonatomic,strong) LWAsyncDisplayView* label;

- (void)cleanUp;

- (void)drawContent;

@end

@interface MenuView : UIView

@end
