//
//  AsyncDisplayHelper.h
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/1/21.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface AsyncDisplayHelper : NSObject

/*
 * 获取单例对象
 */

+ (AsyncDisplayHelper *)sharedDisplayHelper;

/*
 * 绘制文字
 */

- (void)draText:(NSString *)text
         inRect:(CGRect)rect
           font:(UIFont *)font
  textAlignment:(NSTextAlignment)textAlignmet
      lineSpace:(CGFloat)lineSpace
      textColor:(UIColor *)textColor
        context:(CGContextRef)context;


/*
 * 绘制图片
 */
- (void)drawImage:(UIImage *)image
             rect:(CGRect)rect
          context:(CGContextRef)context;


@end
