/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/





#import "LWTextParser.h"

#define URLRegular @""
#define EmojiRegular @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define TopicRegular @"#[^#]+#"

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
    for (NSInteger i = resultArray.count - 1; i >= 0; i --) {
        NSTextCheckingResult* match = [resultArray objectAtIndex:i];
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        if (textStorage.text.length >= range.location + range.length) {
            [textStorage replaceTextWithImage:[UIImage imageNamed:content]
                                    imageSize:CGSizeMake(14, 14)
                                      inRange:range];
        }
    }
}


+ (void)parseHttpURLWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle {
    NSString* text = textStorage.text;
    NSArray* resultArray = [URLRegularExpression() matchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage addLinkWithData:content
                             inRange:range
                           linkColor:linkColor
                      highLightColor:higlightColor
                      UnderLineStyle:NSUnderlineStyleSingle];
    }
}


+ (void)parseAccountWithTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle {

    NSString* text = textStorage.text;
    NSArray* resultArray = [AccountRegularExpression() matchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage addLinkWithData:content
                             inRange:range
                           linkColor:linkColor
                      highLightColor:higlightColor
                      UnderLineStyle:underline];
    }
}


+ (void)parseTopicWithLWTextStorage:(LWTextStorage *)textStorage
                          linkColor:(UIColor *)linkColor
                     highlightColor:(UIColor *)higlightColor
                     underlineStyle:(NSUnderlineStyle)underlineStyle {

    NSString* text = textStorage.text;
    NSArray* resultArray = [TopicRegularExpression() matchesInString:text
                                                             options:0
                                                               range:NSMakeRange(0,text.length)];
    for(NSTextCheckingResult* match in resultArray) {
        NSRange range = [match range];
        NSString* content = [text substringWithRange:range];
        [textStorage addLinkWithData:content
                             inRange:range
                           linkColor:linkColor
                      highLightColor:higlightColor
                      UnderLineStyle:underlineStyle];
    }
}

@end
