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







#import "LWGIFImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>





const NSTimeInterval kLWGIFDelayTimeIntervalMinimumValue = 0.02;//每帧图片最小的显示时间



typedef NS_ENUM(NSUInteger, LWGIFImageDataSizeCategory) {
    LWGIFImageDataSizeCategoryAll = 10,
    LWGIFImageDataSizeCategoryDefault = 75,
    LWGIFImageDataSizeCategoryOnDemand = 250,
    LWGIFImageDataSizeCategoryUnsupported
};

typedef NS_ENUM(NSUInteger, LWGIFImageFrameCacheSize) {
    LWGIFImageFrameCacheSizeNoLimit = 0,
    LWGIFImageFrameCacheSizeLowMemory = 1,
    LWGIFImageFrameCacheSizeGrowAfterMemoryWarning = 2,
    LWGIFImageFrameCacheSizeDefault = 5
};



@interface LWGIFImage ()


@property (nonatomic, strong) UIImage* coverImage;
@property (nonatomic,assign) NSUInteger frameCacheSizeCurrent;//当前缓存的帧数
@property (nonatomic,assign) NSUInteger frameCacheSizeMax;//最大的缓存帧数
@property (nonatomic,strong) NSData* data;//原始二进制数据
@property (nonatomic,assign) NSUInteger frameCacheSizeOptimal;//最佳的缓存帧数
@property (nonatomic,assign,getter = isPredrawingEnabled) BOOL predrawingEnabled;//是否预加载gif
@property (nonatomic,assign) NSUInteger frameCacheSizeMaxInternal;//允许缓存的内存大小，0表示无限大小
@property (nonatomic,assign) NSUInteger requestedFrameIndex;//请求的的帧索引，用于传入索引返回帧图片
@property (nonatomic,assign) NSUInteger coverImageFrameIndex;//封面图片的索引
@property (nonatomic,strong) NSMutableDictionary* cachedFramesForIndexes;//key:帧图片在GIF动画的索引位置 value:帧图片
@property (nonatomic,strong) NSMutableIndexSet* cachedFrameIndexes;//缓存帧图片在GIF动画的索引位置集合
@property (nonatomic,strong) NSMutableIndexSet* requestedFrameIndexes;//需要生成的的帧图片的索引集合，每处理完一帧就将其从中移除
@property (nonatomic,strong) NSIndexSet* allFramesIndexSet; //所有帧的集合
@property (nonatomic,strong) dispatch_queue_t cacheQueue;
@property (nonatomic,strong) __attribute__((NSObject)) CGImageSourceRef imageSource;
@property (nonatomic,assign) NSUInteger memoryWarningCount;
@property (nonatomic, strong, readonly) LWGIFImage* weakProxy;


@end






static NSHashTable* allGIFImagesWeak;

@implementation LWGIFImage


#pragma mark - Sette & Getter

- (NSMutableDictionary *)cachedFramesForIndexes {
    if (_cachedFramesForIndexes) {
        return _cachedFramesForIndexes;
    }
    _cachedFramesForIndexes = [[NSMutableDictionary alloc] init];
    return _cachedFramesForIndexes;
}

- (NSMutableIndexSet *)cachedFrameIndexes {
    if (_cachedFrameIndexes) {
        return _cachedFrameIndexes;
    }
    _cachedFrameIndexes = [[NSMutableIndexSet alloc] init];
    return _cachedFrameIndexes;
}


- (NSMutableIndexSet *)requestedFrameIndexes {
    if (_requestedFrameIndexes) {
        return _requestedFrameIndexes;
    }
    _requestedFrameIndexes = [[NSMutableIndexSet alloc] init];
    return _requestedFrameIndexes;
}

- (NSUInteger)frameCacheSizeCurrent {
    NSUInteger frameCacheSizeCurrent = self.frameCacheSizeOptimal;
    if (self.frameCacheSizeMax > LWGIFImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMax);
    }
    if (self.frameCacheSizeMaxInternal > LWGIFImageFrameCacheSizeNoLimit) {
        frameCacheSizeCurrent = MIN(frameCacheSizeCurrent, self.frameCacheSizeMaxInternal);
    }
    return frameCacheSizeCurrent;
}


