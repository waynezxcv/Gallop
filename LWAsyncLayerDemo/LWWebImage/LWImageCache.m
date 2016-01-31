//
//  LWImageCache.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/4.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "LWImageDecoder.h"


@interface LWImageCache ()

@property (nonatomic,strong) NSString* diskCachePath;
@property (nonatomic) dispatch_queue_t ioQueue;
@property (nonatomic,strong) NSFileManager* fileManager;

@end


//默认的缓存时间为1周
static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7;

//默认的缓存最大缓存量100M
static const NSInteger kDefaultDiskCacheCost = 1048576 * 100;

@implementation LWImageCache

//创建单例
+(LWImageCache *)sharedImageCache {
    static dispatch_once_t once;
    static LWImageCache* sharedCache;
    dispatch_once(&once, ^{
        sharedCache = [[LWImageCache alloc] init];
    });
    return sharedCache;
}

//初始化
- (id)init {
    self = [super init];
    if (self) {
        self.shouldDecompressImages = YES;
        //初始化DiskCache存储路径
        NSString* nameSpace = @"LWImageCache";
        NSString* fullNamespace = [@"com.waynezxcv." stringByAppendingString:nameSpace];
        NSString* directory = [self makeDiskCachePath:nameSpace];
        if (directory != nil) {
            self.diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
        } else {
            NSString *path = [self makeDiskCachePath:nameSpace];
            self.diskCachePath = path;
        }
        //初始化最大硬盘缓存周期
        self.maxCacheAge = kDefaultCacheMaxCacheAge;
        //初始化最大硬盘缓存容量
        self.maxDiskCacheCost = kDefaultDiskCacheCost;
        //初始化内存缓存
        self.memoryCache = [[NSCache alloc] init];
        //创建一个文件读写队列
        _ioQueue = dispatch_queue_create("com.waynezxcv.ioQueue", DISPATCH_QUEUE_CONCURRENT);
        //在文件读写队列创建NSFileManager
        dispatch_async(self.ioQueue, ^{
            @synchronized(self) {
                self.fileManager = [NSFileManager defaultManager];
            }
        });
        //注册内存警告通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        //注册应用即将关闭通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        //注册应用即将进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}


#pragma mark - Setter

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit {
    _totalCostLimit = totalCostLimit;
    self.memoryCache.totalCostLimit = self.totalCostLimit;
}

- (void)setCountLimit:(NSUInteger)countLimit {
    _totalCostLimit = countLimit;
    self.memoryCache.countLimit = self.countLimit;
}

- (void)setEvictsObjectsWithDiscardedContent:(BOOL)evictsObjectsWithDiscardedContent {
    _evictsObjectsWithDiscardedContent = evictsObjectsWithDiscardedContent;
    self.memoryCache.evictsObjectsWithDiscardedContent = evictsObjectsWithDiscardedContent;
}

#pragma mark -- Read
/************************** 读取 ******************************/
//从缓存读取图片
- (void)imageFromCacheForKey:(NSString *)cacheKey Completion:(LWWebImageQueryCompletedBlock)completion {
    __weak LWImageCache* weakSelf = self;
    dispatch_async(self.ioQueue, ^{
        //先从内存中读 。。。。NSCache是线程安全的，不需要加锁
        UIImage* image = [weakSelf imageFromMemoryCacheForKey:cacheKey];
        if (image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image,LWImageCacheTypeMemory);
            });
        } else {
            //若内存中不存在则从硬盘中读，然后放到内存中.为了线程安全有两种方法来来确保线程同步：
            //1.添加互斥锁@synchronized().这里采用的方法
            //2.创建一个全局变量串行队列queue，把所有线程的操作都加到一个queue中去
            //这里采用的是加互斥锁的方法
            UIImage* image = [weakSelf imageFromDiskCacheForKey:cacheKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image,LWImageCacheTypeDisk);
            });
        }
    });

}

//通过CacheKey获取内存缓存图片
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)cacheKey {
    return [self.memoryCache objectForKey:cacheKey];
}

//通过CacheKey获取硬盘缓存图片
- (UIImage *)imageFromDiskCacheForKey:(NSString *)cacheKey {
    UIImage *diskImage = [self diskImageForKey:cacheKey];
    //将读取的图片放到内存中
    if (diskImage) {
        [self saveToMemoryWithImamge:diskImage forkey:cacheKey];
    }
    return diskImage;
}

//从硬盘读取图片
- (UIImage *)diskImageForKey:(NSString *)key {
    //    NSLog(@"从磁盘读取图片所属的线程:%@",[NSThread currentThread]);
    @synchronized(self) {
        NSData *data = [self diskImageDataBySearchingAllPathsForKey:key];
        //        NSLog(@"解压前的文件大小:%ld...",data.length);
        if (data) {
            UIImage* image = [UIImage imageWithData:data];
            if (self.shouldDecompressImages) {
                LWImageDecoder* decoder = [LWImageDecoder sharedDecoder];
                image = [decoder decodedImageWithImage:image];
//                NSLog(@"解压为位图后文件大小:%ld", UIImageJPEGRepresentation(image,1).length);
            }
            return image;
        }
        else {
            return nil;
        }
    }
}

//通过路径查找文件
- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key {
    NSString *defaultPath = [self defaultCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data) {
        return data;
    }
    return nil;
}


//是否存在硬盘缓存
- (BOOL)diskImageExistsWithKey:(NSString *)cacheKey {
    BOOL exists = NO;
    exists = [[NSFileManager defaultManager] fileExistsAtPath:[self defaultCachePathForKey:cacheKey]];
    return exists;
}


