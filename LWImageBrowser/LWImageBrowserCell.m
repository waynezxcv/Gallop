//
//  LWImageBrowserCell.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/19.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageBrowserCell.h"
#import "LWDefine.h"



@implementation LWImageBrowserCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageItem = [[LWImageItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.contentView addSubview:self.imageItem];
    }
    return self;
}

- (void)setImageModel:(LWImageBrowserModel *)imageModel {
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
    }
    self.imageItem.imageModel = self.imageModel;
}

@end