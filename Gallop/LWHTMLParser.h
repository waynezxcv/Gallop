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

#import <Foundation/Foundation.h>



/**
 *  这个类是对libxml的封装，用于解析HTML
 */

@class LWHTMLParser;


@protocol LWHTMLParserDelegate<NSObject>

@optional

- (void)parserDidStartDocument:(LWHTMLParser *)parser;
- (void)parserDidEndDocument:(LWHTMLParser *)parser;
- (void)parser:(LWHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict;
- (void)parser:(LWHTMLParser *)parser didEndElement:(NSString *)elementName;
- (void)parser:(LWHTMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(LWHTMLParser *)parser foundComment:(NSString *)comment;
- (void)parser:(LWHTMLParser *)parser foundCDATA:(NSData *)CDATABlock;
- (void)parser:(LWHTMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;
- (void)parser:(LWHTMLParser *)parser parseErrorOccurred:(NSError *)parseError;

@end


@interface LWHTMLParser : NSObject

@property (nonatomic,weak) id <LWHTMLParserDelegate> delegate;
@property (nonatomic,readonly) NSInteger columnNumber;
@property (nonatomic,readonly) NSInteger lineNumber;
@property (nonatomic,readonly) NSString* publicID;
@property (nonatomic,readonly) NSString* systemID;
@property (nonatomic,strong,readonly) NSError* parserError;


- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (BOOL)startSearchWithXPathQuery:(NSString *)xpath;
- (void)stopParsing;

@end
