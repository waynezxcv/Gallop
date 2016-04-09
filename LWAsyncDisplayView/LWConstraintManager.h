//
//  LWConstraintManager.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/9.
//  Copyright © 2016年 WayneInc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "LWConstraint.h"

@interface LWConstraintManager : NSObject

+ (void)lw_makeConstraint:(LWConstraint* )constraint;
+ (void)lw_makeConstraint:(LWConstraint* )constraint containerSize:(CGSize)size;

@end
