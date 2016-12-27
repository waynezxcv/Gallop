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
#import "LWStorage.h"


/**
 *  HTML渲染布局模型
 */
@interface LWHTMLLayout : NSObject <NSCoding>

/**
 *  添加一个LWStorage对象
 *
 *  @param storage 一个LWStorage对象
 */
- (void)addStorage:(LWStorage *)storage;

/**
 *  从一个数组中添加LWStorage对象
 *
 *  @param storages 一个包含LWStorage对象的数组
 */
- (void)addStorages:(NSArray <LWStorage *>*)storages;

/**
 *  在当前所添加的LWStorage对象的后面拼接一个LWStorage对象
 *
 *  @param storage 一个LWStorage对象
 */
- (void)appendStorage:(LWStorage *)storage;

/**
 *  在当前所添加的LWStorage对象的后面拼接若干个LWStorage对象，它们被顺序地放在数组中
 *
 *  @param storage 一个LWStorage对象
 */
- (void)appendStorages:(NSArray <LWStorage *>*)storages;

/**
 *  获取所有的LWStorage对象
 *
 *  @return 当前包含的所有LWStorage对象
 */
- (NSArray *)allItems;


@end
