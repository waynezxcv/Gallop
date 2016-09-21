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


#pragma mark - Cache

+ (NSSet *)propertysSet {
    NSSet* cachedKeys = objc_getAssociatedObject(self, LWAlechmyCachedPropertyKeysKey);
    if (cachedKeys != nil) {
        return cachedKeys;
    }
    NSMutableSet* propertysSet = [NSMutableSet set];
    [self _enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        LWAlchemyPropertyInfo* propertyInfo = [[LWAlchemyPropertyInfo alloc] initWithProperty:property customMapper:[self mapper]];
        if (propertyInfo.propertyName &&
            !(propertyInfo.typeProperty & LWTypePropertyReadonly)) {
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
            }
            else {
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
            _setPropertyValue(self,propertyInfo,value);
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

- (NSDictionary *)dictionaryFromModel {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSSet* propertysSet = self.class.propertysSet;
    for (LWAlchemyPropertyInfo* propertyInfo in propertysSet) {
        NSString* key = propertyInfo.propertyName;
        id value;
        switch (propertyInfo.typeKind) {
            case LWTypeKindNumber:
                value = _getNumberTypePropertyValue(self,propertyInfo);
                break;
            default:
                value = _getObjectTypePropertyValue(self,propertyInfo);
                break;
        }
        if (value) {
            [dict setObject:value forKey:key];
        }
    }
    return dict.copy;
}

#pragma mark - Private

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

#pragma mark - Getter

static inline NSNumber* _getNumberTypePropertyValue(__unsafe_unretained id model,
                                                    __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo) {
    if (!propertyInfo.getter) {
        return nil;
    }
    SEL sel = NSSelectorFromString(propertyInfo.getter);
    switch (propertyInfo.type) {
        case LWTypeBool: {
            bool (*msgSend)(id, SEL) = (bool(*)(id,SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeInt8:{
            int8_t (*msgSend)(id, SEL) = (int8_t(*)(id,SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeUInt8: {
            uint8_t (*msgSend)(id, SEL) = (uint8_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeInt16: {
            int16_t (*msgSend)(id, SEL) = (int16_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeUInt16: {
            uint16_t (*msgSend)(id, SEL) = (uint16_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeInt32: {
            int32_t (*msgSend)(id, SEL) = (int32_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeUInt32: {
            uint32_t (*msgSend)(id, SEL) = (uint32_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeInt64: {
            int64_t (*msgSend)(id, SEL) = (int64_t (*)(id, SEL))objc_msgSend;
            return @(msgSend(model,sel));
        }
        case LWTypeFloat: {
            float (*msgSend)(id, SEL) = (float (*)(id, SEL))objc_msgSend;
            float number = msgSend(model,sel);
            if (isnan(number)) {
                return nil;
            }
            return @(number);
        }
        case LWTypeDouble:{
            double (*msgSend)(id, SEL) = (double (*)(id, SEL))objc_msgSend;
            double number = msgSend(model,sel);
            if (isnan(number)) {
                return nil;
            }
            return @(number);
        }
        case LWTypeLongDouble: {
            double (*msgSend)(id, SEL) = (double (*)(id, SEL))objc_msgSend;
            double number = msgSend(model,sel);
            if (isnan(number)) {
                return nil;
            }
            return @(number);
        }
        default:
            return nil;
    }
}

static inline id _getObjectTypePropertyValue(__unsafe_unretained id model,
                                             __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo) {
    if (!propertyInfo.getter) {
        return nil;
    }
    SEL sel = NSSelectorFromString(propertyInfo.getter);
    id (*msgSend)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    return msgSend(model,sel);
}


#pragma mark - Setter

static inline void _setPropertyValue(__unsafe_unretained id model,
                                     __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                     __unsafe_unretained id value) {
    if ((propertyInfo.typeProperty & LWTypePropertyReadonly) ||
        (propertyInfo.typeProperty & LWTypePropertyDynamic)) {
        return;
    }
    switch (propertyInfo.typeKind) {
        case LWTypeKindNumber:
            _setNumberTypePropertyValue(model, propertyInfo,value);
            break;
        case LWTypeKindCFObject:
            _setCFTypePropertyValue(model,propertyInfo,value);
            break;
        case LWTypeKindNSOrCustomObject:
            _setObjectTypePropertyValue(model, propertyInfo,value);
            break;
        case LWTypeKindUnknow:
        default:break;
    }
}

static inline void _setNumberTypePropertyValue(__unsafe_unretained id model,
                                               __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                               __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL sel = NSSelectorFromString(propertyInfo.setter);
    switch (propertyInfo.type) {
        case LWTypeBool: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, bool) = (void (*)(id, SEL, bool))objc_msgSend;
            msgSend((id)model, sel, num.boolValue);
        }break;
        case LWTypeInt8:{
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, int8_t) = (void (*)(id, SEL, int8_t))objc_msgSend;
            msgSend((id)model, sel, (int8_t)num.charValue);
        }break;
        case LWTypeUInt8: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, uint8_t) = (void (*)(id, SEL, uint8_t))objc_msgSend;
            msgSend((id)model, sel, (uint8_t)num.unsignedCharValue);
        }break;
        case LWTypeInt16: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, int16_t) = (void (*)(id, SEL, int16_t))objc_msgSend;
            msgSend((id)model, sel, (int16_t)num.shortValue);
        }break;
        case LWTypeUInt16: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, uint16_t) = (void (*)(id, SEL, uint16_t) )objc_msgSend;
            msgSend((id)model, sel, (uint16_t)num.unsignedShortValue);
        }break;
        case LWTypeInt32: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, int32_t) = (void (*)(id, SEL, int32_t))objc_msgSend;
            msgSend((id)model, sel, (int32_t)num.intValue);
        }break;
        case LWTypeUInt32: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            void (*msgSend)(id, SEL, uint32_t) = (void (*)(id, SEL, uint32_t))objc_msgSend;
            msgSend((id)model, sel, (uint32_t)num.unsignedIntValue);
        }break;
        case LWTypeInt64: {
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = NSNumberCreateFromIDType(value);
                void (*msgSend)(id, SEL, int64_t) = (void (*)(id, SEL, int64_t))objc_msgSend;
                msgSend((id)model, sel, (int64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = NSNumberCreateFromIDType(value);
                void (*msgSend)(id, SEL, int64_t) = (void (*)(id, SEL, int64_t))objc_msgSend;
                msgSend((id)model, sel, (int64_t)num.longLongValue);
            }
        }break;
        case LWTypeUInt64:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSNumber* num = NSNumberCreateFromIDType(value);
                void (*msgSend)(id, SEL, uint64_t) = (void (*)(id, SEL, uint64_t))objc_msgSend;
                msgSend((id)model, sel, (uint64_t)num.stringValue.longLongValue);
            } else {
                NSNumber* num = NSNumberCreateFromIDType(value);
                void (*msgSend)(id, SEL, uint64_t) = (void (*)(id, SEL, uint64_t))objc_msgSend;
                msgSend((id)model, sel, (uint64_t)num.longLongValue);
            }
        }break;
        case LWTypeFloat: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            void (*msgSend)(id, SEL, float) = (void (*)(id, SEL, float))objc_msgSend;
            msgSend((id)model, sel, f);
        }break;
        case LWTypeDouble:{
            NSNumber* num = NSNumberCreateFromIDType(value);
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*msgSend)(id, SEL, double) = (void (*)(id, SEL, double))objc_msgSend;
            msgSend((id)model, sel, d);
        }break;
        case LWTypeLongDouble: {
            NSNumber* num = NSNumberCreateFromIDType(value);
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            void (*msgSend)(id, SEL, long double) = (void(*)(id, SEL, long double))objc_msgSend;
            msgSend((id)model, sel, d);
        }break;
        default:break;
    }
}

static inline void _setObjectTypePropertyValue(__unsafe_unretained id model,
                                               __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                               __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL sel = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.nsType) {
        case LWNSTypeNSString:{
            NSString* string = [NSString stringWithFormat:@"%@",(NSString *)value];
            void (*msgSend)(id, SEL,NSString*) = (void (*)(id, SEL,NSString*))objc_msgSend;
            msgSend((id)model, sel, string);
        }break;
        case LWNSTypeNSMutableString:{
            NSMutableString* mutableString = [NSString stringWithFormat:@"%@",value].mutableCopy;
            void (*msgSend)(id, SEL, NSMutableString*) = (void (*)(id, SEL, NSMutableString*))objc_msgSend;
            msgSend((id)model, sel, mutableString);
        }break;
        case LWNSTypeNSValue:{
            void (*msgSend)(id, SEL,NSValue*) = (void (*)(id, SEL,NSValue*))objc_msgSend;
            msgSend((id)model, sel, value);
        }break;
        case LWNSTypeNSNumber:{
            if ([value isKindOfClass:[NSNumber class]]) {
                NSNumber* number = (NSNumber *)value;
                void (*msgSend)(id, SEL,NSNumber*) = (void (*)(id, SEL,NSNumber*))objc_msgSend;
                msgSend((id)model, sel, number);
            }
            else {
                NSNumber* number = NSNumberCreateFromIDType(value);
                void (*msgSend)(id, SEL,NSNumber*) = (void (*)(id, SEL,NSNumber*))objc_msgSend;
                msgSend((id)model, sel, number);
            }
        }break;
        case LWNSTypeNSDecimalNumber:{
            if ([value isKindOfClass:[NSDecimalNumber class]]) {
                NSDecimalNumber* number = (NSDecimalNumber *)value;
                void (*msgSend)(id, SEL,NSDecimalNumber*) = (void (*)(id, SEL,NSDecimalNumber*))objc_msgSend;
                msgSend((id)model, sel, number);
            }
        }break;
        case LWNSTypeNSData:{
            if ([value isKindOfClass:[NSData class]]) {
                NSData* data = ((NSData *)value).copy;
                void (*msgSend)(id, SEL,NSData*) = (void (*)(id, SEL,NSData*))objc_msgSend;
                msgSend((id)model, sel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
                void (*msgSend)(id, SEL,NSData*) = (void (*)(id, SEL,NSData*))objc_msgSend;
                msgSend((id)model, sel, data);
            }
        }break;
        case LWNSTypeNSMutableData:{
            if ([value isKindOfClass:[NSData class]]) {
                NSMutableData* data = ((NSData *)value).mutableCopy;
                void (*msgSend)(id, SEL,NSMutableData*) = (void (*)(id, SEL,NSMutableData*))objc_msgSend;
                msgSend((id)model, sel, data);
            } else if ([value isKindOfClass:[NSString class]]) {
                NSMutableData* data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
                void (*msgSend)(id, SEL,NSMutableData*) = (void (*)(id, SEL,NSMutableData* ))objc_msgSend;
                msgSend((id)model, sel, data);
            }
        }break;
        case LWNSTypeNSDate:{
            if ([value isKindOfClass:[NSDate class]]) {
                void (*msgSend)(id, SEL,NSDate*) = (void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSend((id)model, sel, value);
            } else if ([value isKindOfClass:[NSString class]]) {
                void (*msgSend)(id, SEL,NSDate*) = (void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSend((id)model, sel, LWNSDateFromString(value));
            } else {
                void (*msgSend)(id, SEL,NSDate*) = ( void (*)(id, SEL,NSDate*))objc_msgSend;
                msgSend((id)model, sel,LWNSDateFromString([NSString stringWithFormat:@"%@",value]));
            }
        }break;
        case LWNSTypeNSURL:{
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)value]];
            void (*msgSend)(id, SEL,NSURL*) = (void (*)(id, SEL,NSURL*))objc_msgSend;
            msgSend((id)model, sel,URL);
        }break;
        case LWNSTypeNSArray:{
            NSArray* array = (NSArray *)value;
            void (*msgSend)(id, SEL,NSArray*) = (void (*)(id, SEL,NSArray*))objc_msgSend;
            msgSend((id)model, sel,array);
        }break;
        case LWNSTypeNSMutableArray:{
            NSMutableArray* mutableArray = ((NSArray *)value).mutableCopy;
            void (*msgSend)(id, SEL,NSMutableArray*) = (void (*)(id, SEL,NSMutableArray*))objc_msgSend;
            msgSend((id)model, sel,mutableArray);
        }break;
        case LWNSTypeNSDictionary:{
            NSDictionary* dictionary = (NSDictionary *)value;
            void (*msgSend)(id, SEL,NSDictionary*) = (void (*)(id, SEL,NSDictionary*))objc_msgSend;
            msgSend((id)model, sel,dictionary);
        }break;
        case LWNSTypeNSMutableDictionary:{
            NSMutableDictionary* mutableDict = ((NSDictionary *)value).mutableCopy;
            void (*msgSend)(id, SEL,NSMutableDictionary*) = (void (*)(id, SEL,NSMutableDictionary*))objc_msgSend;
            msgSend((id)model, sel,mutableDict);
        }break;
        case LWNSTypeNSSet:{
            NSSet* set = (NSSet *)value;
            void (*msgSend)(id, SEL,NSSet*) = (void (*)(id, SEL,NSSet*))objc_msgSend;
            msgSend((id)model, sel,set);
        }break;
        case LWNSTypeNSMutableSet:{
            NSMutableSet* mutableSet = ((NSSet *)value).mutableCopy;
            void (*msgSend)(id, SEL,NSMutableSet*) = (void (*)(id, SEL,NSMutableSet*))objc_msgSend;
            msgSend((id)model, sel,mutableSet);
        }break;
        default:{
            if (isNull) {
                void (*msgSend)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
                msgSend((id)model, sel,(id)nil);
            } else if ([value isKindOfClass:propertyInfo.cls]) {
                void (*msgSend)(id, SEL,id) = (void(*)(id, SEL,id))objc_msgSend;
                msgSend((id)model, sel,(id)value);
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
                    SEL sel = NSSelectorFromString(propertyInfo.setter);
                    void (*msgSend)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
                    msgSend((id)model,sel,child);
                }
            } else {
                //id type
                void (*msgSend)(id, SEL,id) = (void (*)(id, SEL,id))objc_msgSend;
                msgSend((id)model, sel,(id)value);
            }
        }
            break;
    }
}

static inline void _setCFTypePropertyValue(__unsafe_unretained id model,
                                           __unsafe_unretained LWAlchemyPropertyInfo* propertyInfo,
                                           __unsafe_unretained id value) {
    if (!propertyInfo.setter) {
        return;
    }
    SEL sel = NSSelectorFromString(propertyInfo.setter);
    BOOL isNull = (value == (id)kCFNull);
    switch (propertyInfo.type) {
        case LWTypeBlock: {
            if (isNull) {
                void (*msgSend)(id, SEL, void (^)()) = (void (*)(id, SEL, void (^)()))objc_msgSend;
                msgSend((id)model, sel, (void (^)())NULL);
            } else if ([value isKindOfClass:LWNSBlockClass()]) {
                void (*msgSend)(id, SEL, void (^)()) = (void (*)(id, SEL, void (^)()))objc_msgSend;
                msgSend((id)model, sel,(void (^)())value);
            }
        }break;
        case LWTypeClass:{
            if (isNull) {
                void (*msgSend)(id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                msgSend((id)model, sel,(Class)NULL);
            } else {
                Class cls = nil;
                if ([value isKindOfClass:[NSString class]]) {
                    cls = NSClassFromString(value);
                    if (cls) {
                        void (*msgSend)(id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                        msgSend((id)model, sel,(Class)cls);
                    }
                } else {
                    cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            void (*msgSend)(id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                            msgSend((id)model, sel, (Class)value);
                        } else {
                            void (*msgSend)(id, SEL,Class) = (void (*)(id, SEL,Class))objc_msgSend;
                            msgSend((id)model, sel,(Class)cls);
                        }
                    }
                }
            }
        case LWTypeSEL: {
            if (isNull) {
                void (*msgSend)(id, SEL,SEL) = (void (*)(id, SEL,SEL))objc_msgSend;
                msgSend((id)model, sel,(SEL)NULL);
            } else if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) {
                    void (*msgSend)(id, SEL,SEL) = (void (*)(id, SEL,SEL))objc_msgSend;
                    msgSend((id)model, sel,sel);
                }
            }
        }break;
        case LWTypeCFString:
        case LWTypePointer:{
            if (isNull) {
                void (*msgSend)(id, SEL,void*) = (void (*)(id, SEL,void*))objc_msgSend;
                msgSend((id)model, sel, (void *)NULL);
            } else if ([value isKindOfClass:[NSValue class]]) {
                NSValue* nsValue = value;
                if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                    void (*msgSend)(id, SEL, void*) = (void (*)(id, SEL, void*))objc_msgSend;
                    msgSend((id)model, sel,nsValue.pointerValue);
                }
            }
        }break;
        case LWTypeUnion:
        case LWTypeStruct:
        case LWTypeCFArray:
            if ([value isKindOfClass:[NSValue class]]) {
                const char* valueType = ((NSValue *)value).objCType;
                Ivar ivar = class_getInstanceVariable([propertyInfo.cls class],[propertyInfo.ivarName UTF8String]);
                const char* metaType = ivar_getTypeEncoding(ivar);
                if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                    [model setValue:value forKey:propertyInfo.propertyName];
                }
            }break;
        case LWTypeVoid:
        default:break;
        }
    }
}

