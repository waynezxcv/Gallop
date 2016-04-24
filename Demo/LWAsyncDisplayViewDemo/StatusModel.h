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

@property (nullable, nonatomic, retain) NSURL* avatar;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSArray* imgs;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *statusID;
@property (nullable, nonatomic, retain) NSArray* commentList;
@property (nullable, nonatomic, retain) NSArray* likeList;

@end
