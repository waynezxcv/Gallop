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

#import "NSObject+LWAlchemy.h"
#import "LWAlchemyPropertyInfo.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreData/CoreData.h>

static void* LWAlechmyCachedPropertyKeysKey = &LWAlechmyCachedPropertyKeysKey;
static void* LWAlechmyMapDictionaryKey = &LWAlechmyMapDictionaryKey;

@implementation NSObject(LWAlchemy)


#pragma mark - Associate

+ (NSSet *)propertysSet {
    NSSet* cachedKeys = objc_getAssociatedObject(self, LWAlechmyCachedPropertyKeysKey);
    if (cachedKeys != nil) {
        return cachedKeys;
    }
    NSMutableSet* propertysSet = [NSMutableSet set];
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property customMapper:[self mapper]];
        if (propertyInfo.propertyName && !propertyInfo.isReadonly) {
            [propertysSet addObject:propertyInfo];
        }
    }];
    objc_setAssociatedObject(self,LWAlechmyCachedPropertyKeysKey, propertysSet, OBJC_ASSOCIATION_COPY);
    return propertysSet;
}

#pragma mark - Init

+ (id)modelWithJSON:(id)json {
    NSObject* model = [[self alloc] init];
    if (model) {
        if (![json isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dic = [model dictionaryWithJSON:json];
            model = [model modelWithDictionary:dic];
        }
        else {
            model = [model modelWithDictionary:json];
        }
    }
    return model;
}

+ (id)entityWithJSON:(id)json context:(NSManagedObjectContext *)context {
    if ([self isSubclassOfClass:[NSManagedObject class]] && context) {
        NSManagedObject* model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                               inManagedObjectContext:context];
        if (model) {
            if (![json isKindOfClass:[NSDictionary class]]) {
                NSDictionary* dic = [model dictionaryWithJSON:json];
                model = [model entity:model modelWithDictionary:dic context:context];
            } else {
                model = [model entity:model modelWithDictionary:json context:context];
            }
        }
        return model;
    }
    return [self modelWithJSON:json];
}

- (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
        id value = nil;
        NSDictionary* tmp = [dictionary copy];
        for (NSInteger i = 0; i < propertyInfo.mapperName.count; i ++) {
            NSString* mapperName = propertyInfo.mapperName[i];
            value = tmp[mapperName];
            if ([value isKindOfClass:[NSDictionary class]]) {
                tmp = value;
            }
        }
        if (value != nil && ![value isEqual:[NSNull null]]) {
            _SetPropertyValue(self,propertyInfo,value);
        }
    }];
    return self;
}

- (instancetype)entity:(NSManagedObject *)object
   modelWithDictionary:(NSDictionary *)dictionary
               context:(NSManagedObjectContext *)contxt {
    if (!dictionary || dictionary == (id)kCFNull) return nil;
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
        id value = nil;
        NSDictionary* tmp = [dictionary copy];
        for (NSInteger i = 0; i < propertyInfo.mapperName.count; i ++) {
            NSString* mapperName = propertyInfo.mapperName[i];
            value = tmp[mapperName];
            if ([value isKindOfClass:[NSDictionary class]]) {
                tmp = value;
            }
        }
        if (value != nil && ![value isEqual:[NSNull null]]) {
            [self _nsmanagedObject:(NSManagedObject *)object
                          Setvalue:value
                      WithProperty:propertyInfo
                         Incontext:contxt];
        }
    }];
    return self;
}


- (NSDictionary *)dictionaryWithJSON:(id)json {
    if (!json || json == (id)kCFNull) return nil;
    NSDictionary* dic = nil;
    NSData* jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
    }
    return dic;
}

#pragma mark - Private Methods

- (void)_enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = [self class];
    BOOL stop = NO;
    while (!stop && ![cls isEqual:[NSObject class]]) {
        unsigned count = 0;
        objc_property_t* properties = class_copyPropertyList(cls, &count);
        if (properties) {
            cls = cls.superclass;
            if (properties == NULL) return;
            for (unsigned i = 0; i < count; i++) {
                block(properties[i], &stop);
                if (stop) break;
            }
            free(properties);
        }
    }
}

static void _SetPropertyValue(__unsafe_unretained id model,
                              __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                              __unsafe_unretained id value) {
    if (propertyInfo.isReadonly || propertyInfo.isDynamic) {
        return;
    }
    if (propertyInfo.isNumberType) {
        _SetNumberPropertyValue(model, propertyInfo, value);
    }
    else if (propertyInfo.isObjectType) {
        _SetObjectTypePropertyValue(model, propertyInfo, value);
    }
    else {
        _SetOtherTypePropertyValue(model,propertyInfo,value);
    }
}


