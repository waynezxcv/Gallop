//
//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweiself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//
//
//  Copyright © 2016年 Wayne Liu. All rights reserved.
//  https://github.com/waynezxcv/LWAlchemy
//  See LICENSE for this sample’s licensing information
//

#import <Foundation/Foundation.h>

@class NSManagedObject;
@class NSManagedObjectContext;

@interface NSObject(LWAlchemy)

/**
 *  由JSON生成model
 *
 */
+ (id)modelWithJSON:(id)json;


/**
 *  由JSON生成entity（CoreData）
 *
 */
+ (id)entityWithJSON:(id)json context:(NSManagedObjectContext *)context;

/**
 *  由NSDictionary生成Model
 *
 */
- (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  由NSDictionary生成Entity（CoreData）
 *
 */
- (instancetype)entity:(NSManagedObject *)object
   modelWithDictionary:(NSDictionary *)dictionary
               context:(NSManagedObjectContext *)contxt;

/**
 *  由JSON生成NSDictionary
 *
 */
- (NSDictionary *)dictionaryWithJSON:(id)json;


/**
 *  自定义的映射
 *
 */
+ (NSDictionary *)mapper;


/**
 *  获取对象的描述
 *
 */
- (NSString *)lwDescription;

@end
