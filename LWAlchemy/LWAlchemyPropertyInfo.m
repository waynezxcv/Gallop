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
//  Created by 刘微 on 16/3/14.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWAlchemyPropertyInfo.h"


@interface LWAlchemyPropertyInfo ()

@property (nonatomic, assign) objc_property_t property;//属性
@property (nonatomic, strong) NSString* propertyName;//属性名称
@property (nonatomic, strong) NSString* ivarName;//实例对象名称
@property (nonatomic, assign) LWType type;//类型
@property (nonatomic, assign) Class cls;//如果是LWTypeObject类型，用来表示该对象所属的类,否则为nil
@property (nonatomic, strong) NSString* getter;//getter方法
@property (nonatomic, strong) NSString* setter;//setter方法
@property (nonatomic,assign,getter=isReadonly) BOOL readonly;//是否是只读属性
@property (nonatomic,assign,getter=isDynamic) BOOL dynamic;

@end

@implementation LWAlchemyPropertyInfo

- (id)initWithProperty:(objc_property_t)property {
    self = [super init];
    if (self) {
        self.readonly = NO;
        self.dynamic = NO;
        self.property = property;
        unsigned int attrCount;
        objc_property_attribute_t* attributes = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attributes[i].name[0]) {
                    //类型属性
                case 'T': {
                    if (attributes[i].value) {
                        LWType type = _GetPropertyInfoType(attributes[i].value);
                        self.type = type;
                        if (self.type == LWTypeObject) {
                            self.cls = _GetPropertyInfoClass(attributes[i].value);
                        }
                        else {
                            self.cls = nil;
                        }
                    }
                } break;
                    //实例对象属性
                case 'V': {
                    if (attributes[i].value) {
                        self.ivarName = [NSString stringWithUTF8String:attributes[i].value];
                    }
                } break;
                    //自定义的Getter方法
                case 'G': {
                    if (attributes[i].value) {
                        self.getter = [NSString stringWithUTF8String:attributes[i].value];
                    }

                } break;
                    //自定义的Setter方法
                case 'S': {
                    if (attributes[i].value) {
                        self.setter = [NSString stringWithUTF8String:attributes[i].value];
                    }
                }break;
                    //是否是只读属性
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
        //propertyName
        self.propertyName =  @(property_getName(property));
        //setter & getter
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

static LWType _GetPropertyInfoType(const char* value) {
    size_t len = strlen(value);
    if (len == 0) return LWTypeUnkonw;
    switch (* value) {
        case 'v': {return LWTypeVoid;}
        case 'B': {return LWTypeBool;}
        case 'c': {return LWTypeInt8;}
        case 'C': {return LWTypeUInt8;}
        case 's': {return LWTypeInt16;}
        case 'S': {return LWTypeUInt16;}
        case 'i': {return LWTypeInt32;}
        case 'I': {return LWTypeUInt32;}
        case 'l': {return LWTypeInt32;}
        case 'L': {return LWTypeUInt32;}
        case 'q': {return LWTypeInt64;}
        case 'Q': {return LWTypeUInt64;}
        case 'f': {return LWTypeFloat;}
        case 'd': {return LWTypeDouble;}
        case 'D': {return LWTypeLongDouble;}
        case '#': {return LWTypeClass;}
        case ':': {return LWTypeSEL;}
        case '*': {return LWTypeCFString;}
        case '^': {return LWTypePointer;}
        case '[': {return LWTypeCFArray;}
        case '(': {return LWTypeUnion;}
        case '{': {return LWTypeStruct;}
        case '@': {
            if (len == 2 && *(value + 1) == '?'){
                return LWTypeBlock;
            } else {
                return LWTypeObject;
            }
        }
        default:{return LWTypeUnkonw;}
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
