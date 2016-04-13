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

#import <UIKit/UIKit.h>

@class LWStorage;
@class LWConstraint;
@class LWConstraintMarginObject;
@class LWConstraintEqualObject;


typedef  LWConstraint* _Nonnull  (^Margin)(CGFloat value);
typedef LWConstraint* _Nonnull (^Length)(CGFloat value);
typedef LWConstraint* _Nonnull (^Center)(CGPoint center);
typedef LWConstraint* _Nonnull (^EqualToStorage)(LWStorage* _Nonnull  storage);
typedef LWConstraint* _Nonnull (^EdgeInsetsToContainer)(UIEdgeInsets insets);
typedef LWConstraint* _Nonnull (^MarginToStorage)(LWStorage* _Nonnull storage, CGFloat value);



/**
 *  自动布局时的约束模型
 */

@interface LWConstraint : NSObject


/**
 *  左边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin _Nullable leftMargin;

/**
 *  右边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin _Nullable rightMargin;

/**
 *  上边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin _Nullable topMargin;

/**
 *  下边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin _Nullable bottomMargin;


/**
 *  宽度（绝对值）
 */
@property (nonatomic,copy,readonly) Length _Nullable widthLength;

/**
 *  高度（绝对值）
 */
@property (nonatomic,copy,readonly) Length _Nullable heightLength;


/**
 *  中心点（绝对值）
 *
 */
@property (nonatomic,copy,readonly) Center _Nullable center;


/**
 *  左边距（相对于另一个LWStorage，即这个LWStorage的左边距离另一个LWStorage的右边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage _Nullable leftMarginToStorage;

/**
 *  右边距（相对于另一个LWStorage，即这个LWStorage的右边距离另一个LWStorage的左边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage _Nullable rightMarginToStorage;

/**
 *  上边距（相对于另一个LWStorage，即这个LWStorage的上边距离另一个LWStorage的下边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage _Nullable topMarginToStorage;

/**
 *  下边距（相对于另一个LWStorage，即这个LWStorage的下边距离另一个LWStorage的上边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage _Nullable bottomMarginToStorage;



/**
 *  左边即frame.origin.x与另一个LWStorage的左边相同
 */
@property (nonatomic,copy,readonly) EqualToStorage _Nullable leftEquelToStorage;

/**
 *  右边即frame.origin.x + frame.size.width与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage _Nullable rightEquelToStorage;


/**
 *  上边即frame.origin.y与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage _Nullable topEquelToStorage;

/**
 *  下边即frame.origin.y + frame.size.heigth与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage _Nullable bottomEquelToStorage;


/**
 *  EdgeInsets（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) EdgeInsetsToContainer _Nullable edgeInsetsToContainer;




/******************************** Private ************************************/


@property (nonatomic,weak) LWStorage* _Nullable superStorage;

@property (nonatomic,strong,readonly) NSNumber* _Nullable left;
@property (nonatomic,strong,readonly) NSNumber* _Nullable right;
@property (nonatomic,strong,readonly) NSNumber* _Nullable top;
@property (nonatomic,strong,readonly) NSNumber* _Nullable bottom;
@property (nonatomic,strong,readonly) NSNumber* _Nullable width;
@property (nonatomic,strong,readonly) NSNumber* _Nullable height;
@property (nonatomic,strong,readonly) NSValue* _Nullable centerValue;

@property (nonatomic,strong,readonly) LWConstraintMarginObject* _Nullable leftMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* _Nullable rightMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* _Nullable topMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* _Nullable bottomMarginObject;


@property (nonatomic,strong,readonly) LWConstraintEqualObject* _Nullable leftEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* _Nullable rightEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* _Nullable topEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* _Nullable bottomEqualObject;

@end


@interface LWConstraintMarginObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;
@property (nonatomic,assign) CGFloat value;

@end


@interface LWConstraintEqualObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;

@end