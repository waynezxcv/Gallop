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
