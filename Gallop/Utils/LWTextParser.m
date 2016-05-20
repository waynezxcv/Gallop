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


#import "LWTextParser.h"

#define EmojiRegular @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"
#define URLRegular @"^(f|ht){1}(tp|tps):\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?"

static inline NSRegularExpression* EmojiRegularExpression() {
    static NSRegularExpression* _EmojiRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _EmojiRegularExpression = [[NSRegularExpression alloc]
                                   initWithPattern:EmojiRegular
                                   options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _EmojiRegularExpression;
}


static inline NSRegularExpression* URLRegularExpression() {
    static NSRegularExpression* _URLRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _URLRegularExpression = [[NSRegularExpression alloc]
                                 initWithPattern:URLRegular
                                 options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _URLRegularExpression;
}

static inline NSRegularExpression* AccountRegularExpression() {
    static NSRegularExpression* _AccountRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AccountRegularExpression = [[NSRegularExpression alloc]
                                     initWithPattern:AccountRegular
                                     options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _AccountRegularExpression;
}


static inline NSRegularExpression* TopicRegularExpression() {
    static NSRegularExpression* _TopicRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TopicRegularExpression = [[NSRegularExpression alloc]
                                   initWithPattern:TopicRegular
                                   options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _TopicRegularExpression;
}


@implementation LWTextParser

+ (void)parseEmojiWithTextStorage:(LWTextStorage *)textStorage {
    NSString* text = textStorage.text;
    NSArray* resultArray = [EmojiRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0,text.length)];

    [resultArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTextCheckingResult* match = [resultArray objectAtIndex:idx];
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage lw_replaceTextWithImage:[UIImage imageNamed:content]
                                     contentMode:UIViewContentModeScaleAspectFill
                                       imageSize:CGSizeMake(14, 14)
                                       alignment:LWTextAttachAlignmentTop
                                           range:range];
        }
    }];
}


+ (void)parseHttpURLWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {
    NSString* text = textStorage.text;
    NSArray* resultArray = [URLRegularExpression() matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0,text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull match, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage lw_addLinkWithData:content range:range linkColor:linkColor highLightColor:higlightColor];
    }];
}


+ (void)parseAccountWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {

    NSString* text = textStorage.text;
    NSArray* resultArray = [AccountRegularExpression() matchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0,text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull match, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage lw_addLinkWithData:content range:range linkColor:linkColor highLightColor:higlightColor];
    }];
}


+ (void)parseTopicWithLWTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor {

    NSString* text = textStorage.text;
    NSArray* resultArray = [TopicRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0,text.length)];
    [resultArray enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull match, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage lw_addLinkWithData:content range:range linkColor:linkColor highLightColor:higlightColor];
    }];
}

@end
