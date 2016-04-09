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
typedef LWConstraint* (^Margin)(CGFloat value);
typedef LWConstraint* (^Length)(CGFloat value);
typedef LWConstraint* (^EqualToStorage)(LWStorage* storage);
//typedef LWConstraint* (^EdgeInsetsToStorage)(LWStorage* storage,UIEdgeInsets insets);

@interface LWConstraint : NSObject


@property (nonatomic,copy,readonly) Margin leftMargin;
@property (nonatomic,copy,readonly) Margin rightMargin;
@property (nonatomic,copy,readonly) Margin topMargin;
@property (nonatomic,copy,readonly) Margin bottomMargin;

@property (nonatomic,copy,readonly) Length widthLength;
@property (nonatomic,copy,readonly) Length heightLength;

@property (nonatomic,copy,readonly) MarginToStorage leftMarginToStorage;
@property (nonatomic,copy,readonly) MarginToStorage rightMarginToStorage;
@property (nonatomic,copy,readonly) MarginToStorage topMarginToStorage;
@property (nonatomic,copy,readonly) MarginToStorage bottomMarginToStorage;

@property (nonatomic,copy,readonly) EqualToStorage leftMarginEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage rightMarginEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage topMarginEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage bottomMarginEquelToStorage;



















/******************************** Private ************************************/


@property (nonatomic,weak) LWStorage* superStorage;

@property (nullable,nonatomic,strong,readonly) NSNumber* left;
@property (nullable,nonatomic,strong,readonly) NSNumber* right;
@property (nullable,nonatomic,strong,readonly) NSNumber* top;
@property (nullable,nonatomic,strong,readonly) NSNumber* bottom;
@property (nullable,nonatomic,strong,readonly) NSNumber* width;
@property (nullable,nonatomic,strong,readonly) NSNumber* height;


@property (nullable,nonatomic,strong,readonly) LWConstraintObject* leftObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintObject* rightObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintObject* topObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintObject* bottomObject;


@end


@interface LWConstraintObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;
@property (nonatomic,assign) CGFloat value;

@end