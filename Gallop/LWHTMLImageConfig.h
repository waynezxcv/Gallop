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


@interface LWHTMLImageConfig : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,assign) BOOL autolayoutHeight;//是否在图片下载完成后，按图片比例自适应高度，默认YES
@property (nonatomic,assign) CGSize size;//图片的大小
@property (nonatomic,strong) UIImage* placeholder;//占位图
@property (nonatomic,assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;//是否响应用户事件
@property (nonatomic,assign) BOOL needAddToImageCallbacks;//是否需要将这个Image包含到点击事件的回调数组里去
@property (nonatomic,assign) UIEdgeInsets edgeInsets;//设置该storage的edgeInsets，优先级高于paragraphEdgeInsets
@property (nonatomic,copy) NSString* extraDisplayIdentifier;//额外绘制的标记字符串
@property (nonatomic,assign) UIViewContentMode contentMode;//效果UIImageView的同名属性

/**
 *  获取一个默认样式的图片设置
 *
 *  @return 一个默认样式的LWHTMLImageConfig对象
 */
+ (LWHTMLImageConfig *)defaultsConfig;

@end
