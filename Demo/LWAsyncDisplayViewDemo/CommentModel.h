//
//  CommentModel.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/24.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic,copy) NSString* from;
@property (nonatomic,copy) NSString* to;
@property (nonatomic,copy) NSString* content;
@property (nonatomic,assign) NSInteger index;

@end
