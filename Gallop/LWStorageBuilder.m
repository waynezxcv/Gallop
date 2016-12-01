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
#import "NSString+HTML.h"
#import "GallopDefine.h"


static inline void _setAttribute(__unsafe_unretained NSMutableAttributedString* attributedString,
                                 __unsafe_unretained LWHTMLTextConfig* config,
                                 NSRange range);


@interface LWStorageBuilder ()<LWHTMLParserDelegate>

@property (nonatomic,strong) LWHTMLParser* parser;
@property (nonatomic,strong) LWHTMLNode* tagElement;
@property (nonatomic,strong) LWHTMLNode* currentNode;
@property (nonatomic,copy) NSString* xpathTag;
@property (nonatomic,strong) NSMutableString* contentString;
@property (nonatomic,strong) NSMutableArray* imageCallbacksArray;
@property (nonatomic,strong) NSMutableArray* tmpStorages;
@property (nonatomic,strong) NSMutableString* tmpString;
@property (nonatomic,assign) UIEdgeInsets edgeInsets;
@property (nonatomic,strong) NSMutableDictionary* configDict;
@property (nonatomic,copy) NSString* xpath;
@property (nonatomic,strong) LWHTMLNode* tree;

@end


@implementation LWStorageBuilder

#pragma mark - Initial

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    if (!data) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.parser = [[LWHTMLParser alloc] initWithData:data encoding:encoding];
        self.parser.delegate = self;
    }
    return self;
}

#pragma mark - CreateLWStorage

- (void)createLWStorageWithXPath:(NSString *)xpath
             paragraphEdgeInsets:(UIEdgeInsets)edgeInsets
                configDictionary:(NSDictionary *)dict {
    NSArray* allKeys = [dict allKeys];
    for (NSString* key in allKeys) {
        self.configDict[key] = dict[key];
    }
    self.xpath = [xpath copy];
    self.edgeInsets = edgeInsets;
    self.imageCallbacksArray = [[NSMutableArray alloc] init];
    [self.parser startSearchWithXPathQuery:xpath];
}

- (void)createLWStorageWithXPath:(NSString *)xpath {
    self.xpath = [xpath copy];
    [self.parser startSearchWithXPathQuery:xpath];
}

#pragma mark - ParserDelegate

- (void)parserDidStartDocument:(LWHTMLParser *)parser {
    self.contentString = [[NSMutableString alloc] init];
    self.tmpStorages = [[NSMutableArray alloc] init];
    self.tagElement = nil;
}

- (void)parser:(LWHTMLParser *)parser didStartElement:(NSString *)elementName
    attributes:(NSDictionary *)attributeDict {
    
    LWHTMLNode* node = [[LWHTMLNode alloc] initWithElementName:elementName
                                                 attributeDict:attributeDict];
    if (self.currentNode) {
        [self.currentNode.children addObject:node];
        node.parent = self.currentNode;
    }
    
    self.currentNode = node;
    if ([elementName isEqualToString:self.xpathTag]) {
        self.tagElement = self.currentNode;
        self.tmpString = [[NSMutableString alloc] init];
    }
}

- (void)parser:(LWHTMLParser *)parser foundCharacters:(NSString *)string {
    string = [string stringByNormalizingWhitespace];
    if (self.tmpString && self.tagElement != self.currentNode) {
        NSRange range = NSMakeRange(self.tmpString.length, string.length);
        self.currentNode.range = range;
    }
    [self.tmpString appendString:string];
    [self.contentString appendString:string];
    self.currentNode.contentString = string;
    self.tagElement.contentString = [self.tmpString copy];
}

- (void)parser:(LWHTMLParser *)parser didEndElement:(NSString *)elementName {
    if (self.tagElement == self.currentNode) {
        self.tagElement.isTag = YES;
        self.tagElement.range = NSMakeRange(0, self.tagElement.contentString.length);
        self.tmpString = nil;
        self.tagElement = nil;
    }
    if (self.currentNode.parent) {
        self.currentNode = self.currentNode.parent;
    }
}

