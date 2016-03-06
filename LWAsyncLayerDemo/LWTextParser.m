//
//  LWTextParser.m
//  LWAsyncLayerDemo
//
//  Created by 刘微 on 16/3/7.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import "LWTextParser.h"

#define EmojiRegular @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#define URLRegular @""
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"

static inline NSRegularExpression* EmojiRegularExpression() {
    static NSRegularExpression* _EmojiRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _EmojiRegularExpression = [[NSRegularExpression alloc] initWithPattern:EmojiRegular options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _EmojiRegularExpression;
}


static inline NSRegularExpression* URLRegularExpression() {
    static NSRegularExpression* _URLRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _URLRegularExpression = [[NSRegularExpression alloc] initWithPattern:URLRegular options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _URLRegularExpression;
}

static inline NSRegularExpression* AccountRegularExpression() {
    static NSRegularExpression* _AccountRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AccountRegularExpression = [[NSRegularExpression alloc] initWithPattern:AccountRegular options:NSRegularExpressionAnchorsMatchLines error:nil];
    });
    return _AccountRegularExpression;
}


static inline NSRegularExpression* TopicRegularExpression() {
    static NSRegularExpression* _TopicRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TopicRegularExpression = [[NSRegularExpression alloc] initWithPattern:TopicRegular options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _TopicRegularExpression;
}


@implementation LWTextParser

+ (void)parseEmojiWithTextLayout:(LWTextLayout *)textLayout {
    NSString* text = textLayout.text;
    NSArray* resultArray = [EmojiRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textLayout replaceTextWithImage:[UIImage imageNamed:content] inRange:range];
    }
}

+ (void)parseHttpURLWithTextLayout:(LWTextLayout *)textLayout
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor
                    underlineStyle:(NSUnderlineStyle)underlineStyle {
    NSString* text = textLayout.text;
    NSArray* resultArray = [URLRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textLayout addLinkWithData:content
                            inRange:range
                          linkColor:linkColor
                     highLightColor:higlightColor
                     UnderLineStyle:NSUnderlineStyleSingle];
    }
}


+ (void)parseAccountWithTextLayout:(LWTextLayout *)textLayout
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor
                    underlineStyle:(NSUnderlineStyle)underlineStyle {
    
    NSString* text = textLayout.text;
    NSArray* resultArray = [AccountRegularExpression() matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textLayout addLinkWithData:content
                            inRange:range
                          linkColor:linkColor
                     highLightColor:higlightColor
                     UnderLineStyle:underline];
    }
}


+ (void)parseTopicWithTextLayout:(LWTextLayout *)textLayout
                         linkColor:(UIColor *)linkColor
                    highlightColor:(UIColor *)higlightColor
                    underlineStyle:(NSUnderlineStyle)underlineStyle {
    
    NSString* text = textLayout.text;
    NSArray* resultArray = [TopicRegularExpression() matchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textLayout addLinkWithData:content
                            inRange:range
                          linkColor:linkColor
                     highLightColor:higlightColor
                     UnderLineStyle:underlineStyle];
    }
}

@end
