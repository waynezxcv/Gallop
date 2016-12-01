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

#import "LWTextGlyph.h"

@implementation LWTextGlyph

- (id)init {
    self = [super init];
    if (self) {
        self.position = CGPointZero;
        self.ascent = 0.0f;
        self.descent = 0.0f;
        self.leading = 0.0f;
        self.width = 0.0f;
        self.height = 0.0f;
    }
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.glyph forKey:@"glyph"];
    [aCoder encodeFloat:self.ascent forKey:@"ascent"];
    [aCoder encodeFloat:self.descent forKey:@"descent"];
    [aCoder encodeFloat:self.leading forKey:@"leading"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeCGPoint:self.position forKey:@"position"];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.glyph = [aDecoder decodeIntegerForKey:@"glyph"];
        self.ascent = [aDecoder decodeFloatForKey:@"ascent"];
        self.descent = [aDecoder decodeFloatForKey:@"descent"];
        self.leading = [aDecoder decodeFloatForKey:@"leading"];
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.position = [aDecoder decodeCGPointForKey:@"position"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextGlyph* one = [[LWTextGlyph alloc] init];
    one.glyph = self.glyph;
    one.position = self.position;
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.leading = self.leading;
    one.width = self.width;
    one.height = self.height;
    return one;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

@end
