//
//  LWConstraint.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/7.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWConstraint.h"

#define kMariginToStorageLeftKey @"leftObject"
#define kMariginToStorageRightKey @"rightObject"
#define kMariginToStorageTopKey @"topObject"
#define kMariginToStorageBottomKey @"bottomObject"

@interface LWConstraint ()

@property (nonatomic, copy) MarginToStorage leftMargin;
@property (nonatomic, copy) MarginToStorage rightMargin;
@property (nonatomic, copy) MarginToStorage topMargin;
@property (nonatomic, copy) MarginToStorage bottomMargin;



@end

@implementation LWConstraint


- (MarginToStorage)marginToStorageWithKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    return ^(LWStorage* storage, CGFloat value) {
        LWConstraintObject* object = [[LWConstraintObject alloc] init];
        object.referenceStorage = storage;
        object.value = value;
        [self setValue:object forKey:key];
        return weakSelf;
    };
}

- (MarginToStorage)leftMargin {
    if (_leftMargin) {
        return _leftMargin;
    }
    _leftMargin = [self marginToStorageWithKey:kMariginToStorageLeftKey];
    return _leftMargin;
}

- (MarginToStorage)rightMargin {
    if (_rightMargin) {
        return _rightMargin;
    }
    _rightMargin = [self marginToStorageWithKey:kMariginToStorageRightKey];
    return _rightMargin;
}

- (MarginToStorage)topMargin {
    if (_topMargin) {
        return _topMargin;
    }
    _topMargin = [self marginToStorageWithKey:kMariginToStorageTopKey];
    return _topMargin;
}

- (MarginToStorage)bottomMargin {
    if (_bottomMargin) {
        return _bottomMargin;
    }
    _bottomMargin = [self marginToStorageWithKey:kMariginToStorageBottomKey];
    return _bottomMargin;
}


@end

@implementation LWConstraintObject

@end

