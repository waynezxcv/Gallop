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

/***  点击链接 ***/
- (void)lwhtmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
   didCilickedTextStorage:(LWTextStorage *)textStorage
                 linkdata:(id)data;

/***  点击LWImageStorage ***/
- (void)lwhtmlDisplayView:(LWHTMLDisplayView *)asyncDisplayView
  didCilickedImageStorage:(LWImageStorage *)imageStorage;

@end

@interface LWHTMLDisplayView : UITableView

@property (nonatomic,strong) LWHTMLLayout* layout;
@property (nonatomic,weak) id <LWHTMLDisplayViewDelegate> displayDelegate;
@property (nonatomic,strong,readonly) LWStorageBuilder* storageBuilder;
@property (nonatomic,strong) NSData* data;
@property (nonatomic,weak) UIViewController* parentVC;//如果要使用图片浏览器，需要设置parentVC

- (id)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC;

@end


