

/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/


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


- (id)copyWithZone:(NSZone *)zone {
    StatusModel* one = [[StatusModel alloc] init];
    one.type = [self.type copy];
    one.avatar = [self.avatar copy];
    one.content = [self.content copy];
    one.detail = [self.detail copy];
    one.date = [self.date copy];
    one.imgs = [self.imgs copy];
    one.name = [self.name copy];
    one.statusID = [self.statusID copy];
    one.commentList = [self.commentList copy];
    one.likeList = [self.likeList copy];
    one.isLike = self.isLike;
    return one;
}


@end
