//
//  CommentView.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/23.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoFitSizeTextView.h"



#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define RGB(A,B,C,D) [UIColor colorWithRed:A/255.0f green:B/255.0f blue:C/255.0f alpha:D]


typedef void(^PressSendBlock)(NSString * content);

@interface CommentView : UIView<AutoFitSizeTextViewDelegate>

@property (nonatomic,strong) AutoFitSizeTextView* textView;
@property (nonatomic,copy) NSString* placeHolder;
@property (nonatomic,copy) PressSendBlock sendBlock;


- (id)initWithFrame:(CGRect)frame sendBlock:(PressSendBlock)sendBlock;

@end
