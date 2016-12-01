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


#import "LWHTMLTextConfig.h"
#import "GallopDefine.h"

@implementation LWHTMLTextConfig


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    LWTextStorage* one = [[LWTextStorage alloc] init];
    one.textColor = [self.textColor copy];
    one.textBackgroundColor = [self.textBackgroundColor copy];
    one.font = [self.font copy];
    one.linespacing = self.linespacing;
    one.characterSpacing = self.characterSpacing;
    one.textAlignment = self.textAlignment;
    one.underlineStyle = self.underlineStyle;
    one.underlineColor = [self.underlineColor copy];
    one.lineBreakMode = self.lineBreakMode;
    one.textDrawMode = self.textDrawMode;
    one.strokeColor = [self.strokeColor copy];
    one.strokeWidth = self.strokeWidth;
    one.extraDisplayIdentifier = [self.extraDisplayIdentifier copy];

    return one;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [self copyWithZone:zone];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.textColor forKey:@"textColor"];
    [aCoder encodeObject:self.textBackgroundColor forKey:@"textBackgroundColor"];
    [aCoder encodeObject:self.font forKey:@"font"];
    [aCoder encodeFloat:self.linespacing forKey:@"linespacing"];
    [aCoder encodeInteger:self.characterSpacing forKey:@"characterSpacing"];
    [aCoder encodeInteger:self.textAlignment forKey:@"textAlignment"];
    [aCoder encodeInteger:self.underlineStyle forKey:@"underlineStyle"];
    [aCoder encodeObject:self.underlineColor forKey:@"underlineColor"];
    [aCoder encodeInteger:self.lineBreakMode forKey:@"lineBreakMode"];
    [aCoder encodeInteger:self.textDrawMode forKey:@"textDrawMode"];
    [aCoder encodeObject:self.strokeColor forKey:@"strokeColor"];
    [aCoder encodeFloat:self.strokeWidth forKey:@"strokeWidth"];
    [aCoder encodeObject:self.extraDisplayIdentifier forKey:@"extraDisplayIdentifier"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.textColor = [aDecoder decodeObjectForKey:@"textColor"];
        self.textBackgroundColor = [aDecoder decodeObjectForKey:@"textBackgroundColor"];
        self.font = [aDecoder decodeObjectForKey:@"font"];
        self.underlineColor = [aDecoder decodeObjectForKey:@"underlineColor"];
        self.strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
        self.extraDisplayIdentifier = [aDecoder decodeObjectForKey:@"extraDisplayIdentifier"];
        self.linespacing = [aDecoder decodeFloatForKey:@"linespacing"];
        self.strokeWidth = [aDecoder decodeFloatForKey:@"strokeWidth"];
        self.characterSpacing = [aDecoder decodeIntegerForKey:@"characterSpacing"];
        self.textAlignment = [aDecoder decodeIntegerForKey:@"textAlignment"];
        self.underlineStyle = [aDecoder decodeIntegerForKey:@"underlineStyle"];
        self.lineBreakMode = [aDecoder decodeIntegerForKey:@"lineBreakMode"];
        self.textDrawMode = [aDecoder decodeIntegerForKey:@"textDrawMode"];
    }
    return self;
}

+ (LWHTMLTextConfig *)defaultsTextConfig {
    static LWHTMLTextConfig* config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[LWHTMLTextConfig alloc] init];
    });
    return config;
}


- (id)init {
    self = [super init];
    if (self) {
        self.textColor = [UIColor blackColor];
        self.textBackgroundColor = [UIColor clearColor];
        self.font = [UIFont systemFontOfSize:14.0f];
        self.textAlignment = NSTextAlignmentLeft;
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.underlineStyle = NSUnderlineStyleNone;
        self.linespacing = 1.0f;
        self.characterSpacing = 0.0f;
        self.textDrawMode = LWTextDrawModeFill;
        self.strokeColor = nil;
        self.strokeWidth = 0.0f;
        self.linkColor = [UIColor blueColor];
        self.linkHighlightColor = RGB(0, 0, 0, 0.35f);
        self.edgeInsets = UIEdgeInsetsZero;
    }
    return self;
}



+ (LWHTMLTextConfig *)defaultsH1TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:20.0f];
    return config;
}

+ (LWHTMLTextConfig *)defaultsH2TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:18.0f];
    return config;
}


+ (LWHTMLTextConfig *)defaultsH3TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:16.0f];
    return config;
}


+ (LWHTMLTextConfig *)defaultsH4TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:14.0f];
    return config;
}


+ (LWHTMLTextConfig *)defaultsH5TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:12.0f];
    return config;
}

+ (LWHTMLTextConfig *)defaultsH6TextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.font = [UIFont boldSystemFontOfSize:10.0f];
    return config;
}

+ (LWHTMLTextConfig *)defaultsParagraphTextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    return config;
}

+ (LWHTMLTextConfig *)defaultsQuoteTextConfig {
    LWHTMLTextConfig* config = [[LWHTMLTextConfig alloc] init];
    config.textColor = [UIColor grayColor];
    return config;
}

@end
