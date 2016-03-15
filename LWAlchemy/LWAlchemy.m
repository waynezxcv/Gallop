//  The MIT License (MIT)
//  Copyright (c) 2016 Wayne Liu <liuweself@126.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
//
//
//  Created by 刘微 on 16/1/20.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAlchemy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "LWAlchemyPropertyInfo.h"

@interface LWAlchemy ()

@property (nonatomic,strong) NSDictionary* mapDict;

@end


@implementation LWAlchemy:NSObject

- (id)initWithJSON:(id)JSON JSONKeyPathsByPropertyKey:(NSDictionary *)mapDict{
    self = [super init];
    if (self) {
        self.mapDict = mapDict;
        NSDictionary* dic = [self _dictionaryWithJSON:JSON];
        self = [self _modelWithDictionary:dic];
    }
    return self;
}

- (NSDictionary *)_dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary* dic = nil;
    NSData* jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}


- (void)_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = [self class];
    BOOL stop = NO;
    while (!stop && ![cls isEqual:[LWAlchemy class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        if (properties) {
            cls = cls.superclass;
            if (properties == NULL) continue;
            for (unsigned i = 0; i < count; i++) {
                block(properties[i], &stop);
                if (stop) break;
            }
            free(properties);
        }
    }
}

- (instancetype)_modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property];
        NSString* mapKey = self.mapDict[propertyInfo.propertyName];
        id object = dictionary[mapKey];
        _SetPropertyValue(self,propertyInfo,object);
    }];
    return self;
}


