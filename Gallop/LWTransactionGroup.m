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

#import "LWTransactionGroup.h"
#import "CALayer+LWTransaction.h"

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer,
                                                     CFRunLoopActivity activity,
                                                     void* info);

@interface LWTransactionGroup ()

@property (nonatomic,strong) NSHashTable* layersContainers;

@end

@implementation LWTransactionGroup

#pragma mark - Init

+ (LWTransactionGroup *)mainTransactionGroup {
    static LWTransactionGroup* mainTransactionGroup;
    if (mainTransactionGroup == nil) {
        mainTransactionGroup = [[LWTransactionGroup alloc] init];
        [self registerTransactionGroupAsMainRunloopObserver:mainTransactionGroup];
    }
    return mainTransactionGroup;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.layersContainers = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    }
    return self;
}

+ (void)registerTransactionGroupAsMainRunloopObserver:(LWTransactionGroup *)transactionGroup {
    static CFRunLoopObserverRef observer;
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);
    
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)transactionGroup,
        &CFRetain,
        &CFRelease,
        NULL
    };
    observer = CFRunLoopObserverCreate(NULL,
                                       activities,
                                       YES,
                                       INT_MAX,
                                       &_transactionGroupRunLoopObserverCallback,
                                       &context);
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

#pragma mark - Methods

- (void)addTransactionContainer:(CALayer *)layerContainer {
    [self.layersContainers addObject:layerContainer];
}

+ (void)commit {
    [[LWTransactionGroup mainTransactionGroup] commit];
}

- (void)commit {
    if ([self.layersContainers count]) {
        NSHashTable* containerLayersToCommit = self.layersContainers;
        self.layersContainers = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
        for (CALayer* containerLayer in containerLayersToCommit) {
            LWTransaction* transaction = containerLayer.currentTransaction;
            containerLayer.currentTransaction = nil;
            [transaction commit];
        }
    }
}

@end

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info) {
    LWTransactionGroup* group = (__bridge LWTransactionGroup *)info;
    [group commit];
}