static void _SetNumberPropertyValue(__unsafe_unretained id model,
                                    __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                    __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    switch (propertyInfo.type) {
        case LWPropertyTypeBool: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, bool) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, num.boolValue);
        }break;
        case LWPropertyTypeInt8:{
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int8_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int8_t)num.charValue);
        }break;
        case LWPropertyTypeUInt8: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint8_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint8_t)num.unsignedCharValue);
        }break;
        case LWPropertyTypeInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int16_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int16_t)num.shortValue);
        }break;
        case LWPropertyTypeUInt16: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint16_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint16_t)num.unsignedShortValue);
        }break;
        case LWPropertyTypeInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, int32_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (int32_t)num.intValue);
        }break;
        case LWPropertyTypeUInt32: {
            NSNumber* num = (NSNumber *)value;
            void (*objc_msgSendToSetter)(id, SEL, uint32_t) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, (uint32_t)num.unsignedIntValue);
        }break;
        case LWPropertyTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, int64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, int64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (int64_t)num.longLongValue);
            }
        }break;
        case LWPropertyTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = (NSDecimalNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, uint64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (uint64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = (NSNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL, uint64_t) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (uint64_t)num.longLongValue);
            }
        }break;
        case LWPropertyTypeFloat: {
            NSNumber* num = (NSNumber *)value;
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            void (*objc_msgSendToSetter)(id, SEL, float) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, f);
        }break;
        case LWPropertyTypeDouble:{
            NSNumber* num = (NSNumber *)value;
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*objc_msgSendToSetter)(id, SEL, double) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, d);
        }break;
        case LWPropertyTypeLongDouble: {
            NSNumber* num = (NSNumber *)value;
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*objc_msgSendToSetter)(id, SEL, long double) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, d);
        }break;
        default:break;
    }
}

