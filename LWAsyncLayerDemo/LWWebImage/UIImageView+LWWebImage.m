//
//  UIImageView+LWWebImage.m
//  LWWebImage
//
//  Created by 刘微 on 16/1/4.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "UIImageView+LWWebImage.h"
#import "LWWebImageManager.h"
#import "UIImage+LWWebImage.h"
#import <objc/runtime.h>


@implementation UIImageView (LWWebImageManager)

//const void* imageURLKey = (void *)@"imageURLKey";
//
//- (void)lw_setImageWithURL:(NSURL *)URL {
//    if (![self.imageURL isEqualToString:URL.absoluteString]) {
//        //取消之前的下载
//        [self cancelCurrentOperation];
//        //对imageURL重新赋值
//        [self setImageURL:URL.absoluteString];
//    }
//
//    BOOL isFade = YES;
//
//    __weak typeof(self) weakSelf = self;
//    //开始读取图片
//    LWWebImageManager* manager = [LWWebImageManager sharedManager];
//    NSOperation* operation = [manager requestImageWithURL:URL
//                                           dowloadOptions:0
//                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat percent) {
//
//                                                 } transform:nil
//                                               completion:^(UIImage *image, NSURL *url, NSError *error, BOOL isFinished) {
//                                                   if (isFinished) {
//                                                       weakSelf.image = (__bridge id _Nullable)(image.CGImage);
//                                                       if (isFade) {
//                                                           CATransition*transition = [CATransition animation];
//                                                           transition.duration = 0.3f;
//                                                           transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//                                                           transition.type = kCATransitionFade;
//                                                           [self.layer addAnimation:transition forKey:@"LWWebImageFadeAnimation"];
//                                                       }
//                                                   }
//                                               }];
//    NSLog(@"currentOperations:%ld",[manager currentRunningOperationCount]);
//    if (operation) {
//        [self setLoadOperationKey:operation forKey:URL.absoluteString];
//    }
//}
//
//- (void)cancelCurrentOperation {
//    NSOperation* lastOperation = [self getLoadOperationForKey:self.imageURL];
//    if (!lastOperation) {
//        return;
//    }
//    [lastOperation cancel];
//    lastOperation = nil;
//}
//
//- (void)setImageURL:(NSString *)imageURL {
//    objc_setAssociatedObject(self, imageURLKey, imageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSString *)imageURL {
//    return objc_getAssociatedObject(self, imageURLKey);
//}
//
//
//
//- (void)setLoadOperationKey:(NSOperation *)loadOperation forKey:(NSString *)urlKey{
//    const void* key = (__bridge void*)urlKey;
//    objc_setAssociatedObject(self, key, loadOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (NSOperation *)getLoadOperationForKey:(NSString *)urlKey {
//    const void* key = (__bridge void*)urlKey;
//    return objc_getAssociatedObject(self, key);
//}
//

@end