#pragma mark -- Write

/************************ 写入 ******************************/

//将一张图片写入到缓存
- (void)saveToImageCacheWithImage:(UIImage *)image forkey:(NSString *)cacheKey {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.ioQueue, ^{
        //    NSLog(@"写入内存缓存所在线程%@",[NSThread currentThread]);
        //1.先将图片写入内存缓存. .NSCache是线程安全的。。
        [weakSelf saveToMemoryWithImamge:image forkey:cacheKey];
        //2/将图片写入硬盘
        [weakSelf saveToDiskWithImage:image forkey:cacheKey];
    });
}

//将一张图片保存到内存缓存
- (void)saveToMemoryWithImamge:(UIImage *)image forkey:(NSString *)cacheKey {
    if (!image || !cacheKey) {
        return;
    }
    [self.memoryCache setObject:image forKey:cacheKey];
}


//将一张图片保存到硬盘
- (void)saveToDiskWithImage:(UIImage *)image forkey:(NSString *)cacheKey {
    //    NSLog(@"写入磁盘所在线程:%@",[NSThread currentThread]);
    @synchronized(self) {
        if (!image || !cacheKey) {
            return;
        }
        NSData* data = UIImageJPEGRepresentation(image, 0.99);
        if (data) {
            if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            [_fileManager createFileAtPath:[self defaultCachePathForKey:cacheKey] contents:data attributes:nil];
        }
    }
}

#pragma mark - Remove

//内存不足时，清除所有MemoryCache
- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}

- (void)cleanDisk {
    [self cleanDiskWithCompletionBlock:nil];
}

- (void)backgroundCleanDisk {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication* application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    [self cleanDiskWithCompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)cleanDiskWithCompletionBlock:(LWWebImageNoParametersBlock)completion {
    dispatch_async(self.ioQueue, ^{
        @synchronized(self) {
            NSURL* diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
            NSArray* resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey,NSURLContentAccessDateKey];

            NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:resourceKeys
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
            //计算缓存过期时间，一周之前
            NSDate* expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
            NSMutableDictionary* cacheFiles = [NSMutableDictionary dictionary];
            NSUInteger currentCacheSize = 0;

            //遍历缓存文件路径，来清除那些缓存过期的文件
            //创建一个数组来保存需要删除的URL
            NSMutableArray* urlsToDelete = [[NSMutableArray alloc] init];

            for (NSURL* fileURL in fileEnumerator) {
                NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
                if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                    continue;
                }
                //获取文件的修改时间
                NSDate* modificationDate = resourceValues[NSURLContentModificationDateKey];
                if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                    [urlsToDelete addObject:fileURL];
                    continue;
                }
                NSNumber* totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
                [cacheFiles setObject:resourceValues forKey:fileURL];
            }

            for (NSURL* fileURL in urlsToDelete) {
                [self.fileManager removeItemAtURL:fileURL error:nil];
            }

            //若缓存容量大于maxCacheCost
            if (self.maxDiskCacheCost > 0 && currentCacheSize > self.maxDiskCacheCost) {
                //清除掉一半的缓存文件
                const NSUInteger desiredCacheSize = self.maxDiskCacheCost/2;

                /**************
                 //按照文件的最近打开的时间排序。这里使用LRU缓存算法 ..获取NSURLContentAccessDateKey。
                 ********************/
                NSArray* sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                    return [obj1[NSURLContentAccessDateKey] compare:obj2[NSURLContentAccessDateKey]];
                                                                }];

                //删除缓存文件，直到存储空间到预期的大小
                for (NSURL* fileURL in sortedFiles) {
                    if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                        NSDictionary* resourceValues = cacheFiles[fileURL];
                        NSNumber* totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                        currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                        if (currentCacheSize < desiredCacheSize) {
                            break;
                        }
                    }
                }
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}


//通过Key将一张图片存内存缓存中移除
- (void)removeObjectFromMemoryForKey:(NSString *)cacheKey {
    [self.memoryCache removeObjectForKey:cacheKey];
}

//通过Key将一张图片从硬盘中删除
- (void)removeObjectFromDiskForKey:(NSString *)cacheKey {

    dispatch_async(self.ioQueue, ^{
        @synchronized(self) {
            [self.fileManager removeItemAtURL:[NSURL URLWithString:[self defaultCachePathForKey:cacheKey]] error:nil];
        }
    });
}

//移除所有MemoryCache
- (void)removeAllMemoryCacheObjects {
    [self.memoryCache removeAllObjects];
}

//移除所有DiskCache
- (void)removeAllDiskCacheObjects {
    dispatch_async(self.ioQueue, ^{
        @synchronized(self) {
            NSURL* diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
            NSArray* resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey,NSURLContentAccessDateKey];
            NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:resourceKeys
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
            NSMutableArray* urlsToDelete = [[NSMutableArray alloc] init];
            for (NSURL* fileURL in fileEnumerator) {
                [urlsToDelete addObject:fileURL];
            }
            for (NSURL* fileURL in urlsToDelete) {
                [self.fileManager removeItemAtURL:fileURL error:nil];
            }
        }
    });
}


#pragma mark - FilePath (private)

//硬盘存储路径
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

//获取默认的存储路径
- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

//拼接存储路径
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

//获取存储的文件名（MD5-Hash）
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char* str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString* filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

#pragma mark - Description

- (NSString *)description {
    if (self.name) {
        return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    }
    else {
        return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
    }
}

@end
