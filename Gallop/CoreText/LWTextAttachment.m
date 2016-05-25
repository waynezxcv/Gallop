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

#import "LWTextAttachment.h"
#import <objc/runtime.h>
#import "GallopUtils.h"

@implementation LWTextAttachment

+ (id)lw_textAttachmentWithContent:(id)content {
    LWTextAttachment* attachment = [[LWTextAttachment alloc] init];
    attachment.content = content;
    attachment.contentMode = UIViewContentModeScaleAspectFill;
    attachment.contentEdgeInsets = UIEdgeInsetsZero;
    return attachment;
}

- (id)init {
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentEdgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()


@end


@implementation LWTextHighlight

- (id)init {
    self = [super init];
    if (self) {
        self.content = nil;
        self.range = NSMakeRange(0, 0);
        self.linkColor = [UIColor clearColor];
        self.hightlightColor = [UIColor clearColor];
        self.positions = @[];
        self.userInfo = @{};
    }
    return self;
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()


@end


@implementation LWTextBackgroundColor

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.range = NSMakeRange(0, 0);
        self.userInfo = @{};
    }
    return self;
}

#pragma mark - NSCoding

LWSERIALIZE_CODER_DECODER();


#pragma mark - NSCopying

LWSERIALIZE_COPY_WITH_ZONE()




@end

