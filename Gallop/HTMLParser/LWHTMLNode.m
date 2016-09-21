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


#import "LWHTMLNode.h"

@implementation LWHTMLNode

- (id)init {
    self = [super init];
    if (self) {
        self.isTag = NO;
        self.elementName = @"";
        self.attributeDict = [[NSMutableDictionary alloc] init];
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithElementName:(NSString *)elementName {
    self = [super init];
    if (self) {
        if (!elementName) {
            return nil;
        }
        self.isTag = NO;
        self.elementName = [elementName copy];
        self.attributeDict = [[NSMutableDictionary alloc] init];
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithElementName:(NSString *)elementName attributeDict:(NSDictionary *)attributeDict {
    self = [super init];
    if (self) {
        if (!elementName) {
            return nil;
        }
        self.isTag = NO;
        self.elementName = [elementName copy];
        self.attributeDict = [[NSMutableDictionary alloc] init];
        self.children = [[NSMutableArray alloc] init];
        for (NSString* key in attributeDict) {
            [self.attributeDict setObject:attributeDict[key] forKey:key];
        }
    }
    return self;
}

- (id)initWithContentString:(NSString *)contentString {
    self = [super init];
    if (self) {
        self.isTag = NO;
        self.contentString = [contentString copy];
        self.elementName = @"";
        self.attributeDict = [[NSMutableDictionary alloc] init];
        self.children = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
