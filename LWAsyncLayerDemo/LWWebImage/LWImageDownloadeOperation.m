//
//  LWImageDownloadeOpertion.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/3.
//  Copyright © 2016年 WayneInc. All rights reserved.//
//

#import "LWImageDownloadeOperation.h"
#import <ImageIO/ImageIO.h>
#import "LWImageCache.h"
#import "LWImageDecoder.h"


@interface LWImageDownloadeOperation ()<NSURLConnectionDelegate>

@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic,readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic,readwrite, getter=isStarted) BOOL started;
@property (nonatomic,strong) NSThread* thread;


@property (nonatomic,strong) NSURLConnection* connection;
@property (nonatomic,strong,readwrite) NSURLRequest* request;
@property (strong, nonatomic) NSURLResponse *response;
@property (nonatomic,strong) NSMutableData* data;
@property (assign, nonatomic) NSInteger expectedSize;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property (nonatomic,assign) BOOL shouldDecompressImages;

@property (nonatomic,assign)LWWebImageOptions options;
@property (nonatomic,copy) LWWebImageDownloadProgressBlock progress;
@property (nonatomic,copy) LWWebImageDownloadCompletionBlock completion;
@property (nonatomic,copy) LWWebImageDownloadTransformBlock transform;



@property (nonatomic,assign) CGImageSourceRef imageSource;
@property (nonatomic,assign,getter=isDownloadFinished) BOOL dowloadFinished;

@end

@implementation LWImageDownloadeOperation {
    size_t width, height;
    UIImageOrientation orientation;
    BOOL responseFromCached;
}

@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;



#pragma mark - Init

- (id)initWithRequest:(NSURLRequest *)request
              options:(LWWebImageOptions)options
             progress:(LWWebImageDownloadProgressBlock)progress
            transform:(LWWebImageDownloadTransformBlock)transform
           completion:(LWWebImageDownloadCompletionBlock)completion{

    self = [super init];
    if (self) {
        self.request = request;
        self.options = options;
        self.progress = [progress copy];
        self.completion = [completion copy];
        self.transform = [transform copy];
        self.executing = NO;
        self.finished = NO;
        self.cancelled = NO;
        self.shouldDecompressImages = YES;
        self.backgroundTaskId = UIBackgroundTaskInvalid;
        self.imageSource = CGImageSourceCreateIncremental(NULL);
        self.dowloadFinished = NO;
    }
    return self;
}

#pragma mark - overwrite

//是否并发
- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    //    NSLog(@"下载所在的线程：%@",[NSThread currentThread]);
    @autoreleasepool {
        //加锁
        @synchronized (self) {
            //如果取消，则reset，返回
            if (self.isCancelled) {
                [self cancel];
                self.finished = YES;
                [self reset];
                return;
            } else  {
                //如果self.request不存在，返回error
                if (!self.request) {
                    self.finished = YES;
                    if (self.completion) {
                        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                             code:NSURLErrorFileDoesNotExist
                                                         userInfo:@{NSLocalizedDescriptionKey:@"request in nil"}];
                        self.completion(nil,self.request.URL,error,NO);
                    }
                } else {
                    //如果需要的话，进行后台任务处理
                    [self beginBackgroundTaskIfNeed];
                    self.executing = YES;
                    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
                    [[NSThread currentThread] setName:@"waynezxcvdownloadThread"];
                    self.thread = [NSThread currentThread];
                }
            }
        }
        //开始请求
        [self.connection start];
        if (self.connection) {
            //请求进度
            if (self.progress) {
                self.progress(0, NSURLResponseUnknownLength,0);
            }
            //在当前线程创建Runloop，防止线程被回收。若不创建，子线程的NSURLConnection无法收到回调
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
            }
            else {
                CFRunLoopRun();
            }
            if (!self.isFinished) {
                [self.connection cancel];
                [self connection:self.connection didFailWithError:
                 [NSError errorWithDomain:NSURLErrorDomain
                                     code:NSURLErrorTimedOut
                                 userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
            }
        }
        //如果connection不存在，返回error
        else {
            if (self.completion) {
                NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Connection can't be initialized"}];
                self.completion(nil, self.request.URL,error,NO);
            }
        }
        //如果需要的话，结束后台任务处理
        [self endBackgroundTaskIfNeed];
    }
}


//如果需要的话，进行后台任务处理
- (void)beginBackgroundTaskIfNeed {
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
    if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
        __weak __typeof__ (self) wself = self;
        UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            if (sself) {
                [sself cancel];
                [app endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
    }
#endif
}

//如果需要的话，结束后台任务处理
- (void)endBackgroundTaskIfNeed {
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}

//是否继续在后台运行
- (BOOL)shouldContinueWhenAppEntersBackground {
    return YES;
}

//重写cancel方法
- (void)cancel {
    //    NSLog(@"cancel Operation");
    //线程同步
    @synchronized (self) {
        //取消操作，如果是在子线程中执行，结束子线程的Runloop
        if (self.thread) {
            [self performSelector:@selector(cancelInternalAndStop)
                         onThread:self.thread
                       withObject:nil
                    waitUntilDone:NO];
        }
        //取消操作
        else {
            [self cancelInternal];
        }
    }
}

//取消操作，如果是在子线程中执行，结束子线程的Runloop
- (void)cancelInternalAndStop {
    if (self.isFinished) {
        return;
    }
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

//取消操作
- (void)cancelInternal {
    if (self.isFinished) {
        return;
    }
    self.cancelled = YES;
    [super cancel];
    if (self.isExecuting) {
        self.executing = NO;
    }
    if (!self.isFinished) {
        self.finished = YES;
    }
    [self reset];
}

//完成
- (void)done {
    self.finished = YES;
    self.executing = NO;
    self.cancelled = NO;
    [self reset];
}

//复位
- (void)reset {
    self.thread = nil;
    self.connection = nil;
    self.progress = nil;
    self.completion = nil;
    self.transform = nil;
    self.data = nil;
    self.request = nil;
    self.imageSource = NULL;
}

#pragma mark - Setter
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}


- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
}


