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
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, LWPropertyType) {
    LWPropertyTypeUnkonw        = 0,
    LWPropertyTypeVoid          = 1,
    LWPropertyTypeBool          = 2,
    LWPropertyTypeInt8          = 3,
    LWPropertyTypeUInt8         = 4,
    LWPropertyTypeInt16         = 5,
    LWPropertyTypeUInt16        = 6,
    LWPropertyTypeInt32         = 7,
    LWPropertyTypeUInt32        = 8,
    LWPropertyTypeInt64         = 9,
    LWPropertyTypeUInt64        = 10,
    LWPropertyTypeFloat         = 11,
    LWPropertyTypeDouble        = 12,
    LWPropertyTypeLongDouble    = 13,
    LWPropertyTypeClass         = 14,
    LWPropertyTypeSEL           = 15,
    LWPropertyTypeCFString      = 16,
    LWPropertyTypePointer       = 17,
    LWPropertyTypeCFArray       = 18,
    LWPropertyTypeUnion         = 19,
    LWPropertyTypeStruct        = 20,
    LWPropertyTypeObject        = 21,
    LWPropertyTypeBlock         = 22
};


typedef NS_ENUM (NSUInteger, LWPropertyNSObjectType) {
    LWPropertyNSObjectTypeNSUnknown             = 0,
    LWPropertyNSObjectTypeNSString              = 1,
    LWPropertyNSObjectTypeNSMutableString       = 2,
    LWPropertyNSObjectTypeNSValue               = 3,
    LWPropertyNSObjectTypeNSNumber              = 4,
    LWPropertyNSObjectTypeNSDecimalNumber       = 5,
    LWPropertyNSObjectTypeNSData                = 6,
    LWPropertyNSObjectTypeNSMutableData         = 7,
    LWPropertyNSObjectTypeNSDate                = 8,
    LWPropertyNSObjectTypeNSURL                 = 9,
    LWPropertyNSObjectTypeNSArray               = 10,
    LWPropertyNSObjectTypeNSMutableArray        = 11,
    LWPropertyNSObjectTypeNSDictionary          = 12,
    LWPropertyNSObjectTypeNSMutableDictionary   = 13,
    LWPropertyNSObjectTypeNSSet                 = 14,
    LWPropertyNSObjectTypeNSMutableSet          = 15
};


@interface LWAlchemyPropertyInfo : NSObject

@property (nonatomic,assign,readonly) objc_property_t property;
@property (nonatomic,strong,readonly) NSString* propertyName;
@property (nonatomic,strong,readonly) NSArray* mapperName;
@property (nonatomic,strong,readonly) NSString* ivarName;
@property (nonatomic,assign,readonly) Ivar ivar;
@property (nonatomic,assign,readonly) LWPropertyType type;
@property (nonatomic,assign,readonly) LWPropertyNSObjectType nsType;
@property (nonatomic,copy,readonly) NSString* typeEncoding;
@property (nonatomic,assign,readonly) Class cls;
@property (nonatomic,strong,readonly) NSString* getter;
@property (nonatomic,strong,readonly) NSString* setter;
@property (nonatomic,assign,readonly,getter=isReadonly) BOOL readonly;
@property (nonatomic,assign,readonly,getter=isDynamic) BOOL dynamic;
@property (nonatomic,assign,readonly,getter=isNumberType) BOOL numberType;
@property (nonatomic,assign,readonly,getter=isObjectType) BOOL objectType;
@property (nonatomic,assign,readonly,getter=isIdType) BOOL idType;
@property (nonatomic,assign,readonly,getter=isFoundationType) BOOL foundationType;

- (id)initWithProperty:(objc_property_t)property customMapper:(NSDictionary *)mapper;

@end
