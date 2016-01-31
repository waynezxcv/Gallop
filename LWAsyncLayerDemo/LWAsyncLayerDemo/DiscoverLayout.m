//
//  DiscoverLayout.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverLayout.h"

@interface DiscoverLayout ()


@end

@implementation DiscoverLayout

- (id)initWithStatusModel:(DiscoverStatuModel *)statuModel {
    self = [super init];
    if (self) {
        self.statusModel = statuModel;
        [self layout];
    }
    return self;
}

- (void)layout {
    //name
    self.nameTextLayout = [[LWTextLayout alloc] initWithText:self.statusModel.user.name
                                                        font:[UIFont systemFontOfSize:14.0f]
                                               textAlignment:NSTextAlignmentCenter
                                                   linespace:0.0f
                                                   textColor:RGB(113, 129, 161, 1)
                                                        rect:CGRectMake(60.0f, 20.0f,ScreenWidth, 20.0f)];
    //text
    self.textTextLayout = [[LWTextLayout alloc] initWithText:self.statusModel.text
                                                        font:[UIFont systemFontOfSize:15.0f]
                                               textAlignment:NSTextAlignmentLeft
                                                   linespace:2.0f
                                                   textColor:RGB(40, 40, 40, 1)
                                                        rect:CGRectMake(60.0f, 50.0f, ScreenWidth - 80.0f, CGFLOAT_MAX)];
    //timeStamp
    self.timeStampTextLayout = [[LWTextLayout alloc] initWithText:self.statusModel.timeStamp
                                                             font:[UIFont systemFontOfSize:13.0f]
                                                    textAlignment:NSTextAlignmentCenter
                                                        linespace:2.0f
                                                        textColor:[UIColor grayColor]
                                                             rect:CGRectMake(60.0f, 60.0f + self.textTextLayout.boundsSize.height, ScreenWidth - 80.0f, 20.0f)];
    //avatar
    self.avatarPosition = CGRectMake(10.0f, 20.0f,40.0f, 40.0f);
    //menu
    self.menuPosition = CGRectMake(ScreenWidth - 40.0f, 65.0f + self.textTextLayout.boundsSize.height, 20.0f, 15.0f);
    //cellHeight
    self.cellHeight = 60.0f + self.textTextLayout.boundsSize.height + self.timeStampTextLayout.boundsSize.height + 20.0f;
}


@end