static void _SetObjectTypePropertyValue(__unsafe_unretained id model,
                                        __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                        __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.nsType) {
        case LWPropertyNSObjectTypeNSString:{
            NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
            void (*objc_msgSendToSetter)(id, SEL,NSString*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, string);
        }break;
        case LWPropertyNSObjectTypeNSMutableString:{
            NSMutableString* mutableString = [NSString stringWithFormat:@"%@",value].mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL, NSMutableString*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, mutableString);
        }break;
        case LWPropertyNSObjectTypeNSValue:{
            void (*objc_msgSendToSetter)(id, SEL,NSValue*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector, value);
        }break;
        case LWPropertyNSObjectTypeNSNumber:{
            if ([value isKindOfClass:[NSNumber class]]) {
                NSNumber* number = (NSNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL,NSNumber*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, number);
            }
            else {
                NSNumber* number = NSNumberCreateFromIDType(value);
                void (*objc_msgSendToSetter)(id, SEL,NSNumber*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, number);
            }
        }break;
        case LWPropertyNSObjectTypeNSDecimalNumber:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* number = (NSDecimalNumber *)value;
                void (*objc_msgSendToSetter)(id, SEL,NSDecimalNumber*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, number);
            }
        }break;
        case LWPropertyNSObjectTypeNSData:{
            if ([value isKindOfClass:[NSData class]]) {
                NSData* data = ((NSData *)value).copy;
                void (*objc_msgSendToSetter)(id, SEL,NSData*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                void (*objc_msgSendToSetter)(id, SEL,NSData*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, data);
            }
        }break;
        case LWPropertyNSObjectTypeNSMutableData:{
            if ([value isKindOfClass:[NSData class]]) {
                NSMutableData* data = ((NSData *)value).mutableCopy;
                void (*objc_msgSendToSetter)(id, SEL,NSMutableData*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSMutableData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
                void (*objc_msgSendToSetter)(id, SEL,NSMutableData* ) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, data);
            }
        }break;
        case LWPropertyNSObjectTypeNSDate:{
            if ([value isKindOfClass:[NSDate class]]) {
                void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, value);
            } else if ([value isKindOfClass:[NSString class]]) {
                void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, LWNSDateFromString(value));
            } else {
                void (*objc_msgSendToSetter)(id, SEL,NSDate*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,LWNSDateFromString([NSString stringWithFormat:@"%@",value]));
            }
        }break;
        case LWPropertyNSObjectTypeNSURL:{
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
            void (*objc_msgSendToSetter)(id, SEL,NSURL*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,URL);
        }break;
        case LWPropertyNSObjectTypeNSArray:{
            NSArray* array = (NSArray *)value;
            void (*objc_msgSendToSetter)(id, SEL,NSArray*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,array);
        }break;
        case LWPropertyNSObjectTypeNSMutableArray:{
            NSMutableArray* mutableArray = ((NSArray *)value).mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL,NSMutableArray*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,mutableArray);
        }break;
        case LWPropertyNSObjectTypeNSDictionary:{
            NSDictionary* dictionary = (NSDictionary *)value;
            void (*objc_msgSendToSetter)(id, SEL,NSDictionary*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,dictionary);
        }break;
        case LWPropertyNSObjectTypeNSMutableDictionary:{
            NSMutableDictionary* mutableDict = ((NSDictionary *)value).mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL,NSMutableDictionary*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,mutableDict);
        }break;
        case LWPropertyNSObjectTypeNSSet:{
            NSSet* set = (NSSet *)value;
            void (*objc_msgSendToSetter)(id, SEL,NSSet*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,set);
        }break;
        case LWPropertyNSObjectTypeNSMutableSet:{
            NSMutableSet* mutableSet = ((NSSet *)value).mutableCopy;
            void (*objc_msgSendToSetter)(id, SEL,NSMutableSet*) = (void*)objc_msgSend;
            objc_msgSendToSetter((id)model, setterSelector,mutableSet);
        }break;
        default:{
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(id)nil);
            } else if ([value isKindOfClass:propertyInfo.cls]) {
                void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(id)value);
            }
            else if ([value isKindOfClass:[NSDictionary class]]) {
                NSObject* child = nil;
                if (propertyInfo.getter) {
                    SEL getter = NSSelectorFromString(propertyInfo.getter);
                    child = ((id (*)(id, SEL))(void *) objc_msgSend)((id)model,getter);
                }
                if (child) {
                    [child modelWithDictionary:value];
                } else {
                    Class cls = propertyInfo.cls;
                    child = [cls new];
                    [child modelWithDictionary:value];
                    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
                    void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
                    objc_msgSendToSetter((id)model,setterSelector,child);
                }
            }
            else {
                //id type
                void (*objc_msgSendToSetter)(id, SEL,id) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(id)value);
            }
        }
            break;
    }
}

static void _SetOtherTypePropertyValue(__unsafe_unretained id model,
                                       __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                       __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL setterSelector = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.type) {
        case LWPropertyTypeBlock: {
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL, void (^)()) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (void (^)())NULL);
            } else if ([value isKindOfClass:LWNSBlockClass()]) {
                void (*objc_msgSendToSetter)(id, SEL, void (^)()) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(void (^)())value);
            }
        }break;
        case LWPropertyTypeClass:{
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(Class)NULL);
            } else {
                Class cls = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(value);
                    if (cls) {
                        void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                        objc_msgSendToSetter((id)model, setterSelector,(Class)cls);
                    }
                } else {
                    cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                            objc_msgSendToSetter((id)model, setterSelector, (Class)value);
                        } else {
                            void (*objc_msgSendToSetter)(id, SEL,Class) = (void*)objc_msgSend;
                            objc_msgSendToSetter((id)model, setterSelector,(Class)cls);
                        }
                    }
                }
            }
        case LWPropertyTypeSEL: {
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,SEL) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector,(SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) {
                    void (*objc_msgSendToSetter)(id, SEL,SEL) = (void*)objc_msgSend;
                    objc_msgSendToSetter((id)model, setterSelector,sel);
                }
            }
        }break;
        case LWPropertyTypeCFString:
        case LWPropertyTypePointer:{
            if (isNull) {
                void (*objc_msgSendToSetter)(id, SEL,void*) = (void*)objc_msgSend;
                objc_msgSendToSetter((id)model, setterSelector, (void *)NULL);
            } else if ([value isKindOfClass:[NSValue class]]) {
                NSValue* nsValue = value;
                if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                    void (*objc_msgSendToSetter)(id, SEL, void* ) = (void*)objc_msgSend;
                    objc_msgSendToSetter((id)model, setterSelector,nsValue.pointerValue);
                }
            }
        }break;
        case LWPropertyTypeUnion:
        case LWPropertyTypeStruct:
        case LWPropertyTypeCFArray:
            if ([value isKindOfClass:[NSValue class]]) {
                const char* valueType = ((NSValue *)value).objCType;
                Ivar ivar = class_getInstanceVariable([propertyInfo.cls class],[propertyInfo.ivarName UTF8String]);
                const char* metaType = ivar_getTypeEncoding(ivar);
                if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                    [model setValue:value forKey:propertyInfo.propertyName];
                }
            }break;
        case LWPropertyTypeUnkonw:
        case LWPropertyTypeVoid:
        default:break;
        }
    }
}

