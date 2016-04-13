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


#import "LWAlchemyPropertyInfo.h"

@interface LWAlchemyPropertyInfo ()

@property (nonatomic,assign) objc_property_t property;
@property (nonatomic,strong) NSString* propertyName;
@property (nonatomic,strong) NSArray* mapperName;
@property (nonatomic,strong) NSString* ivarName;
@property (nonatomic,assign) LWPropertyType type;
@property (nonatomic,assign) LWPropertyNSObjectType nsType;
@property (nonatomic,assign) Class cls;
@property (nonatomic,strong) NSString* getter;
@property (nonatomic,strong) NSString* setter;
@property (nonatomic,assign,getter=isReadonly) BOOL readonly;
@property (nonatomic,assign,getter=isDynamic) BOOL dynamic;
@property (nonatomic,assign,getter=isIdType) BOOL idType;
@property (nonatomic,assign,getter=isNumberType) BOOL numberType;
@property (nonatomic,assign,getter=isObjectType) BOOL objectType;
@property (nonatomic,assign,getter=isFoundationType) BOOL foundationType;
@property (nonatomic,copy) NSString* typeEncoding;

@end

@implementation LWAlchemyPropertyInfo

- (id)initWithProperty:(objc_property_t)property customMapper:(NSDictionary *)mapper {
    self = [super init];
    if (self) {
        self.readonly = NO;
        self.dynamic = NO;
        self.idType = NO;
        self.numberType = NO;
        self.objectType = NO;
        self.foundationType = NO;
        self.property = property;
        unsigned int attrCount;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attributes[i].name[0]) {
                case 'T': {
                    if (attributes[i].value) {
                        self.type = _GetPropertyInfoType(self, attributes[i].value);
                        if (self.type == LWPropertyTypeObject) {
                            self.cls = _GetPropertyInfoClass(attributes[i].value);
                            self.nsType = _GetObjectNSType(self.cls);
                            if (self.nsType != LWPropertyNSObjectTypeNSUnknown) {
                                self.foundationType = YES;
                            }
                        }
                    }
                } break;
                case 'V': {
                    if (attributes[i].value) {
                        self.ivarName = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                case 'G': {
                    if (attributes[i].value) {
                        self.getter = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                case 'S': {
                    if (attributes[i].value) {
                        self.setter = [NSString stringWithUTF8String:attributes[i].value];
                    }
                }break;
                case 'R': {
                    self.readonly = YES;
                } break;
                case 'D': {
                    self.dynamic = YES;
                } break;
                default:break;
            }
        }
        if (attributes) {
            free(attributes);
            attributes = NULL;
        }
        self.propertyName =  @(property_getName(property));
        self.mapperName = @[@(property_getName(property))];
        if (mapper[self.propertyName]) {
            NSMutableArray* mappedToKeyArray = [[NSMutableArray alloc] init];
            NSArray* keyPath = [mapper[self.propertyName] componentsSeparatedByString:@"."];
            if (keyPath.count > 1) {
                for (NSString* oneKey in keyPath) {
                    [mappedToKeyArray addObject:oneKey];
                }
            } else {
                [mappedToKeyArray addObject:mapper[self.propertyName]];
            }
            self.mapperName = mappedToKeyArray;
        }
        if (self.propertyName) {
            if (!self.getter) {
                self.getter = self.propertyName;
            }
            if (!self.setter) {
                self.setter = [NSString stringWithFormat:@"set%@%@:",
                               [self.propertyName substringToIndex:1].uppercaseString,
                               [self.propertyName substringFromIndex:1]];
            }
        }
    }
    return self;
}

- (void)setType:(LWPropertyType)type {
    _type = type;
    switch (_type) {
        case LWPropertyTypeBool:
        case LWPropertyTypeInt8:
        case LWPropertyTypeUInt8:
        case LWPropertyTypeInt16:
        case LWPropertyTypeUInt16:
        case LWPropertyTypeInt32:
        case LWPropertyTypeUInt32:
        case LWPropertyTypeInt64:
        case LWPropertyTypeUInt64:
        case LWPropertyTypeFloat:
        case LWPropertyTypeDouble:
        case LWPropertyTypeLongDouble:self.numberType = YES;break;
        case LWPropertyTypeObject:self.objectType = YES;break;
        case LWPropertyTypeBlock:break;
        case LWPropertyTypeClass:break;
        case LWPropertyTypeUnkonw:break;
        case LWPropertyTypeVoid:break;
        case LWPropertyTypeCFString:break;
        case LWPropertyTypeCFArray:break;
        case LWPropertyTypeUnion:break;
        case LWPropertyTypeStruct:break;
        case LWPropertyTypePointer:break;
        case LWPropertyTypeSEL:break;
        default:break;
    }
}

static inline LWPropertyNSObjectType _GetObjectNSType(Class cls) {
    if (!cls) return LWPropertyNSObjectTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSString class]]) return LWPropertyNSObjectTypeNSString;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return LWPropertyNSObjectTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return LWPropertyNSObjectTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return LWPropertyNSObjectTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return LWPropertyNSObjectTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return LWPropertyNSObjectTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return LWPropertyNSObjectTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return LWPropertyNSObjectTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return LWPropertyNSObjectTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return LWPropertyNSObjectTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return LWPropertyNSObjectTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return LWPropertyNSObjectTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return LWPropertyNSObjectTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return LWPropertyNSObjectTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return LWPropertyNSObjectTypeNSSet;
    return LWPropertyNSObjectTypeNSUnknown;
}


static LWPropertyType _GetPropertyInfoType(LWAlchemyPropertyInfo* propertyInfo, const char* value) {
    size_t len = strlen(value);
    if (len == 0) return LWPropertyTypeUnkonw;
    switch (* value) {
        case 'v': {return LWPropertyTypeVoid;}
        case 'B': {return LWPropertyTypeBool;}
        case 'c': {return LWPropertyTypeInt8;}
        case 'C': {return LWPropertyTypeUInt8;}
        case 's': {return LWPropertyTypeInt16;}
        case 'S': {return LWPropertyTypeUInt16;}
        case 'i': {return LWPropertyTypeInt32;}
        case 'I': {return LWPropertyTypeUInt32;}
        case 'l': {return LWPropertyTypeInt32;}
        case 'L': {return LWPropertyTypeUInt32;}
        case 'q': {return LWPropertyTypeInt64;}
        case 'Q': {return LWPropertyTypeUInt64;}
        case 'f': {return LWPropertyTypeFloat;}
        case 'd': {return LWPropertyTypeDouble;}
        case 'D': {return LWPropertyTypeLongDouble;}
        case '#': {return LWPropertyTypeClass;}
        case ':': {return LWPropertyTypeSEL;}
        case '*': {return LWPropertyTypeCFString;}
        case '^': {return LWPropertyTypePointer;}
        case '[': {return LWPropertyTypeCFArray;}
        case '(': {return LWPropertyTypeUnion;}
        case '{': {return LWPropertyTypeStruct;}
        case '@': {
            if (len == 2 && *(value + 1) == '?'){
                return LWPropertyTypeBlock;
            } else {
                if (len == 1) {
                    propertyInfo.idType = YES;
                }
                return LWPropertyTypeObject;
            }
        }
        default:{return LWPropertyTypeUnkonw;}
    }
}

static Class _GetPropertyInfoClass(const char* value) {
    size_t len = strlen(value);
    if (len > 3) {
        char name[len - 2];
        name[len - 3] = '\0';
        memcpy(name, value + 2, len - 3);
        return objc_getClass(name);
    }
    return nil;
}


@end