- (void)parserDidEndDocument:(LWHTMLParser *)parser {
    self.tree = self.currentNode;
    [self _preorderTraversing:self.currentNode];
    self.currentNode = nil;
    self.xpath = nil;
    self.configDict = nil;
}

#pragma mark - Building

- (void)_preorderTraversing:(LWHTMLNode *)node {
    LWStorage* storage = [self _nodeToStorage:node];
    if (storage) {
        [self.tmpStorages addObject:storage];
    }
    if (!node.children || !node.children.count) {
        return;
    }
    for (LWHTMLNode* aNode in node.children) {
        [self _preorderTraversing:aNode];
    }
}

- (LWStorage *)_nodeToStorage:(LWHTMLNode *)node {
    if ([node.elementName isEqualToString:@"img"]) {
        if (node.attributeDict[@"src"]) {
            LWHTMLImageConfig* imageConfig = [LWHTMLImageConfig defaultsConfig];
            if (self.configDict[@"img"] &&
                [self.configDict[@"img"] isKindOfClass:[LWHTMLImageConfig class]]) {
                imageConfig = self.configDict[@"img"];
            }
            LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
            imageStorage.extraDisplayIdentifier = imageConfig.extraDisplayIdentifier;
            imageStorage.contents = [NSURL URLWithString:[NSString stringWithFormat:@"%@",
                                                          (NSString *)node.attributeDict[@"src"]]];
            
            UIEdgeInsets edgeInsets = self.edgeInsets;
            
            if (!UIEdgeInsetsEqualToEdgeInsets(imageConfig.edgeInsets, UIEdgeInsetsZero)) {
                edgeInsets = imageConfig.edgeInsets;
            }
            
            CGFloat width =
            (imageConfig.size.width >= SCREEN_WIDTH - edgeInsets.left - edgeInsets.right) ?
            SCREEN_WIDTH - edgeInsets.left - edgeInsets.right
            : imageConfig.size.width;
            
            imageStorage.frame = CGRectMake(edgeInsets.left,
                                            edgeInsets.top,
                                            width,
                                            imageConfig.size.height);
            
            imageStorage.clipsToBounds = YES;
            imageStorage.placeholder = imageConfig.placeholder;
            imageStorage.htmlLayoutEdgeInsets = edgeInsets;
            imageStorage.contentMode = imageConfig.contentMode;
            
            if (imageConfig.autolayoutHeight) {
                imageStorage.needResize = YES;
            }
            
            imageStorage.userInteractionEnabled = imageConfig.userInteractionEnabled;
            
            if (imageConfig.needAddToImageCallbacks &&
                ![self.imageCallbacksArray containsObject:imageStorage]) {
                [self.imageCallbacksArray addObject:imageStorage];
            }
            return imageStorage;
        }
        return nil;
    }
    else if ([node.elementName isEqualToString:@"object"]) {
        //todo:
        return nil;
    }
    else {
        if (!node.isTag) {
            return nil;
        }
        LWHTMLTextConfig* config = [LWHTMLTextConfig defaultsTextConfig];
        if (self.configDict[node.elementName] &&
            [self.configDict[node.elementName] isKindOfClass:[LWHTMLTextConfig class]]) {
            config = self.configDict[node.elementName];
        }
        if (!node.contentString) {
            return nil;
        }
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]
                                                       initWithString:node.contentString];
        NSRange range = node.range;
        _setAttribute(attributedString, config,range);
        for (LWHTMLNode* child in node.children) {
            if ([child.elementName isEqualToString:@"a"] && child.attributeDict[@"href"]) {
                [attributedString addLinkWithData:child.attributeDict[@"href"]
                                            range:child.range
                                        linkColor:config.linkColor
                                   highLightColor:config.linkHighlightColor];
            } else {
                if (self.configDict[child.elementName] &&
                    [self.configDict[child.elementName] isKindOfClass:[LWHTMLTextConfig class]]) {
                    LWHTMLTextConfig* chidConfig = [self.configDict objectForKey:child.elementName];
                    _setAttribute(attributedString, chidConfig,child.range);
                }
            }
        }
        UIEdgeInsets edgeInsets = self.edgeInsets;
        if (!UIEdgeInsetsEqualToEdgeInsets(config.edgeInsets, UIEdgeInsetsZero)) {
            edgeInsets = config.edgeInsets;
        }
        
        CGRect frame = CGRectMake(edgeInsets.left,
                                  edgeInsets.top,
                                  SCREEN_WIDTH - edgeInsets.left - edgeInsets.right,
                                  CGFLOAT_MAX);
        LWTextStorage* textStorage = [LWTextStorage lw_textStorageWithText:attributedString
                                                                    frame:frame];
        textStorage.textDrawMode  = config.textDrawMode;
        textStorage.htmlLayoutEdgeInsets = edgeInsets;
        textStorage.extraDisplayIdentifier = config.extraDisplayIdentifier;
        return textStorage;
    }
}


