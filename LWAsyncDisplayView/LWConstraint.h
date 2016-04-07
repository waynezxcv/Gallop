//
//  LWConstraint.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWStorage.h"

@class LWConstraint;
@class LWConstraintObject;

typedef LWConstraint* (^MarginToStorage)(LWStorage* storage, CGFloat value);

@interface LWConstraint : NSObject

@property (nonatomic, copy, readonly) MarginToStorage leftMargin;
@property (nonatomic, copy, readonly) MarginToStorage rightMargin;
@property (nonatomic, copy, readonly) MarginToStorage topMargin;
@property (nonatomic, copy, readonly) MarginToStorage bottomMargin;


@property (nonatomic,strong) LWConstraintObject* leftObject;
@property (nonatomic,strong) LWConstraintObject* rightObject;
@property (nonatomic,strong) LWConstraintObject* topObject;
@property (nonatomic,strong) LWConstraintObject* bottomObject;

@end


@interface LWConstraintObject : NSObject

@property (nonatomic,strong) LWStorage* referenceStorage;
@property (nonatomic,assign) CGFloat value;

@end