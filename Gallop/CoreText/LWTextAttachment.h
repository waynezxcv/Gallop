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

//*** Text附件 ***//

#define LWTextAttachmentAttributeName @"LWTextAttachmentKey"

@interface LWTextAttachment : NSObject<NSCopying>

@property (nonatomic,strong) id content;
@property (nonatomic,assign) NSRange range;//在string中的range
@property (nonatomic,assign) CGRect frame;//frame
@property (nonatomic,strong) NSURL* URL;//URL
@property (nonatomic,assign) UIViewContentMode contentMode;
@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic,strong) NSDictionary* userInfo;//自定义的一些信息

/**
 *  构造方法
 *
 *  @param object 可以是UIImage对象、UIView对象、CALayer对象。
 *  如果是UIImage对象，会使用CoreGraphics方法来绘制
 *
 *  @return LWTextAttachment实例对象
 */
+ (id)lw_textAttachmentWithContent:(id)content;

@end


