//
//  LWConstraint.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWConstraint.h"

@interface LWConstraint ()

@property (nonatomic,copy) Margin leftMargin;
@property (nonatomic,copy) Margin rightMargin;
@property (nonatomic,copy) Margin topMargin;
@property (nonatomic,copy) Margin bottomMargin;
@property (nonatomic,copy) Length widthLength;
@property (nonatomic,copy) Length heightLength;


@property (nonatomic,copy) MarginToStorage leftMarginToStorage;
@property (nonatomic,copy) MarginToStorage rightMarginToStorage;
@property (nonatomic,copy) MarginToStorage topMarginToStorage;
@property (nonatomic,copy) MarginToStorage bottomMarginToStorage;

@property (nonatomic,copy) EqualToStorage leftMarginEquelToStorage;
@property (nonatomic,copy) EqualToStorage rightMarginEquelToStorage;
@property (nonatomic,copy) EqualToStorage topMarginEquelToStorage;
@property (nonatomic,copy) EqualToStorage bottomMarginEquelToStorage;

@property (nullable,nonatomic,strong) NSNumber* left;
@property (nullable,nonatomic,strong) NSNumber* right;
@property (nullable,nonatomic,strong) NSNumber* top;
@property (nullable,nonatomic,strong) NSNumber* bottom;
@property (nullable,nonatomic,strong) NSNumber* width;
@property (nullable,nonatomic,strong) NSNumber* height;

@property (nullable,nonatomic,strong) LWConstraintObject* leftObject;
@property (nullable,nonatomic,strong) LWConstraintObject* rightObject;
@property (nullable,nonatomic,strong) LWConstraintObject* topObject;
@property (nullable,nonatomic,strong) LWConstraintObject* bottomObject;

@end



@implementation LWConstraint

- (Margin)leftMargin {
    if (_leftMargin) {
        return _leftMargin;
    }
    _leftMargin = [self marginWithKey:@"left"];
    return _leftMargin;
}

- (Margin)rightMargin {
    if (_rightMargin) {
        return _rightMargin;
    }
    _rightMargin = [self marginWithKey:@"right"];
    return _rightMargin;
}

- (Margin)topMargin {
    if (_topMargin) {
        return _topMargin;
    }
    _topMargin = [self marginWithKey:@"top"];
    return _topMargin;
}

- (Margin)bottomMargin {
    if (_bottomMargin) {
        return _bottomMargin;
    }
    _bottomMargin = [self marginWithKey:@"bottom"];
    return _bottomMargin;
}

- (Length)widthLength {
    if (_widthLength) {
        return _widthLength;
    }
    _widthLength = [self lengthWithKey:@"width"];
    return _widthLength;
}

- (Length)heightLength {
    if (_heightLength) {
        return _heightLength;
    }
    _heightLength = [self lengthWithKey:@"height"];
    return _heightLength;
}

- (MarginToStorage)leftMarginToStorage {
    if (_leftMarginToStorage) {
        return _leftMarginToStorage;
    }
    _leftMarginToStorage = [self marginToStorageWithKey:@"leftObject"];
    return _leftMarginToStorage;
}

- (MarginToStorage)rightMarginToStorage {
    if (_rightMarginToStorage) {
        return _rightMarginToStorage;
    }
    _rightMarginToStorage = [self marginToStorageWithKey:@"rightObject"];
    return _rightMarginToStorage;
}

- (MarginToStorage)topMarginToStorage {
    if (_topMarginToStorage) {
        return _topMarginToStorage;
    }
    _topMarginToStorage = [self marginToStorageWithKey:@"topObject"];
    return _topMarginToStorage;
}

- (MarginToStorage)bottomMarginToStorage {
    if (_bottomMarginToStorage) {
        return _bottomMarginToStorage;
    }
    _bottomMarginToStorage = [self marginToStorageWithKey:@"bottomObject"];
    return _bottomMarginToStorage;
}


- (Length)lengthWithKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    return ^(CGFloat value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([key isEqualToString:@"width"]) {
            strongSelf.width = @(value);
        }
        else if ([key isEqualToString:@"height"]) {
            strongSelf.height = @(value);
        }
        return strongSelf;
    };
}

- (Margin)marginWithKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    return ^(CGFloat value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([key isEqualToString:@"left"]) {
            strongSelf.left = @(value);
        } else if ([key isEqualToString:@"right"]) {
            strongSelf.right = @(value);
        } else if ([key isEqualToString:@"top"]) {
            strongSelf.top = @(value);
        }
        else if ([key isEqualToString:@"bottom"]) {
            strongSelf.bottom = @(value);
        }
        return strongSelf;
    };
}

- (MarginToStorage)marginToStorageWithKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    return ^(LWStorage* storage, CGFloat value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LWConstraintObject* object = [[LWConstraintObject alloc] init];
        object.referenceStorage = storage;
        object.value = value;
        [strongSelf setValue:object forKey:key];
        return strongSelf;
    };
}

@end

@implementation LWConstraintObject

@end