- (void)_nsmanagedObject:(NSManagedObject *)object
                Setvalue:(id)value
            WithProperty:(LWAlchemyPropertyInfo *)propertyInfo
               Incontext:(NSManagedObjectContext *)context {
    switch (propertyInfo.nsType) {
        case LWPropertyNSObjectTypeNSDate: {
            NSDate* date = LWNSDateFromString([NSString stringWithFormat:@"%@",value]);
            [object setValue:date forKey:propertyInfo.propertyName];
        }break;
        case LWPropertyNSObjectTypeNSURL: {
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",value]];
            [object setValue:URL forKey:propertyInfo.propertyName];
        }break;
        case LWPropertyNSObjectTypeNSString:{
            [object setValue:[NSString stringWithFormat:@"%@",value] forKey:propertyInfo.propertyName];
        }break;
        case LWPropertyNSObjectTypeNSNumber:{
            NSNumber* number = NSNumberCreateFromIDType(value);
            [object setValue:number forKey:propertyInfo.propertyName];
        }break;
        case LWPropertyNSObjectTypeNSDecimalNumber:
        case LWPropertyNSObjectTypeNSMutableString:
        case LWPropertyNSObjectTypeNSValue:
        case LWPropertyNSObjectTypeNSData:
        case LWPropertyNSObjectTypeNSMutableData:
        case LWPropertyNSObjectTypeNSArray:
        case LWPropertyNSObjectTypeNSMutableArray:
        case LWPropertyNSObjectTypeNSDictionary:
        case LWPropertyNSObjectTypeNSMutableDictionary:
        case LWPropertyNSObjectTypeNSSet:
        case LWPropertyNSObjectTypeNSMutableSet:{
            [object setValue:value forKey:propertyInfo.propertyName];
        }break;
        default:{
            if (propertyInfo.isIdType) {
                [object setValue:value forKey:propertyInfo.propertyName];
            } else {
                if (propertyInfo.cls) {
                    Class cls = propertyInfo.cls;
                    NSManagedObject* one = [cls entityWithJSON:value context:context];
                    [object setValue:one forKey:propertyInfo.propertyName];
                }
            }
        }break;
    }
}


static NSNumber* NSNumberCreateFromIDType(__unsafe_unretained id value) {
    static NSCharacterSet* dot;
    static NSDictionary* dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{@"TRUE" :   @(YES),
                @"True" :   @(YES),
                @"true" :   @(YES),
                @"FALSE" :  @(NO),
                @"False" :  @(NO),
                @"false" :  @(NO),
                @"YES" :    @(YES),
                @"Yes" :    @(YES),
                @"yes" :    @(YES),
                @"NO" :     @(NO),
                @"No" :     @(NO),
                @"no" :     @(NO),
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    if (!value || value == (id)kCFNull) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSNumber* num = dic[value];
        if (num) {
            if (num == (id)kCFNull) return nil;
            return num;
        }
        if ([(NSString *)value rangeOfCharacterFromSet:dot].location != NSNotFound) {
            const char* cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        } else {
            const char* cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}


static inline NSDate* LWNSDateFromString(__unsafe_unretained NSString *string) {
    NSTimeInterval timeInterval = [string floatValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

static inline Class LWNSBlockClass() {
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

- (NSString *)lwDescription {
    NSMutableString* des = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",self]];
    NSSet* propertysSet = self.class.propertysSet;
    [propertysSet enumerateObjectsUsingBlock:^(LWAlchemyPropertyInfo* propertyInfo, BOOL * _Nonnull stop) {
        NSString* d = [NSString stringWithFormat:@"<%@(%@):%@>,\n",propertyInfo.propertyName,
                       [[self valueForKey:propertyInfo.propertyName] class],
                       [self valueForKey:propertyInfo.propertyName]];
        [des appendString:d];
    }];
    return des;
}

+ (NSDictionary *)mapper {
    return nil;
}

@end
