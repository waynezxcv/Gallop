//
//  StatusModel.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/5.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWAlchemy.h"

@interface StatusModel : NSObject

@property (nullable, nonatomic, copy) NSString* type;
@property (nullable, nonatomic, strong) NSURL* avatar;
@property (nullable, nonatomic, copy) NSString* content;
@property (nullable, nonatomic, copy) NSString* detail;
@property (nullable, nonatomic, strong) NSDate* date;
@property (nullable, nonatomic, copy) NSArray* imgs;
@property (nullable, nonatomic, copy) NSString* name;
@property (nullable, nonatomic, strong) NSNumber* statusID;
@property (nullable, nonatomic, copy) NSArray* commentList;
@property (nullable, nonatomic, copy) NSArray* likeList;
@property (nonatomic,assign) BOOL isLike;

@end
