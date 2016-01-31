//
//  LWTextLayout.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/2/1.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>


@interface LWTextLayout : NSObject

@property (nonatomic,readonly,strong) NSAttributedString* text;
@property (nonatomic,readonly) CTFramesetterRef frameSetter;
@property (nonatomic,readonly) CTFrameRef frame;
@property (nonatomic,readonly) CGSize boundsSize;
@property (nonatomic,readonly) CGRect boundsRect;
@property (nonatomic,readonly) CGMutablePathRef textPath;


- (LWTextLayout *)initWithText:(NSString *)text
                          font:(UIFont *)font
                 textAlignment:(NSTextAlignment)textAlignment
                     linespace:(CGFloat)linespace
                     textColor:(UIColor *)textColor
                          rect:(CGRect)rect;

- (void)drawTextLayoutIncontext:(CGContextRef)context;

@end