static void _SetPropertyValue(__unsafe_unretained id model,
                              __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                              __unsafe_unretained id value) {
    if (propertyInfo.isReadonly) {
        return;
    }
    SEL setter = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.type) {
        case LWTypeBool: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, setter, num.boolValue);
        }break;
        case LWTypeInt8:{
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model,setter, (int8_t)num.charValue);
        }break;
        case LWTypeUInt8: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model,setter, (uint8_t)num.unsignedCharValue);
        }break;
        case LWTypeInt16: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model,setter, (int16_t)num.shortValue);
        }break;
        case LWTypeUInt16: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model,setter, (uint16_t)num.unsignedShortValue);
        }break;
        case LWTypeInt32: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model,setter, (int32_t)num.intValue);
        }break;
        case LWTypeUInt32: {
            NSNumber* num = (NSNumber *)value;
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model,setter, (uint32_t)num.unsignedIntValue);
        }break;
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* num = (NSDecimalNumber *)value;
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model,setter, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model,setter, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* num = (NSDecimalNumber *)value;
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model,setter, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model,setter, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeFloat: {
            NSNumber* num = (NSNumber *)value;
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model,setter, f);
        }break;

        case LWTypeDouble:{
            NSNumber* num = (NSNumber *)value;
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model,setter, d);
        }break;
        case LWTypeLongDouble: {
            NSNumber* num = (NSNumber *)value;
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model,setter, (long double)d);
        }break;
        case LWTypeSEL: {
            if (isNull) {
                ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,setter, (SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)model,setter, (SEL)sel);
            }
        }break;
        case LWTypeObject: {
            if ([propertyInfo.cls class] == [NSString class]) {
                NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
                ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)model,setter,string);
            }
            else if ([propertyInfo.cls class] == [NSMutableString class]) {
                NSMutableString* mutableString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",value]];;
                ((void (*)(id, SEL, NSMutableString*))(void *) objc_msgSend)((id)model,setter, mutableString);
            }
            else if ([propertyInfo.cls class] == [NSValue class]) {
                if ([value isKindOfClass:[NSValue class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, value);
                }
            }
            else if ([propertyInfo.cls class] == [NSNumber class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    NSNumber* num = (NSNumber *)value;
                    ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)model,setter, num);
                }
            }
            else if ([propertyInfo.cls class] == [NSDecimalNumber class]) {
                if ([value isKindOfClass:[NSNumber class]]) {
                    NSDecimalNumber* num = (NSDecimalNumber *)value;
                    ((void (*)(id, SEL, NSDecimalNumber*))(void *) objc_msgSend)((id)model,setter, num);
                }
            }
            else if ([propertyInfo.cls class] == [NSData class]) {
                if ([value isKindOfClass:[NSData class]]) {
                    NSData *data = ((NSData *)value).copy;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
                } else if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
                }
            }
            else if ([propertyInfo.cls class] == [NSMutableData class]) {
                if ([value isKindOfClass:[NSData class]]) {
                    NSMutableData *data = ((NSData *)value).mutableCopy;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
                } else if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, data);
                }
            }
            else if ([propertyInfo.cls class] == [NSDate class]) {
                if ([value isKindOfClass:[NSDate class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, value);
                } else if ([value isKindOfClass:[NSString class]]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter,LWNSDateFromString(value));
                } else {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter,LWNSDateFromString([NSString stringWithFormat:@"%@",value]));
                }
            }
            else if ([propertyInfo.cls class] == [NSURL class]) {
                NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
                ((void (*)(id, SEL, NSURL *))(void *) objc_msgSend)((id)model,setter, URL);
            }
            else if ([propertyInfo.cls class] == [NSArray class]) {
                NSArray* array = (NSArray *)value;
                ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, array);
            }
            else if ([propertyInfo.cls class] == [NSMutableArray class]) {
                NSMutableArray* mutableArray = [[NSMutableArray alloc] initWithArray:(NSArray *)value];
                ((void (*)(id, SEL, NSArray *))(void *) objc_msgSend)((id)model,setter, mutableArray);
            }
            else if ([propertyInfo.cls class] == [NSDictionary class]) {
                NSDictionary* dictionary = (NSDictionary *)value;
                ((void (*)(id, SEL, NSDictionary *))(void *) objc_msgSend)((id)model,setter, dictionary);
            }
            else if ([propertyInfo.cls class] == [NSMutableDictionary class]) {
                NSMutableDictionary* mutableDict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)value];
                ((void (*)(id, SEL, NSMutableDictionary *))(void *) objc_msgSend)((id)model,setter, mutableDict);
            }
            else if ([propertyInfo.cls class] == [NSSet class]) {
                NSSet* set = (NSSet *)value;
                ((void (*)(id, SEL, NSSet *))(void *) objc_msgSend)((id)model,setter, set);
            }
            else if ([propertyInfo.cls class] == [NSMutableSet class]) {
                NSMutableSet* mutableSet = [[NSMutableSet alloc] initWithSet:(NSSet *)value];
                ((void (*)(id, SEL, NSMutableSet *))(void *) objc_msgSend)((id)model,setter, mutableSet);
            }
            else {
                SEL setter = NSSelectorFromString(propertyInfo.setter);
                if (isNull) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, (id)nil);
                } else if ([value isKindOfClass:propertyInfo.cls]) {
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)model,setter, (id)value);
                }
            }
        }break;
        case LWTypeBlock: {
            if (isNull) {
                ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, setter, (void (^)())NULL);
            } else if ([value isKindOfClass:LWNSBlockClass()]) {
                ((void (*)(id, SEL, void (^)()))(void *) objc_msgSend)((id)model, setter, (void (^)())value);
            }
        }break;
        case LWTypeClass:{
            if (isNull) {
                ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)NULL);
            } else {
                Class cls = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(value);
                    if (cls) {
                        ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)cls);
                    }
                } else {
                    cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)value);
                        } else {
                            ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)model,setter, (Class)cls);
                        }
                    }
                }
            }
        }break;
        case LWTypeUnkonw: {
        }break;
        case LWTypeVoid: {
        }break;
        case LWTypeCFString: {
        }break;
        case LWTypePointer: {
        }break;
        case LWTypeUnion: {
        }break;
        case LWTypeStruct: {
        }break;
        case LWTypeCFArray:{
        }break;
        default:break;
    }
}



static NSDate* LWNSDateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}


static  Class LWNSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

@end
