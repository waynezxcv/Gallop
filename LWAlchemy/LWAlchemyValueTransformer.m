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


#import "LWAlchemyValueTransformer.h"

@interface LWAlchemyValueTransformer ()

@property (nonatomic, copy, readonly) LWAlchemyValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) LWAlchemyValueTransformerBlock reverseBlock;

@end

@implementation LWAlchemyValueTransformer

+ (instancetype)transformerUsingForwardBlock:(LWAlchemyValueTransformerBlock)transformation {
    return [[self alloc] initWithForwardBlock:transformation reverseBlock:nil];
}

+ (instancetype)transformerUsingReversibleBlock:(LWAlchemyValueTransformerBlock)transformation {
    return [self transformerUsingForwardBlock:transformation reverseBlock:transformation];
}

+ (instancetype)transformerUsingForwardBlock:(LWAlchemyValueTransformerBlock)forwardBlock reverseBlock:(LWAlchemyValueTransformerBlock)reverseBlock {
    return [[LWAlchemyValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (id)initWithForwardBlock:(LWAlchemyValueTransformerBlock)forwardBlock reverseBlock:(LWAlchemyValueTransformerBlock)reverseBlock {
    NSParameterAssert(forwardBlock != nil);
    self = [super init];
    if (self == nil) return nil;
    _forwardBlock = [forwardBlock copy];
    _reverseBlock = [reverseBlock copy];
    return self;
}


#pragma mark - Transformer

+ (BOOL)allowsReverseTransformation {
    return NO;
}

+ (Class)transformedValueClass {
    return NSObject.class;
}

- (id)transformedValue:(id)value {
    NSError* error = nil;
    BOOL success = YES;
    return self.forwardBlock(value, &success, &error);
}

- (id)transformedValue:(id)value success:(BOOL *)outerSuccess error:(NSError **)outerError {
    NSError *error = nil;
    BOOL success = YES;
    id transformedValue = self.forwardBlock(value, &success, &error);
    if (outerSuccess != NULL) *outerSuccess = success;
    if (outerError != NULL) *outerError = error;
    return transformedValue;
}

@end
