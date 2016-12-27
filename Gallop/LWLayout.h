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
#import "LWStorage.h"
#import "LWTextStorage.h"
#import "LWImageStorage.h"




@protocol LWLayoutProtocol <NSObject>

/**
 *  添加一个LWStorage对象
 *
 *  @param storage 一个LWStorage对象
 */
- (void)addStorage:(LWStorage *)storage;

/**
 *  添加一个包含LWStorage对象的数组的所有元素到LWLayout
 *
 *  @param storages 一个包含LWStorage对象的数组
 */
- (void)addStorages:(NSArray <LWStorage *> *)storages;

/**
 *  移除一个LWStorage对象
 *
 *  @param storage 一个LWStorage对象
 */
- (void)removeStorage:(LWStorage *)storage;

/**
 *  移除一个包含LWStorage对象的数组的所有元素
 *
 *  @param storages 一个包含LWStorage对象的数组
 */
- (void)removeStorages:(NSArray <LWStorage *> *)storages;

/**
 *  获取到一个建议的高度，主要用于UITabelViewCell的高度设定。
 *  你可以在UITableVeiw的代理方法中直接返回这个高度，来方便的动态设定Cell高度
 *
 *  @param bottomMargin 距离底部的间距
 *
 *  @return 建议的高度
 */
- (CGFloat)suggestHeightWithBottomMargin:(CGFloat)bottomMargin;


/**
 *  获取包含LWTextStorage的数组
 *
 */
- (NSMutableArray<LWTextStorage *>*)textStorages;

/**
 *  获取包含LWImageStorage的数组
 *
 */
- (NSMutableArray<LWImageStorage *>*)imageStorages;


/**
 *  获取包含所有的LWStorage的数组
 *
 */
- (NSMutableArray<LWStorage *>*) totalStorages;


@end


/**
 *  Gallop的布局模型。其中包含了LWStorage及其子类的对象。
 */

@interface LWLayout : NSObject <LWLayoutProtocol,NSCoding>



@end