- (void)setFrameCacheSizeMax:(NSUInteger)frameCacheSizeMax {
    if (_frameCacheSizeMax != frameCacheSizeMax) {
        BOOL willFrameCacheSizeShrink = (frameCacheSizeMax < self.frameCacheSizeCurrent);
        _frameCacheSizeMax = frameCacheSizeMax;
        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}


- (void)setFrameCacheSizeMaxInternal:(NSUInteger)frameCacheSizeMaxInternal {
    if (_frameCacheSizeMaxInternal != frameCacheSizeMaxInternal) {
        BOOL willFrameCacheSizeShrink = (frameCacheSizeMaxInternal < self.frameCacheSizeCurrent);
        _frameCacheSizeMaxInternal = frameCacheSizeMaxInternal;
        if (willFrameCacheSizeShrink) {
            [self purgeFrameCacheIfNeeded];
        }
    }
}


#pragma mark - LifeCycle

+ (void)initialize {
    if (self == [LWGIFImage class]) {//检查类型，防止多次继承之后调用
        allGIFImagesWeak = [NSHashTable weakObjectsHashTable];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSArray* images = nil;
            @synchronized(allGIFImagesWeak) {
                images = [[allGIFImagesWeak allObjects] copy];
            }
            [images makeObjectsPerformSelector:@selector(didReceiveMemoryWarning:) withObject:note];
        }];
    }
}


- (id)initWithGIFData:(NSData *)data {
    if (data.length == 0) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.data = data;
        self.predrawingEnabled = YES;
        NSUInteger optimalFrameCacheSize = 0;
        
        
        self.imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                       (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});//创建CGImageSourceRef，并设置系统不缓存
        if (!self.imageSource) {
            return nil;
        }
        
        CFStringRef imageSourceContainerType = CGImageSourceGetType(_imageSource);
        if (!UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF)) {
            return nil;
        }
        
        NSDictionary* imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(self.imageSource, NULL);
        _loopCount = [[[imageProperties objectForKey:(id)kCGImagePropertyGIFDictionary] objectForKey:(id)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
        
        //遍历图片ImageSourceRef，获取每一帧的信息，并保存
        size_t imageCount = CGImageSourceGetCount(self.imageSource);
        NSUInteger skippedFrameCount = 0;
        NSMutableDictionary* timesForIndexMutable = [NSMutableDictionary dictionaryWithCapacity:imageCount];
        for (size_t i = 0; i < imageCount; i++) {
            
            @autoreleasepool {
                
                //每一帧
                CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(self.imageSource, i, NULL);
                if (frameImageRef) {
                    UIImage* frameImage = [UIImage imageWithCGImage:frameImageRef];
                    if (frameImage) {
                        if (!self.coverImage) {
                            self.coverImage = frameImage;
                            self.coverImageFrameIndex = i;
                            [self.cachedFramesForIndexes setObject:self.coverImage forKey:@(self.coverImageFrameIndex)];
                            [self.cachedFrameIndexes addIndex:self.coverImageFrameIndex];
                        }
                        
                        
                        NSDictionary* frameProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(_imageSource, i, NULL);
                        NSDictionary* framePropertiesGIF = [frameProperties objectForKey:(id)kCGImagePropertyGIFDictionary];
                        
                        //获取每一帧的显示时间
                        NSNumber* time = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFUnclampedDelayTime];
                        if (!time) {
                            time = [framePropertiesGIF objectForKey:(id)kCGImagePropertyGIFDelayTime];
                        }
                        
                        const NSTimeInterval kDelayTimeIntervalDefault = 0.1;
                        if (!time) {
                            if (i == 0) {
                                time = @(kDelayTimeIntervalDefault);
                            } else {
                                time = timesForIndexMutable[@(i - 1)];
                            }
                        }
                        if ([time floatValue] < ((float)kLWGIFDelayTimeIntervalMinimumValue - FLT_EPSILON)) {
                            time = @(kDelayTimeIntervalDefault);
                        }
                        timesForIndexMutable[@(i)] = time;
                        
                    } else {//跳过的帧
                        skippedFrameCount++;
                    }
                    CFRelease(frameImageRef);
                } else {
                    skippedFrameCount++;
                }
            }
        }
        
        _timesForIndex = [timesForIndexMutable copy];
        _frameCount = imageCount;
        
        if (self.frameCount == 0) {
            return nil;
        }
        
        //计算缓存策略
        if (optimalFrameCacheSize == 0) {
            // 图片的 （每行字节长度 * 高 * 图片帧数量） / 1M字节 = GIF大小（M）
            CGFloat animatedImageDataSize = CGImageGetBytesPerRow(self.coverImage.CGImage) * self.coverImage.size.height * (self.frameCount - skippedFrameCount) / (1024 * 1024);
            
            // GIF动画的占用内存大小与LWGIFImageDataSizeCategory的方案比较，确认缓存策略
            if (animatedImageDataSize <= LWGIFImageDataSizeCategoryAll) {
                _frameCacheSizeOptimal = self.frameCount;
            } else if (animatedImageDataSize <= LWGIFImageDataSizeCategoryDefault) {
                _frameCacheSizeOptimal = LWGIFImageFrameCacheSizeDefault;
            } else {
                _frameCacheSizeOptimal = LWGIFImageFrameCacheSizeLowMemory;
            }
            
        } else {
            
            //自定义的缓存策略
            _frameCacheSizeOptimal = optimalFrameCacheSize;
        }
        
        // 确认最佳的GIF动画的帧图片缓存数量
        _frameCacheSizeOptimal = MIN(_frameCacheSizeOptimal, self.frameCount);
        _allFramesIndexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.frameCount)];
        
        //一个弱类型的自身代理，防止循环引用，存入哈希表，当收到内存报警时，遍历哈希表调用didReceiveMemoryWarning方法
        _weakProxy = (id)[LWProxy proxyWithObject:self];
        @synchronized(allGIFImagesWeak) {
            [allGIFImagesWeak addObject:self];
        }
    }
    return self;
}