#pragma mark - NSURLConnectionDelegate

//接收到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //如果StatusCode正常
    if (![response respondsToSelector:@selector(statusCode)] ||
        ([((NSHTTPURLResponse *)response) statusCode] < 400 &&
         [((NSHTTPURLResponse *)response) statusCode] != 304)) {
            NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
            self.expectedSize = expected;
            if (self.progress) {
                self.progress(0, expected,0);
            }
            self.data = [[NSMutableData alloc] initWithCapacity:expected];
            self.response = response;
        }
    //处理StatusCode异常
    else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        if (code == 304) {
            [self cancelInternal];
        } else {
            [self.connection cancel];
        }
        if (self.completion) {
            self.completion(nil, self.request.URL, [NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil],NO);
        }
        CFRunLoopStop(CFRunLoopGetCurrent());
        [self done];
    }
}

//接收到服务器的数据时
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @autoreleasepool {
        //拼接数据
        [self.data appendData:data];
        //计算下载进度
        if (self.progress) {
            CGFloat percent = (float)self.data.length / (float)self.expectedSize;
            self.progress(self.data.length, self.expectedSize,percent);
        }

        //Leak？？？？？
        //逐步地加载一幅图像：
        if (self.completion) {
            //更新imageSource的数据
            CGImageSourceUpdateData(self.imageSource,(__bridge CFDataRef)self.data, false);
            //创建CGImage
            CGImageRef cgImage = CGImageSourceCreateImageAtIndex(_imageSource,0, (__bridge CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
            //更新到UIImage
            UIImage* image = [UIImage imageWithCGImage:cgImage];
            //释放内存
            if (image) {
                CFRelease(cgImage);
            }
            //如果是非GIF图片.解压图片为位图
            if (!image.images) {
                if (self.shouldDecompressImages) {
                    LWImageDecoder* decoder = [LWImageDecoder sharedDecoder];
                    image = [decoder decodedImageWithImage:image];
                }
            }
            self.completion(image,self.request.URL,nil,NO);
        }
    }
}

//数据加载完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    @autoreleasepool {

        @synchronized(self) {
            CFRunLoopStop(CFRunLoopGetCurrent());
            self.thread = nil;
            self.connection = nil;
        }
        if (![[NSURLCache sharedURLCache] cachedResponseForRequest:_request]) {
            responseFromCached = NO;
        }
        if (self.completion) {
            if (self.data) {
                //创建CGImage
                CGImageRef cgImage = CGImageSourceCreateImageAtIndex(self.imageSource,0, (__bridge CFDictionaryRef)@{(id)kCGImageSourceShouldCache:@(YES)});
                //更新到UIImage
                UIImage* image = [UIImage imageWithCGImage:cgImage];
                if (image) {
                    CFRelease(cgImage);
                }
                if (self.transform) {
                    UIImage* newImage = self.transform(image);
                    if (newImage != nil) {
                        image = newImage;
                    }
                }
                //NSLog(@"解压前的文件大小:%ld...",self.data.length);
                // 如果是非GIT图片.解压图片为位图
                if (!image.images) {
                    if (self.shouldDecompressImages) {
                        LWImageDecoder* decoder = [LWImageDecoder sharedDecoder];
                        image = [decoder decodedImageWithImage:image];
                        //NSLog(@"解压为位图后文件大小:%ld", UIImageJPEGRepresentation(image,1).length);
                    }
                }
                //图片大小为0
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    self.completion(nil, self.request.URL, [NSError errorWithDomain:NSURLErrorDomain
                                                                               code:0
                                                                           userInfo:@{NSLocalizedDescriptionKey :
                                                                                          @"Downloaded image has 0 pixels"}],YES);
                } else {
                    if (self.isCancelled) {
                        return;
                    }
                    self.dowloadFinished = YES;
                    self.completion(image, self.request.URL, nil,YES);
                }
            } else {

                self.completion(nil, self.request.URL, [NSError errorWithDomain:NSURLErrorDomain
                                                                           code:0
                                                                       userInfo:@{NSLocalizedDescriptionKey :
                                                                                      @"Image data is nil"}],YES);
            }

        }
        self.completionBlock = nil;
        [self done];
    }
}

//请求失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @autoreleasepool {
        @synchronized(self) {
            CFRunLoopStop(CFRunLoopGetCurrent());
            self.thread = nil;
            self.connection = nil;
        }
        if (self.completion) {
            self.completion(nil, self.request.URL, error,YES);
        }
        self.completion = nil;
        [self done];
    }
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    @autoreleasepool {

        responseFromCached = NO;
        if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
            return nil;
        }
        else {
            return cachedResponse;
        }
    }
}

+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value {
    switch (value) {
        case 1:
            return UIImageOrientationUp;
        case 3:
            return UIImageOrientationDown;
        case 8:
            return UIImageOrientationLeft;
        case 6:
            return UIImageOrientationRight;
        case 2:
            return UIImageOrientationUpMirrored;
        case 4:
            return UIImageOrientationDownMirrored;
        case 5:
            return UIImageOrientationLeftMirrored;
        case 7:
            return UIImageOrientationRightMirrored;
        default:
            return UIImageOrientationUp;
    }
}

@end
