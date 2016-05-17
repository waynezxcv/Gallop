//
//  LWAsyncDisplayView.m
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/5/16.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#import "LWAsyncDisplayView.h"
#import "GallopUtils.h"


@implementation LWAsyncDisplayView{
    NSArray* _textStorages;
    NSArray* _imageStorages;
    LWTextHighlight* _highlight;
    BOOL _showingHighlight;
    BOOL _cleanedImageContainer;
    BOOL _setedImageContents;
    BOOL _displayed;
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.layer.opaque = YES;
    self.layer.contentsScale = [GallopUtils contentsScale];
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout == layout || [_layout isEqual:layout]) {
        return;
    }
    [self _cleanup];
    _layout = layout;
    [self _updateLayout];

}

- (void)setFrame:(CGRect)frame {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = frame.size;
    if (!CGSizeEqualToSize(oldSize, newSize) &&
        !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setFrame:frame];
        [self _setNeedDisplay];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGSize oldSize = self.bounds.size;
    CGSize newSize = bounds.size;
    if (!CGSizeEqualToSize(oldSize, newSize) &&
        !CGSizeEqualToSize(newSize,CGSizeZero)) {
        [super setBounds:bounds];
        [self _setNeedDisplay];
    }
}

#pragma mark - Private

- (void)_cleanup {
    LWLayout* layout = _layout;
    _layout = nil;

    LWTextHighlight* highlight = _highlight;
    _highlight = nil;

    NSArray* textStroages = _textStorages;
    _textStorages = nil;

    NSArray* imageStorages = _imageStorages;
    _imageStorages = nil;

    _showingHighlight = NO;
    _cleanedImageContainer = YES;
    _setedImageContents = NO;
    _displayed = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [textStroages count];
        [layout class];
        [highlight class];
        [imageStorages count];
    });
}

- (void)_updateLayout {
    _imageStorages = self.layout.imageStorages;
    _setedImageContents = NO;

    _textStorages = self.layout.textStorages;
    _displayed = NO;

    [self _setNeedDisplay];
}



#pragma mark - Display
- (void)_setNeedDisplay {
    if (!_displayed) {
        [self _commitDisplay];
    }
}

- (void)_commitDisplay {
    [self lw_addDisplayTransactionsWithasyncDisplay:^(CGContextRef context, CGSize size) {
        [self _drawStoragesInContext:context];
    } complete:^(id displayContent, BOOL isFinished) {
        if (isFinished) {
            _displayed = YES;
        }
    }];
}

- (void)setNeedRedDraw {
    [self lw_asyncDisplay:^(CGContextRef context, CGSize size) {
        [self _drawStoragesInContext:context];
    } complete:^(id displayContent, BOOL isFinished) {
        if (isFinished) {
            _displayed = YES;
        }
    }];
}

- (void)_drawStoragesInContext:(CGContextRef)context {
    for (LWTextStorage* textStorage in _textStorages) {
        [textStorage.textLayout drawIncontext:context
                                         size:textStorage.textLayout.textBoundingSize
                                        point:textStorage.frame.origin
                                containerView:self
                               containerLayer:self.layer];
    }
}


@end
