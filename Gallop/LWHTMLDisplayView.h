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

@class LWLayout;
@class LWHTMLDisplayView;
@class LWTextStorage;
@class LWStorageBuilder;
@class LWImageStorage;
@class LWHTMLLayout;

@protocol LWHTMLDisplayViewDelegate <NSObject>

@optional

/**
 *  点击链接时可以在这个代理方法里收到回调。
 *
 *  @param asyncDisplayView LWTextStorage所处的LWAsyncDisplayView
 *  @param textStorage      点击的那个LWTextStorage对象
 *  @param data             添加点击链接时所附带的信息。
 */
- (void)lw_htmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
   didCilickedTextStorage:(LWTextStorage *)textStorage
                 linkdata:(id)data;

/**
 *  点击LWImageStorage时，可以在这个代理方法里收到回调
 *
 *  @param asyncDisplayView LWImageStorage所处的LWAsyncDisplayView
 *  @param imageStorage     点击的那个LWImageStorage对象
 */

- (void)lw_htmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
   didSelectedImageStorage:(LWImageStorage *)imageStorage
               totalImages:(NSArray *)images
                 superView:(UIView *)superView
       inSuperViewPosition:(CGRect)position
                     index:(NSUInteger)index;


/**
 *  当给某个LWHTMLTextConfig对象或LWHTMLImageConfig对象设置了extraDisplayIdentifier时，可以通过比较
 *  extraDisplayIdentifier字符串进行额外的绘制
 *
 *  @param asyncDisplayView  所处的LWAsyncDisplayView
 *  @param context           CGContextRef
 *  @param size              绘制区域大小
 *  @param displayIdentifier extraDisplayIdentifier字符串
 */
- (void)lw_htmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
     extraDisplayIncontext:(CGContextRef)context
                      size:(CGSize)size
         displayIdentifier:(NSString *)displayIdentifier;

@end


/**
 *  HTML解析视图
 */
@interface LWHTMLDisplayView : UITableView

@property (nonatomic,strong) LWHTMLLayout* layout;//布局模型
@property (nonatomic,weak) id <LWHTMLDisplayViewDelegate> displayDelegate;//代理对象
@property (nonatomic,strong,readonly) LWStorageBuilder* storageBuilder;//用于解析HTML创建LWStorage
@property (nonatomic,strong) NSData* data;//HTML文件

@end


