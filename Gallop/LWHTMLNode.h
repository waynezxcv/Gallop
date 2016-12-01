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

#import <Foundation/Foundation.h>

/**
 *  结点
 */

@interface LWHTMLNode : NSObject <NSCopying,NSMutableCopying,NSCoding>

@property (nonatomic,strong) LWHTMLNode* parent;//双亲结点
@property (nonatomic,strong) LWHTMLNode* firstChild;//子结点
@property (nonatomic,strong) LWHTMLNode* rightSib;//右兄弟结点
@property (nonatomic,strong) NSMutableArray* children;//子结点
@property (nonatomic,copy) NSString* elementName;//元素标签名
@property (nonatomic,copy) NSString* contentString;//内容
@property (nonatomic,strong) NSMutableDictionary* attributeDict;//属性字典
@property (nonatomic,assign) NSRange range;//若是文本内容，在父级结点中的位置
@property (nonatomic,assign) BOOL isTag;//是否是标签结点

/**
 *  构造方法
 *
 *  @param elementName 标签名称
 *
 *  @return 一个LWHTMLNode实例
 */
- (id)initWithElementName:(NSString *)elementName;

/**
 *  构造方法
 *
 *  @param elementName   标签名称
 *  @param attributeDict 属性
 *
 *  @return 一个HTMLNode实例
 */
- (id)initWithElementName:(NSString *)elementName attributeDict:(NSDictionary *)attributeDict;


/**
 *  构造方法
 *
 *  @param contentString 文本内容
 *
 *  @return 一个HTMLNode实例
 */
- (id)initWithContentString:(NSString *)contentString;

@end
