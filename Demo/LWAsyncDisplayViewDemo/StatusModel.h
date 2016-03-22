//
//  StatusModel.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/3/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAlchemy.h"

@interface StatusModel : NSObject

@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) NSURL* avatar;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,strong) NSDate* date;
@property (nonatomic,copy) NSArray* imgs;
@property (nonatomic,assign) NSInteger statusID;


@end
