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


#import "LWStorageBuilder.h"
#import "LWHTMLParser.h"
#import "NSMutableAttributedString+Gallop.h"



typedef NS_ENUM(NSUInteger, LWElementType) {
    LWHTMLElementTypeText = 0,
    LWHTMLElementTypeImage,
    LWElementTypeLink
};

@interface LWStorageBuilder ()<LWHTMLParserDelegate>

@property (nonatomic,strong) LWHTMLParser* parser;
@property (nonatomic,copy) NSString* xpath;
@property (nonatomic,copy) NSArray<LWStorage *>* storages;
@property (nonatomic,assign) CGFloat offsetY;
@property (nonatomic,copy) NSDictionary* configDict;
@property (nonatomic,assign) UIEdgeInsets edgeInsets;

@property (nonatomic,assign) BOOL isTagEnd;
@property (nonatomic,copy) NSString* parentTag;
@property (nonatomic,assign) LWElementType currentType;
@property (nonatomic,strong) _LWHTMLLink* currentLink;
@property (nonatomic,strong) _LWHTMLTag* currentTag;

@property (nonatomic,strong) NSMutableString* contentString;
@property (nonatomic,strong) NSMutableArray* tmpStorages;
@property (nonatomic,strong) NSMutableString* tmpString;
@property (nonatomic,strong) NSMutableArray* tmpLinks;
@property (nonatomic,strong) NSMutableArray* tmpTags;
@property (nonatomic,strong) NSMutableArray* imageCallbacksArray;

@end


@implementation LWStorageBuilder

#pragma mark - Init

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    if (!data) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.isTagEnd = YES;
        self.offsetY = 0.0f;
        self.parser = [[LWHTMLParser alloc] initWithData:data encoding:encoding];
        self.parser.delegate = self;
        self.imageCallbacksArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - CreateLWStorage

- (void)createLWStorageWithXPath:(NSString *)xpath
                      edgeInsets:(UIEdgeInsets)edgeInsets
                configDictionary:(NSDictionary *)dict {
    self.xpath = [xpath copy];
    self.edgeInsets = edgeInsets;
    self.offsetY = self.edgeInsets.top;
    self.configDict = [dict copy];
    [self.parser startSearchWithXPathQuery:xpath];
}

- (void)createLWStorageWithXPath:(NSString *)xpath {
    self.xpath = [xpath copy];
    self.edgeInsets = UIEdgeInsetsZero;
    self.offsetY = self.edgeInsets.top;
    self.configDict = nil;
    [self.parser startSearchWithXPathQuery:xpath];
}

#pragma mark - Getter
- (NSArray<LWStorage *>*)storages {
    return [self.tmpStorages copy];
}

- (LWStorage *)firstStorage {
    if (self.tmpStorages.count) {
        return [self.tmpStorages objectAtIndex:0];
    }
    return nil;
}

- (LWStorage *)lastStorage {
    return [self.tmpStorages lastObject];
}

- (NSString *)contents {
    return [self.contentString copy];
}

- (NSArray<LWImageStorage *>*)imageCallbacks {
    return self.imageCallbacksArray;
}

#pragma mark - ParserDelegate

- (void)parserDidStartDocument:(LWHTMLParser *)parser {
    self.contentString = [[NSMutableString alloc] init];
    [self.tmpStorages removeAllObjects];
}

