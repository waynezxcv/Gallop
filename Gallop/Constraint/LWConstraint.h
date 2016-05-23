/*
 https://github.com/waynezxcv/Gallop
 
 Copyright (c) 2016 waynezxcv <liuweiself@126.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import <UIKit/UIKit.h>

@class LWStorage;
@class LWConstraint;
@class LWConstraintMarginObject;
@class LWConstraintEqualObject;


typedef LWConstraint* (^Margin)(CGFloat value);
typedef LWConstraint* (^Length)(CGFloat value);
typedef LWConstraint* (^Center)(CGPoint center);
typedef LWConstraint* (^EqualToStorage)(LWStorage* storage);
typedef LWConstraint* (^EdgeInsetsToContainer)(UIEdgeInsets insets);
typedef LWConstraint* (^MarginToStorage)(LWStorage* storage, CGFloat value);



/***  自动布局时的约束模型 ***/

@interface LWConstraint : NSObject


/**
 *  左边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin leftMargin;

/**
 *  右边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin rightMargin;

/**
 *  上边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin topMargin;

/**
 *  下边距（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) Margin bottomMargin;


/**
 *  宽度（绝对值）
 */
@property (nonatomic,copy,readonly) Length widthLength;

/**
 *  高度（绝对值）
 */
@property (nonatomic,copy,readonly) Length heightLength;


/**
 *  中心点（绝对值）
 *
 */
@property (nonatomic,copy,readonly) Center center;


/**
 *  左边距（相对于另一个LWStorage，即这个LWStorage的左边距离另一个LWStorage的右边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage leftMarginToStorage;

/**
 *  右边距（相对于另一个LWStorage，即这个LWStorage的右边距离另一个LWStorage的左边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage rightMarginToStorage;

/**
 *  上边距（相对于另一个LWStorage，即这个LWStorage的上边距离另一个LWStorage的下边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage topMarginToStorage;

/**
 *  下边距（相对于另一个LWStorage，即这个LWStorage的下边距离另一个LWStorage的上边的距离）
 */
@property (nonatomic,copy,readonly) MarginToStorage bottomMarginToStorage;



/**
 *  左边即frame.origin.x与另一个LWStorage的左边相同
 */
@property (nonatomic,copy,readonly) EqualToStorage leftEquelToStorage;

/**
 *  右边即frame.origin.x + frame.size.width与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage rightEquelToStorage;


/**
 *  上边即frame.origin.y与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage topEquelToStorage;

/**
 *  下边即frame.origin.y + frame.size.heigth与另一个LWStorage相同
 */
@property (nonatomic,copy,readonly) EqualToStorage bottomEquelToStorage;


/**
 *  EdgeInsets（相对于Container，即装载这个LWStorage的LWAsyncDisplayView）
 */
@property (nonatomic,copy,readonly) EdgeInsetsToContainer edgeInsetsToContainer;




/******************************** Private ************************************/


@property (nonatomic,weak) LWStorage* superStorage;

@property (nonatomic,strong,readonly) NSNumber* left;
@property (nonatomic,strong,readonly) NSNumber* right;
@property (nonatomic,strong,readonly) NSNumber* top;
@property (nonatomic,strong,readonly) NSNumber* bottom;
@property (nonatomic,strong,readonly) NSNumber* width;
@property (nonatomic,strong,readonly) NSNumber* height;
@property (nonatomic,strong,readonly) NSValue* centerValue;

@property (nonatomic,strong,readonly) LWConstraintMarginObject* leftMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* rightMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* topMarginObject;
@property (nonatomic,strong,readonly) LWConstraintMarginObject* bottomMarginObject;


@property (nonatomic,strong,readonly) LWConstraintEqualObject* leftEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* rightEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* topEqualObject;
@property (nonatomic,strong,readonly) LWConstraintEqualObject* bottomEqualObject;

@end


@interface LWConstraintMarginObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;
@property (nonatomic,assign) CGFloat value;

@end


@interface LWConstraintEqualObject : NSObject

@property (nullable,nonatomic,strong) LWStorage* referenceStorage;

@end