- (void)dealloc {
    if (_weakProxy) {
        [NSObject cancelPreviousPerformRequestsWithTarget:_weakProxy];
    }
    if (_imageSource) {
        CFRelease(_imageSource);
    }
}


#pragma mark - ImageDecoding


+ (UIImage *)predrawnImageFromImage:(UIImage *)imageToPredraw {
    
    CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceDeviceRGBRef) {
        return imageToPredraw;
    }
    
    size_t numberOfComponents = CGColorSpaceGetNumberOfComponents(colorSpaceDeviceRGBRef) + 1; // 4: RGB + A
    
    void *data = NULL;
    size_t width = imageToPredraw.size.width;
    size_t height = imageToPredraw.size.height;
    size_t bitsPerComponent = CHAR_BIT;
    
    size_t bitsPerPixel = (bitsPerComponent * numberOfComponents);
    size_t bytesPerPixel = (bitsPerPixel / 8);
    size_t bytesPerRow = (bytesPerPixel * width);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageToPredraw.CGImage);
    if (alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaOnly) {
        alphaInfo = kCGImageAlphaNoneSkipFirst;
    } else if (alphaInfo == kCGImageAlphaFirst) {
        alphaInfo = kCGImageAlphaPremultipliedFirst;
    } else if (alphaInfo == kCGImageAlphaLast) {
        alphaInfo = kCGImageAlphaPremultipliedLast;
    }
    
    bitmapInfo |= alphaInfo;
    
    
    CGContextRef bitmapContextRef = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpaceDeviceRGBRef, bitmapInfo);
    CGColorSpaceRelease(colorSpaceDeviceRGBRef);
    
    if (!bitmapContextRef) {
        return imageToPredraw;
    }
    
    CGContextDrawImage(bitmapContextRef, CGRectMake(0.0, 0.0, imageToPredraw.size.width, imageToPredraw.size.height), imageToPredraw.CGImage);
    CGImageRef predrawnImageRef = CGBitmapContextCreateImage(bitmapContextRef);
    UIImage* predrawnImage = [UIImage imageWithCGImage:predrawnImageRef scale:imageToPredraw.scale orientation:imageToPredraw.imageOrientation];
    CGImageRelease(predrawnImageRef);
    CGContextRelease(bitmapContextRef);
    
    if (!predrawnImage) {
        return imageToPredraw;
    }
    return predrawnImage;
}



#pragma mark - getFrameImage & Cache

- (UIImage *)frameImageWithIndex:(NSInteger)index {
    
    if (index >= self.frameCount) {
        return nil;
    }
    self.requestedFrameIndex = index;
    
    if ([self.cachedFrameIndexes count] < self.frameCount) {
        NSMutableIndexSet* frameIndexesToAddToCacheMutable = [self frameIndexesToCache];
        [frameIndexesToAddToCacheMutable removeIndexes:self.cachedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndexes:self.requestedFrameIndexes];
        [frameIndexesToAddToCacheMutable removeIndex:self.coverImageFrameIndex];
        
        NSIndexSet* frameIndexesToAddToCache = [frameIndexesToAddToCacheMutable copy];
        if ([frameIndexesToAddToCache count] > 0) {
            //新增新帧到缓存
            [self addFrameIndexesToCache:frameIndexesToAddToCache];
        }
    }
    //从缓存中读取该索引对应帧
    UIImage* image = self.cachedFramesForIndexes[@(index)];
    //清除缓存
    [self purgeFrameCacheIfNeeded];
    return image;
}