- (void)parser:(LWHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"html"] || [elementName isEqualToString:@"body"]) {
        return;
    }
    if (self.isTagEnd) {
        self.isTagEnd = NO  ;
        self.parentTag = elementName;
        self.tmpString = [[NSMutableString alloc] init];
        self.tmpLinks = [[NSMutableArray alloc] init];
        self.tmpTags = [[NSMutableArray alloc] init];
    }
    LWElementType type = [self _elementTypeWithElementName:elementName];
    switch (type) {
        case LWHTMLElementTypeText: {
            self.currentType = LWHTMLElementTypeText;
            self.currentTag = [[_LWHTMLTag alloc] init];
            self.currentTag.tagName = elementName;
            self.currentTag.isParent = NO;
            if ([self.parentTag isEqualToString:elementName]) {
                self.currentTag.isParent = YES;
            }
        }break;
        case LWHTMLElementTypeImage: {
            self.currentType = LWHTMLElementTypeImage;
            if (attributeDict[@"src"]) {
                LWHTMLImageConfig* imageConfig = [LWHTMLImageConfig defaultsConfig];
                if (self.configDict[@"img"] && [self.configDict[@"img"] isKindOfClass:[LWHTMLImageConfig class]]) {
                    imageConfig = self.configDict[@"img"];
                }
                LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
                imageStorage.contents = [NSURL URLWithString:[NSString stringWithFormat:@"%@",(NSString *)attributeDict[@"src"]]];
                CGFloat width = (imageConfig.size.width >= SCREEN_WIDTH - self.edgeInsets.left - self.edgeInsets.right) ?
                SCREEN_WIDTH - self.edgeInsets.left - self.edgeInsets.right : imageConfig.size.width;
                imageStorage.frame = CGRectMake(self.edgeInsets.left,
                                                self.edgeInsets.top,
                                                width,
                                                imageConfig.size.height);
                imageStorage.clipsToBounds = YES;
                imageStorage.placeholder = imageConfig.placeholder;
                imageStorage.htmlLayoutEdgeInsets = self.edgeInsets;
                
                if (imageConfig.autolayoutHeight) {
                    imageStorage.needResize = YES;
                }
                
                imageStorage.userInteractionEnabled = imageConfig.userInteractionEnabled;
                self.offsetY += (imageStorage.height + imageConfig.paragraphSpacing);
                [self.tmpStorages addObject:imageStorage];
                if (imageConfig.needAddToImageBrowser && ![self.imageCallbacksArray containsObject:imageStorage]) {
                    [self.imageCallbacksArray addObject:imageStorage];
                }
            }
        }break;
        case LWElementTypeLink: {
            self.currentType = LWElementTypeLink;
            if (!self.currentLink) {
                self.currentLink = [[_LWHTMLLink alloc] init];
                self.currentLink.URL = attributeDict[@"href"];
            }
        }break;
    }
}

- (void)parser:(LWHTMLParser *)parser foundCharacters:(NSString *)string {
    if (!string || !string.length) {
        return;
    }
    [self.contentString appendString:string];
    switch (self.currentType) {
        case LWHTMLElementTypeText: {
            if (self.tmpString) {
                if (self.currentTag) {
                    self.currentTag.range =  NSMakeRange(self.tmpString.length, string.length);
                }
                [self.tmpString appendString:string];
                if (![self.currentTag.tagName isEqualToString:self.parentTag]) {
                    _LWHTMLTag* aTag = [[_LWHTMLTag alloc] init];
                    aTag.range = self.currentTag.range;
                    aTag.tagName = [self.currentTag.tagName copy];
                    aTag.isParent = self.currentTag.isParent;
                    if (aTag.tagName) {
                        [self.tmpTags addObject:aTag];
                    }
                }
                self.currentTag = nil;
            }
        } break;
        case LWElementTypeLink: {
            if (self.currentLink) {
                self.currentLink.range = NSMakeRange(self.tmpString.length, string.length);
                [self.tmpString appendString:string];
                _LWHTMLLink* aLink = [[_LWHTMLLink alloc] init];
                aLink.URL = [self.currentLink.URL copy];
                aLink.range = self.currentLink.range;
                [self.tmpLinks addObject:aLink];
                self.currentLink = nil;
            }
        } break;
        case LWHTMLElementTypeImage:
            break;
    }
}

