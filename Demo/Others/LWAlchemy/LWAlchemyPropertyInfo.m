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



#import "LWAlchemyPropertyInfo.h"

@interface LWAlchemyPropertyInfo ()

@property (nonatomic,assign) objc_property_t property;
@property (nonatomic,strong) NSString* propertyName;
@property (nonatomic,strong) NSArray* mapperName;
@property (nonatomic,strong) NSString* ivarName;
@property (nonatomic,assign) Ivar ivar;
@property (nonatomic,assign) Class cls;
@property (nonatomic,strong) NSString* getter;
@property (nonatomic,strong) NSString* setter;

@property (nonatomic,assign) LWTypeKind typeKind;
@property (nonatomic,assign) LWTypeProperty typeProperty;
@property (nonatomic,assign) LWType type;
@property (nonatomic,assign) LWNSType nsType;


@end

@implementation LWAlchemyPropertyInfo

#pragma mark - Initial


- (id)initWithProperty:(objc_property_t)property customMapper:(NSDictionary *)mapper {
    self = [super init];
    if (self) {
                
        
        self.property = property;
        self.typeProperty = LWTypePropertyPlaceholder;
        unsigned int attrCount;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attributes[i].name[0]) {
                case 'T': {
                    if (attributes[i].value) {
                        _setTypeAndTypeKind(self,attributes[i].value);
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
                    self.typeProperty |= LWTypePropertyReadonly;
                } break;
                case 'D': {
                    self.typeProperty |= LWTypePropertyDynamic;
                }break;
                case 'C': {
                    self.typeProperty |= LWTypePropertyCopy;
                } break;
                case '&': {
                    self.typeProperty |= LWTypePropertyRetain;
                } break;
                case 'N': {
                    self.typeProperty |= LWTypePropertyNonatomic;
                } break;
                case 'W': {
                    self.typeProperty |= LWTypePropertyWeak;
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

#pragma mark - Type

static inline void _setTypeAndTypeKind(LWAlchemyPropertyInfo* propertyInfo,const char *value) {
    size_t len = strlen(value);
    if (len == 0) {
        propertyInfo.typeKind = LWTypeKindUnknow;
    }
    switch (*value) {
        case 'v': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeVoid;
        }break;
        case 'B': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeBool;
        }break;
        case 'c': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeInt8;
        }break;
        case 'C': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeUInt8;
        }break;
        case 's': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeInt16;
        }break;
        case 'S': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeUInt16;
        }break;
        case 'i': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeInt32;
        }break;
        case 'I': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeUInt32;
        }break;
        case 'l': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeInt32;
        }break;
        case 'L': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeUInt32;
        }break;
        case 'q': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeInt64;
        }break;
        case 'Q': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeUInt64;
        }break;
        case 'f': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeFloat;
        }break;
        case 'd': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeDouble;
        }break;
        case 'D': {
            propertyInfo.typeKind = LWTypeKindNumber;
            propertyInfo.type = LWTypeLongDouble;
        }break;
        case '#': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeClass;
        }break;
        case ':': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeSEL;
        }break;
        case '*': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeCFString;
        }break;
        case '^': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypePointer;
        }break;
        case '[': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeCFArray;
        }break;
        case '(': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeUnion;
        }break;
        case '{': {
            propertyInfo.typeKind = LWTypeKindCFObject;
            propertyInfo.type = LWTypeStruct;
        }break;
        case '@': {
            if (len == 2 && *(value + 1) == '?'){
                propertyInfo.typeKind = LWTypeKindCFObject;
                propertyInfo.type = LWTypeBlock;
            } else {
                propertyInfo.typeKind = LWTypeKindNSOrCustomObject;
                if (len == 1) {
                    propertyInfo.nsType = LWNSTypeId;
                } else {
                    propertyInfo.cls = _getPropertyInfoClass(value);
                    propertyInfo.nsType = _getObjectNSType(propertyInfo.cls);
                }
            }
        }break;
        default:{
            propertyInfo.typeKind = LWTypeKindUnknow;
        }break;
    }
}

static inline LWNSType _getObjectNSType(Class cls) {
    if (!cls) return LWNSTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSString class]]) return LWNSTypeNSString;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return LWNSTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return LWNSTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return LWNSTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return LWNSTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return LWNSTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return LWNSTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return LWNSTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return LWNSTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return LWNSTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return LWNSTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return LWNSTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return LWNSTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return LWNSTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return LWNSTypeNSSet;
    return LWNSTypeNSUnknown;
}

static inline Class _getPropertyInfoClass(const char* value) {
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
