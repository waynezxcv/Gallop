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

#import "LWAsyncImageView.h"
#import "SDWebImageManager.h"







@interface LWAsyncImageView (WebCacheOperation)


/**
 *  把NSOperation对象设置到LWAsyncImageView的关联对象operationDictionary上，用于取消操作
 *
 *  @param operation operation对象
 *  @param key       operation对象存在字典中的key
 */

- (void)lw_setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key;


/**
 *  取消这个LWAsyncImageView上的一个下载任务
 *
 *  @param key       operation对象存在字典中的key
 */
- (void)lw_cancelImageLoadOperationWithKey:(nullable NSString *)key;



/**
 *  将一个operation对象从关联对象operationDictionary中移除
 *
 */
- (void)lw_removeImageLoadOperationWithKey:(nullable NSString *)key;

@end