#pragma mark - NSManagedObject Setter

- (void)_nsmanagedObject:(NSManagedObject *)object
                Setvalue:(id)value
            WithProperty:(LWAlchemyPropertyInfo *)propertyInfo
               Incontext:(NSManagedObjectContext *)context {
    switch (propertyInfo.nsType) {
        case LWNSTypeNSDate: {
            NSDate* date = LWNSDateFromString([NSString stringWithFormat:@"%@",value]);
            [object setValue:date forKey:propertyInfo.propertyName];
        }break;
        case LWNSTypeNSURL: {
            NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",value]];
            [object setValue:URL forKey:propertyInfo.propertyName];
        }break;
        case LWNSTypeNSString:{
            [object setValue:[NSString stringWithFormat:@"%@",value] forKey:propertyInfo.propertyName];
        }break;
        case LWNSTypeNSNumber:{
            NSNumber* number = NSNumberCreateFromIDType(value);
            [object setValue:number forKey:propertyInfo.propertyName];
        } break;
        case LWNSTypeNSDecimalNumber:
        case LWNSTypeNSMutableString:
        case LWNSTypeNSValue:
        case LWNSTypeNSData:
        case LWNSTypeNSMutableData:
        case LWNSTypeNSArray:
        case LWNSTypeNSMutableArray:
        case LWNSTypeNSDictionary:
        case LWNSTypeNSMutableDictionary:
        case LWNSTypeNSSet:
        case LWNSTypeNSMutableSet:{
            [object setValue:value forKey:propertyInfo.propertyName];
        }break;
        default:{
            if (propertyInfo.nsType == LWNSTypeId) {
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

#pragma mark - Others

static inline NSNumber* NSNumberCreateFromIDType(__unsafe_unretained id value) {
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

#pragma mark - Description

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

#pragma mark - Mapper

+ (NSDictionary *)mapper {
    return nil;
}

@end
