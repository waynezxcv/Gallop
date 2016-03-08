//
//  LWImageBrowserFlowLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/19.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import "LWImageBrowserFlowLayout.h"




@implementation LWImageBrowserFlowLayout


-(id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(SCREEN_WIDTH + 10.0f, SCREEN_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0.0f;
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}

@end
