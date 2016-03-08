//
//  ContainerView.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/2.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import <UIKit/UIKit.h>
#import "DiscoverLayout.h"

@interface ContainerView : UIView

@property (nonatomic,strong) DiscoverLayout* layout;

- (void)cleanUp;

- (void)drawConent;

@end
