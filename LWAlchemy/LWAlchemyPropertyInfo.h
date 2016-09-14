/*
 https://github.com/waynezxcv/LWAlchemy

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
#import <objc/runtime.h>



typedef NS_ENUM(NSUInteger, LWTypeKind) {
    LWTypeKindUnknow                = 1,
    LWTypeKindNumber                = 2,
    LWTypeKindCFObject              = 3,
    LWTypeKindNSOrCustomObject      = 4,
};

typedef NS_OPTIONS(NSUInteger, LWTypeProperty) {
    LWTypePropertyPlaceholder    = 1 << 1,
    LWTypePropertyReadonly       = 1 << 2,
    LWTypePropertyDynamic        = 1 << 3,
    LWTypePropertyCopy           = 1 << 4,
    LWTypePropertyRetain         = 1 << 5,
    LWTypePropertyWeak           = 1 << 6,
    LWTypePropertyNonatomic      = 1 << 7,
};

typedef NS_ENUM(NSUInteger, LWType) {
    LWTypeVoid,
    LWTypeBool,
    LWTypeInt8,
    LWTypeUInt8,
    LWTypeInt16,
    LWTypeUInt16,
    LWTypeInt32,
    LWTypeUInt32,
    LWTypeInt64,
    LWTypeUInt64,
    LWTypeFloat,
    LWTypeDouble,
    LWTypeLongDouble,
    LWTypeClass,
    LWTypeSEL,
    LWTypeCFString,
    LWTypePointer,
    LWTypeCFArray,
    LWTypeUnion,
    LWTypeStruct,
    LWTypeBlock,
};

typedef NS_ENUM(NSUInteger, LWNSType) {
    LWNSTypeNSUnknown,
    LWNSTypeId,
    LWNSTypeNSString,
    LWNSTypeNSMutableString,
    LWNSTypeNSValue,
    LWNSTypeNSNumber,
    LWNSTypeNSDecimalNumber,
    LWNSTypeNSData,
    LWNSTypeNSMutableData,
    LWNSTypeNSDate,
    LWNSTypeNSURL,
    LWNSTypeNSArray,
    LWNSTypeNSMutableArray,
    LWNSTypeNSDictionary,
    LWNSTypeNSMutableDictionary,
    LWNSTypeNSSet,
    LWNSTypeNSMutableSet,
};

/**
 *  对objc_property_t的封装
 */
@interface LWAlchemyPropertyInfo : NSObject

@property (nonatomic,assign,readonly) objc_property_t property;
@property (nonatomic,strong,readonly) NSString* propertyName;
@property (nonatomic,strong,readonly) NSArray* mapperName;
@property (nonatomic,strong,readonly) NSString* ivarName;
@property (nonatomic,assign,readonly) Ivar ivar;
@property (nonatomic,assign,readonly) Class cls;
@property (nonatomic,strong,readonly) NSString* getter;
@property (nonatomic,strong,readonly) NSString* setter;
@property (nonatomic,assign,readonly) LWTypeKind typeKind;
@property (nonatomic,assign,readonly) LWTypeProperty typeProperty;
@property (nonatomic,assign,readonly) LWType type;
@property (nonatomic,assign,readonly) LWNSType nsType;


- (id)initWithProperty:(objc_property_t)property customMapper:(NSDictionary *)mapper;


@end
