//
//  LWLabel.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTextLayout.h"


@interface LWLabel : UIView

@property (nonatomic,copy) NSString* text;
@property (nonatomic,strong) UIFont* font;
@property (nonatomic,strong) UIColor* textColor;
@property (nonatomic,strong) UIColor* shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSLineBreakMode lineBreakMode;
@property (nonatomic,copy) NSAttributedString* attributedText;
@property (nonatomic,strong) UITextView* lable;


- (id)initWithFrame:(CGRect)frame;

@end