- (void)parser:(LWHTMLParser *)parser didEndElement:(NSString *)elementName {
    if (![self.parentTag isEqualToString:elementName]) {
        self.currentType = [self _elementTypeWithElementName:self.parentTag];
        return;
    }
    self.isTagEnd = YES;
    NSMutableAttributedString* attributedString = nil;
    LWHTMLTextConfig* config = [LWHTMLTextConfig defaultsTextConfig];
    if (self.configDict[elementName] && [self.configDict[elementName] isKindOfClass:[LWHTMLTextConfig class]]) {
        config = self.configDict[elementName];
    }
    NSString* string = [[self.tmpString stringByNormalizingWhitespace] copy];
    NSRange range = NSMakeRange(0, string.length);
    attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setTextColor:config.textColor range:range];
    [attributedString setTextBackgroundColor:config.textBackgroundColor range:range];
    [attributedString setFont:config.font range:range];
    [attributedString setLineSpacing:config.linespacing range:range];
    [attributedString setCharacterSpacing:config.characterSpacing range:range];
    [attributedString setTextAlignment:config.textAlignment range:range];
    [attributedString setUnderlineStyle:config.underlineStyle underlineColor:config.underlineColor range:range];
    [attributedString setLineBreakMode:config.lineBreakMode range:range];
    for (NSInteger i = 0; i < self.tmpTags.count; i ++) {
        _LWHTMLTag* aTag = self.tmpTags[i];
        if (!self.configDict[aTag.tagName] || ![self.configDict[aTag.tagName] isKindOfClass:[LWHTMLTextConfig class]]) {
            continue;
        }
        LWHTMLTextConfig* chilredConfig = self.configDict[aTag.tagName];
        [attributedString setTextColor:chilredConfig.textColor range:aTag.range];
        [attributedString setTextBackgroundColor:chilredConfig.textBackgroundColor range:aTag.range];
        [attributedString setFont:chilredConfig.font range:aTag.range];
        [attributedString setLineSpacing:chilredConfig.linespacing range:aTag.range];
        [attributedString setCharacterSpacing:chilredConfig.characterSpacing range:aTag.range];
        [attributedString setTextAlignment:chilredConfig.textAlignment range:aTag.range];
        [attributedString setUnderlineStyle:chilredConfig.underlineStyle underlineColor:config.underlineColor range:aTag.range];
        [attributedString setLineBreakMode:chilredConfig.lineBreakMode range:aTag.range];
    }
    if (self.tmpLinks && self.tmpLinks.count) {
        for (_LWHTMLLink* aLink in self.tmpLinks) {
            [attributedString addLinkWithData:aLink.URL range:aLink.range linkColor:config.linkColor highLightColor:config.linkHighlightColor];
        }
    }
    CGRect frame = CGRectMake(self.edgeInsets.left,self.edgeInsets.top,SCREEN_WIDTH - self.edgeInsets.left - self.edgeInsets.right,CGFLOAT_MAX);
    if (attributedString.length) {
        LWTextStorage* textStorage = [LWTextStorage lw_textStrageWithText:attributedString frame:frame];
        textStorage.textDrawMode  = config.textDrawMode;
        textStorage.htmlLayoutEdgeInsets = self.edgeInsets;
        self.offsetY += (textStorage.height + config.paragraphSpacing);
        [self.tmpStorages addObject:textStorage];
    }
    self.tmpString = nil;
    self.tmpLinks = nil;
    self.tmpTags = nil;
}

- (void)parserDidEndDocument:(LWHTMLParser *)parser {
    self.xpath = nil;
    self.isTagEnd = YES;
    self.parentTag = nil;
    self.currentType = 0;
    self.currentLink = nil;
    self.tmpLinks = nil;
    self.configDict = nil;
    self.tmpString = nil;
}

#pragma mark - Private

- (LWElementType)_elementTypeWithElementName:(NSString *)elementName {
    if ([elementName isEqualToString:@"a"]) {
        return LWElementTypeLink;
    }
    else if ([elementName isEqualToString:@"img"]) {
        return LWHTMLElementTypeImage;
    }
    else {
        return LWHTMLElementTypeText;
    }
}

#pragma mark - Getter

- (NSMutableArray *)tmpStorages {
    if (_tmpStorages) {
        return _tmpStorages;
    }
    _tmpStorages = [[NSMutableArray alloc] init];
    return _tmpStorages;
}

@end

@implementation _LWHTMLLink

@end

@implementation _LWHTMLTag

@end
