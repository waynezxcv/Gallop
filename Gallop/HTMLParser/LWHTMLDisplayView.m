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

#import "LWHTMLDisplayView.h"
#import "LWAsyncDisplayView.h"
#import "LWLayout.h"
#import "LWStorageBuilder.h"
#import "LWImageBrowser/LWImageBrowser.h"


@interface LWHTMLDisplayView ()<LWAsyncDisplayViewDelegate>

@property (nonatomic,strong) LWAsyncDisplayView* asyncDisplayView;
@property (nonatomic,strong) LWStorageBuilder* storageBuilder;
@property (nonatomic,copy) NSArray* imageCallbacks;

@end

@implementation LWHTMLDisplayView

- (id)init {
    self = [super init];
    if (self) {
        self.asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.asyncDisplayView.delegate = self;
        [self addSubview:self.asyncDisplayView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.asyncDisplayView.delegate = self;
        [self addSubview:self.asyncDisplayView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC {
    self = [super initWithFrame:frame];
    if (self) {
        self.asyncDisplayView = [[LWAsyncDisplayView alloc] initWithFrame:CGRectZero];
        self.asyncDisplayView.delegate = self;
        [self addSubview:self.asyncDisplayView];
        self.parentVC = parentVC;
    }
    return self;
}

- (void)setData:(NSData *)data {
    if (_data != data) {
        _data = data;
    }
    self.storageBuilder = [[LWStorageBuilder alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
}

- (void)setLayout:(LWLayout *)layout {
    if (_layout != layout) {
        _layout = layout;
    }
    CGSize contentSize = CGSizeMake(SCREEN_WIDTH, [layout suggestHeightWithBottomMargin:10.0f]);
    self.contentSize = contentSize;
    self.asyncDisplayView.frame = CGRectMake(0, 0, SCREEN_WIDTH, contentSize.height);
    self.asyncDisplayView.layout = self.layout;
}

#pragma mark - LWAsyncDisplayViewDelegate

/***  点击链接 ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedTextStorage:(LWTextStorage *)textStorage linkdata:(id)data {
    if ([self.displayDelegate respondsToSelector:@selector(lwhtmlDisplayView:didCilickedTextStorage:linkdata:)] &&
        [self.displayDelegate conformsToProtocol:@protocol(LWHTMLDisplayViewDelegate)]) {
        [self.displayDelegate lwhtmlDisplayView:self didCilickedTextStorage:textStorage linkdata:data];
    }
}

/***  点击LWImageStorage回调 ***/
- (void)lwAsyncDisplayView:(LWAsyncDisplayView *)asyncDisplayView didCilickedImageStorage:(LWImageStorage *)imageStorage touch:(UITouch *)touch {
    if ([self.imageCallbacks containsObject:imageStorage]) {
        NSInteger index = [self.imageCallbacks indexOfObject:imageStorage];
        NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:self.imageCallbacks.count];
        for (NSInteger i = 0; i < self.imageCallbacks.count; i ++) {
            @autoreleasepool {
                LWImageStorage* imageStorage = [self.imageCallbacks objectAtIndex:i];
                LWImageBrowserModel* imageModel = [[LWImageBrowserModel alloc] initWithplaceholder:nil
                                                                                      thumbnailURL:(NSURL *)imageStorage.contents
                                                                                             HDURL:(NSURL *)imageStorage.contents
                                                                                imageViewSuperView:self.asyncDisplayView
                                                                               positionAtSuperView:imageStorage.frame
                                                                                             index:index];
                [tmp addObject:imageModel];
            }
        }
        LWImageBrowser* imageBrowser = [[LWImageBrowser alloc] initWithParentViewController:self.parentVC
                                                                                imageModels:tmp
                                                                               currentIndex:index];
        [imageBrowser show];
    }
    if ([self.displayDelegate respondsToSelector:@selector(lwhtmlDisplayView:didCilickedImageStorage:)] &&
        [self.displayDelegate conformsToProtocol:@protocol(LWHTMLDisplayViewDelegate)]) {
        [self.displayDelegate lwhtmlDisplayView:self didCilickedImageStorage:imageStorage];
    }
}

#pragma mark - Getter
- (NSArray *)imageCallbacks {
    return self.storageBuilder.imageCallbacks;
}

@end
