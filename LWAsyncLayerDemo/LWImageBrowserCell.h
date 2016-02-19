//
//  LWImageBrowserCell.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/19.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWImageBrowserModel.h"
#import "LWImageItem.h"


@interface LWImageBrowserCell : UICollectionViewCell

@property (nonatomic,strong) LWImageBrowserModel* imageModel;
@property (nonatomic,strong) LWImageItem* imageItem;

@end
