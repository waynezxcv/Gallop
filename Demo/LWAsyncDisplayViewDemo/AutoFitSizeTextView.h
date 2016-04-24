//
//  AutoFitSizeTextView.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/24.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AutoFitSizeTextView;

@protocol AutoFitSizeTextViewDelegate <NSObject>

@optional


- (void)textView:(AutoFitSizeTextView *)textView heightChanged:(NSInteger)height;

@end

@interface AutoFitSizeTextView : UITextView


@property (nonatomic,weak) id <AutoFitSizeTextViewDelegate> fitSizeDelegate;

@end
