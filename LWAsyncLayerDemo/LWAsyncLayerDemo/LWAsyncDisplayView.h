//
//  LWAsyncDisplayView.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWAsyncDisplayTask;


@protocol LWAsyncDisplayViewDelegate <NSObject>

@required

- (LWAsyncDisplayTask *)newAsyncDisplayTask;

@end


@interface LWAsyncDisplayView : UIView

@property (nonatomic,weak) id <LWAsyncDisplayViewDelegate> delegate;


@end


//将要开始绘制
typedef void(^WillBeginDisplay)(CALayer* layer);
//绘制
typedef void(^Displaying)(CGContextRef context,CGSize size);
//绘制完成
typedef void(^DidFinishDisplay)(CALayer* layer ,BOOL finished);




@interface LWAsyncDisplayTask : NSObject

@property (nonatomic, copy) WillBeginDisplay willDisplay;

//绘制
@property (nonatomic, copy) Displaying display;

//绘制完成
@property (nonatomic, copy) DidFinishDisplay didDisplay;

@end


@interface LWTransaction : NSObject


+ (LWTransaction *)transactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object;


- (void)commit;

@end