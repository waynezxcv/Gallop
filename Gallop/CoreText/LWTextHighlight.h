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

#define LWTextLinkAttributedName @"LWTextLinkAttributedName"
#define LWTextBackgroundColorAttributedName @"LWTextBackgroundColorAttributedName"

//*** Text高亮（点击链接时） ***//

@interface LWTextHighlight : NSObject <NSCopying>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* linkColor;
@property (nonatomic,strong) UIColor* hightlightColor;//高亮颜色
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) id content;//内容
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

@end


//*** Text背景颜色（用来代替NSBackgroundColor） ***//

@interface LWTextBackgroundColor : NSObject  <NSCopying>

@property (nonatomic,assign) NSRange range;//在字符串的range
@property (nonatomic,strong) UIColor* backgroundColor;
@property (nonatomic,copy) NSArray<NSValue *>* positions;//位置数组
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

@end