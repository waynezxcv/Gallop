//
//  DiscoverTableViewCell.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverLayout.h"
#import "LWAsyncDisplayLayer.h"

@interface DiscoverTableViewCell : UITableViewCell

@property (nonatomic,strong) DiscoverLayout* layout;

- (void)cleanUp;

- (void)drawContent;

@end

@interface MenuView : UIView

@end
