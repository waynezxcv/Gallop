//
//  DiscoverTableViewCell.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverLayout.h"

@interface DiscoverTableViewCell : UITableViewCell

@property (nonatomic,strong) DiscoverLayout* layout;

@end




@interface BackgroundImageView : UIView

- (void)drawContentWithLayout:(DiscoverLayout *)layout;

@end

@interface MenuView : UIView

@end
