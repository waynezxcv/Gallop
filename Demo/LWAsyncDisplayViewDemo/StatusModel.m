//
//  StatusModel.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/5.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "StatusModel.h"

@implementation StatusModel

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.type = dict[@"type"];
        self.avatar = [NSURL URLWithString:dict[@"avatar"]];
        self.content = dict[@"content"];
        self.detail = dict[@"detail"];
        self.date = [NSDate dateWithTimeIntervalSince1970:[dict[@"date"] floatValue]];
        self.imgs = dict[@"imgs"];
        self.name = dict[@"name"];
        self.statusID = dict[@"statusID"];
        self.commentList = dict[@"commentList"];
        self.likeList = dict[@"likeList"];
        self.isLike = [dict[@"isLike"] boolValue];
    }
    return self;
}



@end