#pragma mark - Getter

- (NSMutableDictionary *)configDict {
    if (_configDict) {
        return _configDict;
    }
    _configDict =
    [[NSMutableDictionary alloc]
     initWithDictionary:@{@"h1":[LWHTMLTextConfig defaultsH1TextConfig],
                          @"h2":[LWHTMLTextConfig defaultsH2TextConfig],
                          @"h3":[LWHTMLTextConfig defaultsH3TextConfig],
                          @"h4":[LWHTMLTextConfig defaultsH4TextConfig],
                          @"h5":[LWHTMLTextConfig defaultsH5TextConfig],
                          @"h6":[LWHTMLTextConfig defaultsH6TextConfig],
                          @"p":[LWHTMLTextConfig defaultsParagraphTextConfig],
                          @"q":[LWHTMLTextConfig defaultsQuoteTextConfig],
                          @"blockquote":[LWHTMLTextConfig defaultsQuoteTextConfig]}];
    return _configDict;
}

- (NSString *)xpathTag {
    NSString* xpathTag = @"";
    if (self.xpath) {
        NSArray* mached = [self.xpath componentsSeparatedByString:@"/"];
        NSString* last = [mached lastObject];
        if (!last) {
            return xpathTag;
        }
        xpathTag = last;
        if ([last containsString:@"["]) {
            NSRange r = [last rangeOfString:@"["];
            xpathTag = [last substringToIndex:r.location];
        }
    }
    return xpathTag;
}

- (NSString *)contents {
    return [self.contentString copy];
}

- (NSArray<LWStorage *>*)storages {
    return [self.tmpStorages copy];
}

- (LWStorage *)firstStorage {
    return self.storages.firstObject;
}

- (LWStorage *)lastStorage {
    return self.storages.lastObject;
}

- (NSArray<LWImageStorage *>*)imageCallbacks {
    return [self.imageCallbacksArray copy];
}

- (LWHTMLNode *)tree {
    return self.tree;
}

@end



static inline void _setAttribute(__unsafe_unretained NSMutableAttributedString* attributedString,
                                 __unsafe_unretained LWHTMLTextConfig* config,
                                 NSRange range) {
    [attributedString setTextColor:config.textColor range:range];
    [attributedString setTextBackgroundColor:config.textBackgroundColor range:range];
    [attributedString setFont:config.font range:range];
    [attributedString setLineSpacing:config.linespacing range:range];
    [attributedString setCharacterSpacing:config.characterSpacing range:range];
    [attributedString setTextAlignment:config.textAlignment range:range];
    [attributedString setUnderlineStyle:config.underlineStyle underlineColor:config.underlineColor range:range];
    [attributedString setLineBreakMode:config.lineBreakMode range:range];
}
