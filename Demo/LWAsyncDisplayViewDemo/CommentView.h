//
//  CommentView.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/23.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoFitSizeTextView.h"


typedef void(^PressSendBlock)(NSString * content);

@interface CommentView : UIView<AutoFitSizeTextViewDelegate>

@property (nonatomic,strong) AutoFitSizeTextView* textView;
@property (nonatomic,copy) NSString* placeHolder;
@property (nonatomic,copy) PressSendBlock sendBlock;


- (id)initWithFrame:(CGRect)frame sendBlock:(PressSendBlock)sendBlock;

@end
