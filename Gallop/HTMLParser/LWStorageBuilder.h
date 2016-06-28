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


typedef void(^LWStorageBuildingCompletion)(NSArray* storages);

@interface LWStorageBuilder : NSObject

//** 构造方法  **//
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

//** 使用默认的edgeInsets和configDictionary来创建LWstorage实例
- (void)createLWStorageWithXPath:(NSString *)xpath;

//** 使用edgeInsets和configDictionary来创建LWstorage实例
- (void)createLWStorageWithXPath:(NSString *)xpath
                      edgeInsets:(UIEdgeInsets)edgeInsets
                configDictionary:(NSDictionary *)dict;


#pragma mark - Storage getter
//** 获取生成的LWstorage实例数组  **//
- (NSArray<LWStorage *>*)storages;

//** 获取生成的LWstorage实例数组中的第一个元素  **//
- (LWStorage *)firstStorage;

//** 获取生成的LWstorage实例数组中的最后一个元素  **//
- (LWStorage *)lastStorage;

//** 获取加入回调列表的LWImageStorage数组 **//
- (NSArray<LWImageStorage *>*)imageCallbacks;

#pragma mark - Content getter
//** 获取生成的字符串 **//
- (NSString *)contents;

@end


#pragma mark - Private

@interface _LWHTMLLink : NSObject

@property (nonatomic,copy) NSString* URL;
@property (nonatomic,assign) NSRange range;

@end

@interface _LWHTMLTag : NSObject

@property (nonatomic,assign) NSRange range;
@property (nonatomic,copy) NSString* tagName;
@property (nonatomic,assign) BOOL isParent;

@end