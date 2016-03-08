//
//  DiscoverModel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/31.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import <Foundation/Foundation.h>

@class UserModel;
@class DiscoverShareModel;

typedef NS_ENUM(NSUInteger, DiscoverStatuType) {
    DiscoverStatuTypeNormal,//文字or图片or文字+图片
    DiscoverStatuTypeShare,//分享
    DiscoverStatuTypeVideo,//视频
    DiscoverStatuTypeAdvertising//广告
};

//
@interface DiscoverStatuModel : NSObject
@property (nonatomic,assign) DiscoverStatuType statuType;//朋友圈状态类型
@property (nonatomic,strong) UserModel* user;//发布用户
@property (nonatomic,copy) NSString* text;//文字内容
@property (nonatomic,copy) NSArray* imageModels;//图片URL数组
@property (nonatomic,copy) NSString* timeStamp;//发布时间
@property (nonatomic,copy) NSArray* likedUsers;//点赞的用户
@property (nonatomic,copy) NSArray* comments;//评论的用户
@property (nonatomic,strong) DiscoverShareModel* share;//分享

@end


//图片
@interface ImageModels : NSObject

@property (nonatomic,strong) NSURL* thumbnailURL;
@property (nonatomic,strong) NSURL* HDURL;

@end

//用户
@interface UserModel : NSObject

@property (nonatomic,copy) NSString* name;
@property (nonatomic,copy) NSURL* avatarURL;

@end


//评论
@interface DiscoverCommentModel : NSObject

@property (nonatomic,strong) UserModel* fromUser;
@property (nonatomic,strong) UserModel* toUser;
@property (nonatomic,copy) NSString* content;

@end


//分享
@interface DiscoverShareModel : NSObject

@property (nonatomic,copy) NSString* imageURL;
@property (nonatomic,copy) NSString* title;
@property (nonatomic,copy) NSString* link;

@end

