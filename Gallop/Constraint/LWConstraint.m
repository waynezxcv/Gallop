/*
 https://github.com/waynezxcv/Gallop
 
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


#import "LWConstraint.h"
#import "LWStorage.h"




@interface LWConstraint ()

@property (nonatomic,copy) Margin leftMargin;
@property (nonatomic,copy) Margin rightMargin;
@property (nonatomic,copy) Margin topMargin;
@property (nonatomic,copy) Margin bottomMargin;
@property (nonatomic,copy) Length widthLength;
@property (nonatomic,copy) Length heightLength;
@property (nonatomic,copy) Center center;


@property (nonatomic,copy) MarginToStorage leftMarginToStorage;
@property (nonatomic,copy) MarginToStorage rightMarginToStorage;
@property (nonatomic,copy) MarginToStorage topMarginToStorage;
@property (nonatomic,copy) MarginToStorage bottomMarginToStorage;

@property (nonatomic,copy) EqualToStorage leftEquelToStorage;
@property (nonatomic,copy) EqualToStorage rightEquelToStorage;
@property (nonatomic,copy) EqualToStorage topEquelToStorage;
@property (nonatomic,copy) EqualToStorage bottomEquelToStorage;


@property (nonatomic,copy) EdgeInsetsToContainer edgeInsetsToContainer;


@property (nonatomic,strong) NSNumber* left;
@property (nonatomic,strong) NSNumber* right;
@property (nonatomic,strong) NSNumber* top;
@property (nonatomic,strong) NSNumber* bottom;
@property (nonatomic,strong) NSNumber* width;
@property (nonatomic,strong) NSNumber* height;
@property (nonatomic,strong) NSValue* centerValue;

@property (nonatomic,strong) LWConstraintMarginObject* leftMarginObject;
@property (nonatomic,strong) LWConstraintMarginObject* rightMarginObject;
@property (nonatomic,strong) LWConstraintMarginObject* topMarginObject;
@property (nonatomic,strong) LWConstraintMarginObject* bottomMarginObject;


@property (nonatomic,strong) LWConstraintEqualObject* leftEqualObject;
@property (nonatomic,strong) LWConstraintEqualObject* rightEqualObject;
@property (nonatomic,strong) LWConstraintEqualObject* topEqualObject;
@property (nonatomic,strong) LWConstraintEqualObject* bottomEqualObject;

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
    _leftMarginToStorage = [self marginToStorageWithKey:@"leftMarginObject"];
    return _leftMarginToStorage;
}

- (MarginToStorage)rightMarginToStorage {
    if (_rightMarginToStorage) {
        return _rightMarginToStorage;
    }
    _rightMarginToStorage = [self marginToStorageWithKey:@"rightMarginObject"];
    return _rightMarginToStorage;
}

- (MarginToStorage)topMarginToStorage {
    if (_topMarginToStorage) {
        return _topMarginToStorage;
    }
    _topMarginToStorage = [self marginToStorageWithKey:@"topMarginObject"];
    return _topMarginToStorage;
}

- (MarginToStorage)bottomMarginToStorage {
    if (_bottomMarginToStorage) {
        return _bottomMarginToStorage;
    }
    _bottomMarginToStorage = [self marginToStorageWithKey:@"bottomMarginObject"];
    return _bottomMarginToStorage;
}

- (EqualToStorage)leftEquelToStorage {
    if (_leftEquelToStorage) {
        return _leftEquelToStorage;
    }
    _leftEquelToStorage = [self equelToStorageWithKey:@"leftEqualObject"];
    return _leftEquelToStorage;
}

- (EqualToStorage)rightEquelToStorage {
    if (_rightEquelToStorage) {
        return _rightEquelToStorage;
    }
    _rightEquelToStorage = [self equelToStorageWithKey:@"rightEqualObject"];
    return _rightEquelToStorage;
}


- (EqualToStorage)topEquelToStorage {
    if (_topEquelToStorage) {
        return _topEquelToStorage;
    }
    _topEquelToStorage = [self equelToStorageWithKey:@"topEqualObject"];
    return _topEquelToStorage;
}

- (EqualToStorage)bottomEquelToStorage {
    if (_bottomEquelToStorage) {
        return _bottomEquelToStorage;
    }
    _bottomEquelToStorage  = [self equelToStorageWithKey:@"bottomEqualObject"];
    return _bottomEquelToStorage;
}

- (EqualToStorage)equelToStorageWithKey:(NSString *)key {
    __weak typeof(self) weakSelf = self;
    return ^(LWStorage* storage) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LWConstraintEqualObject* object = [[LWConstraintEqualObject alloc] init];
        object.referenceStorage = storage;
        [strongSelf setValue:object forKey:key];
        return strongSelf;
    };
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
        LWConstraintMarginObject* object = [[LWConstraintMarginObject alloc] init];
        object.referenceStorage = storage;
        object.value = value;
        [strongSelf setValue:object forKey:key];
        return strongSelf;
    };
}

- (EdgeInsetsToContainer)edgeInsetsToContainer {
    if (_edgeInsetsToContainer) {
        return _edgeInsetsToContainer;
    }
    __weak typeof(self) weakSelf = self;
    _edgeInsetsToContainer = ^(UIEdgeInsets insets) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.left = @(insets.left);
        strongSelf.right = @(insets.right);
        strongSelf.top = @(insets.top);
        strongSelf.bottom = @(insets.bottom);
        return strongSelf;
    };
    return _edgeInsetsToContainer;
}

- (Center)center {
    if (_center) {
        return _center;
    }
    __weak typeof(self) weakSelf = self;
    _center  = ^(CGPoint center) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSValue* centerValue = [NSValue valueWithCGPoint:CGPointMake(center.x, center.y)];
        strongSelf.centerValue = centerValue;
        return strongSelf;
    };
    return _center;
}

@end



@implementation LWConstraintMarginObject

@end

@implementation LWConstraintEqualObject

@end

