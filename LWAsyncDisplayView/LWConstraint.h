//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
////
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWStorage.h"



@class LWConstraint;
@class LWConstraintMarginObject;
@class LWConstraintEqualObject;




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




@property (nonatomic,copy,readonly) EqualToStorage leftEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage rightEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage topEquelToStorage;
@property (nonatomic,copy,readonly) EqualToStorage bottomEquelToStorage;














/******************************** Private ************************************/


@property (nonatomic,weak) LWStorage* superStorage;

@property (nullable,nonatomic,strong,readonly) NSNumber* left;
@property (nullable,nonatomic,strong,readonly) NSNumber* right;
@property (nullable,nonatomic,strong,readonly) NSNumber* top;
@property (nullable,nonatomic,strong,readonly) NSNumber* bottom;
@property (nullable,nonatomic,strong,readonly) NSNumber* width;
@property (nullable,nonatomic,strong,readonly) NSNumber* height;


@property (nullable,nonatomic,strong,readonly) LWConstraintMarginObject* leftMarginObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintMarginObject* rightMarginObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintMarginObject* topMarginObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintMarginObject* bottomMarginObject;


@property (nullable,nonatomic,strong,readonly) LWConstraintEqualObject* leftEqualObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintEqualObject* rightEqualObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintEqualObject* topEqualObject;
@property (nullable,nonatomic,strong,readonly) LWConstraintEqualObject* bottomEqualObject;

@end


@interface LWConstraintMarginObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;
@property (nonatomic,assign) CGFloat value;

@end


@interface LWConstraintEqualObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;

@end