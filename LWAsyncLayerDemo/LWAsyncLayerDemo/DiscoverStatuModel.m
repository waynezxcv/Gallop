//
//  DiscoverModel.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "DiscoverStatuModel.h"

@implementation DiscoverStatuModel

- (id)init {
    self = [super init];
    if (self) {
        self.statuType = DiscoverStatuTypeNormal;
        self.user = [[UserModel alloc] init];
        self.text = @"";
        self.imageModels = @[];
        self.timeStamp = @"";
        self.likedUsers = @[];
        self.comments = @[];
        self.share = [[DiscoverShareModel alloc] init];
    }
    return self;
}

@end


@implementation ImageModels

@end



@implementation UserModel

- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.avatarURL = [NSURL URLWithString: @""];
    }
    return self;
}

@end




@implementation DiscoverCommentModel

- (id)init {
    self = [super init];
    if (self) {
        self.fromUser = [[UserModel alloc] init];
        self.toUser = [[UserModel alloc] init];
        self.content = @"";
    }
    return self;
}

@end



@implementation DiscoverShareModel

- (id)init {
    self = [super init];
    if (self) {
        self.link = @"";
        self.title = @"";
        self.imageURL = @"";
    }
    return self;
}

@end

