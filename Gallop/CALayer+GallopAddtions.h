//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//  Created by 刘微 on 16/3/7.
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAsyncDisplayView
//  See LICENSE for this sample’s licensing information
//

#import <UIKit/UIKit.h>

@interface CALayer(GallopAddtions)


/**
 *  设置Image并设置圆角半径，同时避免离屏渲染
 *
 */
- (void)lw_setImage:(UIImage *)image
      containerSize:(CGSize)size
       cornerRadius:(CGFloat)cornerRadius
cornerBackgroundColor:(UIColor *)color
  cornerBorderColor:(UIColor *)borderColor
         borderWidth:(CGFloat)borderWidth;


/**
 *  在主线程RunLoop空闲时执行setContents
 *
 */
- (void)lw_delaySetContents:(id)contents;

@end
