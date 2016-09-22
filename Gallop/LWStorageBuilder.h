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
#import "LWLayout.h"
#import "LWHTMLTextConfig.h"
#import "LWHTMLImageConfig.h"
#import "LWHTMLNode.h"

typedef void(^LWStorageBuildingCompletion)(NSArray* storages);

@interface LWStorageBuilder : NSObject

@property (nonatomic,strong,readonly) LWHTMLNode* tree;


/**
 *  构造方法
 *
 *  @param data     HTML数据
 *  @param encoding 编码方式
 *
 *  @return LWStorageBuilder对象
 */
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

/**
 *  使用默认的edgeInsets和configDictionary来创建LWstorage实例
 *
 *  @param xpath xpath变大时
 */
- (void)createLWStorageWithXPath:(NSString *)xpath;

/**
 *  使用edgeInsets和configDictionary来创建LWstorage实例
 *
 *  @param xpath      xpath表达式
 *  @param edgeInsets 通过edgeInsets来设置边缘内嵌的大小
 *  @param dict       一个字典，key对应需要设置的标签名，value为一个LWHTMLConfig对象，
 *                    用来设置对应标签的式样。
 */
- (void)createLWStorageWithXPath:(NSString *)xpath
             paragraphEdgeInsets:(UIEdgeInsets)edgeInsets
                configDictionary:(NSDictionary *)dict;

/**
 *  获取生成的LWstorage实例数组
 *
 *  @return 一个包含所有的LWStorage对象的数组
 */
- (NSArray<LWStorage *>*)storages;

/**
 *  获取生成的LWstorage实例数组中的第一个元素
 *
 *  @return 第一个LWStorage对象
 */
- (LWStorage *)firstStorage;

/**
 *  获取生成的LWstorage实例数组中的最后一个元素
 *
 *  @return 最后一个LWStorage对象
 */
- (LWStorage *)lastStorage;

/**
 *   获取加入图片浏览器回调列表的LWImageStorage数组
 *
 *  @return 一个包含了加入图片浏览器回调列表LWImageStorage对象的数组
 */
- (NSArray<LWImageStorage *>*)imageCallbacks;

/**
 *  获取文本内容
 *
 *  @return HTML的文本内容
 */
- (NSString *)contents;

/**
 *  获取HTML树
 */

- (LWHTMLNode *)tree;

@end


