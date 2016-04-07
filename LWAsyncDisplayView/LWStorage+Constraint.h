//
//  LWConstraintManager.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWConstraint.h"
#import "LWStorage.h"


typedef LWConstraint* (^MarginToStorage)(LWStorage* storage, CGFloat value);

@interface LWStorage(Constraint)

@property (nonatomic, copy, readonly) MarginToStorage leftMargin;
@property (nonatomic, copy, readonly) MarginToStorage rightMargin;
@property (nonatomic, copy, readonly) MarginToStorage topMargin;
@property (nonatomic, copy, readonly) MarginToStorage bottomMargin;

@end