- (void)addFrameIndexesToCache:(NSIndexSet *)frameIndexesToAddToCache {
    //从请求的帧到最后一帧区间
    NSRange firstRange = NSMakeRange(self.requestedFrameIndex, self.frameCount - self.requestedFrameIndex);
    //从第一帧到请求的帧区间
    NSRange secondRange = NSMakeRange(0, self.requestedFrameIndex);
    //将帧索引加入待办
    [self.requestedFrameIndexes addIndexes:frameIndexesToAddToCache];
    
    //在一个串行队列中处理
    if (!self.cacheQueue) {
        self.cacheQueue = dispatch_queue_create("com.waynezxcv.gifCahceQueue", DISPATCH_QUEUE_SERIAL);
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.cacheQueue, ^{
        __strong typeof(weakSelf) sself = weakSelf;
        
        void (^frameRangeBlock)(NSRange, BOOL *) = ^(NSRange range, BOOL *stop) {
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
                
                UIImage* image = [weakSelf imageAtIndex:i];
                if (image && weakSelf) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        sself.cachedFramesForIndexes[@(i)] = image;//帧图片及其对应的索引添加到字典
                        [sself.cachedFrameIndexes addIndex:i];//帧索引集合
                        [sself.requestedFrameIndexes removeIndex:i];//代办队列中移除这个索引
                    });
                }
            }
        };
        
        //遍历两个区间，将帧数据添加到缓存
        [frameIndexesToAddToCache enumerateRangesInRange:firstRange options:0 usingBlock:frameRangeBlock];
        [frameIndexesToAddToCache enumerateRangesInRange:secondRange options:0 usingBlock:frameRangeBlock];
    });
}


- (UIImage *)imageAtIndex:(NSUInteger)index {
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSource, index, NULL);
    if (!imageRef) {
        return nil;
    }
    UIImage* image = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    
    //如果需要，将图片解码
    if (self.isPredrawingEnabled) {
        image = [[self class] predrawnImageFromImage:image];
    }
    return image;
}


- (NSMutableIndexSet *)frameIndexesToCache {
    
    
    NSMutableIndexSet* indexesToCache = nil;
    
    
    if (self.frameCacheSizeCurrent == self.frameCount) {
        indexesToCache = [self.allFramesIndexSet mutableCopy];
    } else {
        indexesToCache = [[NSMutableIndexSet alloc] init];
        NSUInteger firstLength = MIN(self.frameCacheSizeCurrent, self.frameCount - self.requestedFrameIndex);
        NSRange firstRange = NSMakeRange(self.requestedFrameIndex, firstLength);
        [indexesToCache addIndexesInRange:firstRange];
        NSUInteger secondLength = self.frameCacheSizeCurrent - firstLength;
        if (secondLength > 0) {
            NSRange secondRange = NSMakeRange(0, secondLength);
            [indexesToCache addIndexesInRange:secondRange];
        }
        
        [indexesToCache addIndex:self.coverImageFrameIndex];
    }
    return indexesToCache;
}

- (void)purgeFrameCacheIfNeeded {
    
    if ([self.cachedFrameIndexes count] > self.frameCacheSizeCurrent) {
        NSMutableIndexSet* indexesToPurge = [self.cachedFrameIndexes mutableCopy];
        [indexesToPurge removeIndexes:[self frameIndexesToCache]];
        [indexesToPurge enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
            for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
                [self.cachedFrameIndexes removeIndex:i];
                [self.cachedFramesForIndexes removeObjectForKey:@(i)];
            }
        }];
    }
}


#pragma mark - Memory Warning

- (void)growFrameCacheSizeAfterMemoryWarning:(NSNumber *)frameCacheSize {
    self.frameCacheSizeMaxInternal = [frameCacheSize unsignedIntegerValue];
    const NSTimeInterval kResetDelay = 3.0;
    [self.weakProxy performSelector:@selector(resetFrameCacheSizeMaxInternal) withObject:nil afterDelay:kResetDelay];
}


- (void)resetFrameCacheSizeMaxInternal {
    self.frameCacheSizeMaxInternal = LWGIFImageFrameCacheSizeNoLimit;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    
    self.memoryWarningCount ++;
    [NSObject cancelPreviousPerformRequestsWithTarget:self.weakProxy selector:@selector(growFrameCacheSizeAfterMemoryWarning:) object:@(LWGIFImageFrameCacheSizeGrowAfterMemoryWarning)];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.weakProxy selector:@selector(resetFrameCacheSizeMaxInternal) object:nil];
    self.frameCacheSizeMaxInternal = LWGIFImageFrameCacheSizeLowMemory;
    
    const NSUInteger kGrowAttemptsMax = 2;
    const NSTimeInterval kGrowDelay = 2.0;
    
    if ((self.memoryWarningCount - 1) <= kGrowAttemptsMax) {
        [self.weakProxy performSelector:@selector(growFrameCacheSizeAfterMemoryWarning:) withObject:@(LWGIFImageFrameCacheSizeGrowAfterMemoryWarning) afterDelay:kGrowDelay];
    }
}

@end


@implementation LWProxy

+ (instancetype)proxyWithObject:(id)object {
    LWProxy* proxy = [LWProxy alloc];
    proxy.target = object;
    return proxy;
}


- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void* nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

@end

