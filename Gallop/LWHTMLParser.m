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


#import "LWHTMLParser.h"
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


static void _startDocument(void* context);
static void _endDocument(void* context);
static void _startElement(void* context, const xmlChar* name,const xmlChar** atts);
static void _startElement_no_delegate(void* context, const xmlChar* name, const xmlChar** atts);
static void _endElement(void* context, const xmlChar* name);
static void _endElement_no_delegate(void* context, const xmlChar* chars);
static void _characters(void* context, const xmlChar* ch, int len);
static void _comment(void* context, const xmlChar* value);
static void _lwerror(void* context, const char* msg, ...);
static void _cdataBlock(void* context, const xmlChar* value, int len);
static void _processingInstruction (void* context, const xmlChar* target, const xmlChar* data);
static NSData* _dataWithHTMLXPathQuery(NSData* document, NSString* query,const char* encoding);
static NSString* _stringWithXPathQuery(xmlDocPtr doc, NSString* query);
static NSString* _rawStringForNode(xmlNodePtr currentNode);


@interface LWHTMLParser ()

@property (nonatomic,strong) NSData* rawData;
@property (nonatomic,assign) NSStringEncoding encoding;
@property (nonatomic,assign) htmlSAXHandler handler;
@property (nonatomic,strong) NSMutableString* accumulateBuffer;
@property (nonatomic,assign) BOOL isAborting;
@property (nonatomic,strong) NSError* parserError;

- (void)_resetAccumulateBufferAndReportCharacters;
- (void)_accumulateCharacters:(const xmlChar* )characters length:(int)length;

@end

@implementation LWHTMLParser {
    htmlParserCtxtPtr _parserContext;
}

#pragma mark - LifeCycle
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    if (!data) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.rawData = data;
        self.encoding = encoding;
        xmlSAX2InitHtmlDefaultSAXHandler(&_handler);
    }
    return self;
}

- (void)dealloc {
    if (_parserContext) {
        htmlFreeParserCtxt(_parserContext);
    }
}

#pragma mark -- Parsing

- (BOOL)startSearchWithXPathQuery:(NSString *)xpath {
    const char* enc;
    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(_encoding);
    if (cfenc != kCFStringEncodingInvalidId) {
        CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
        if (cfencstr) {
            NSString* NS_VALID_UNTIL_END_OF_SCOPE encstr = [NSString stringWithString:(__bridge NSString*)cfencstr];
            enc = [encstr UTF8String];
        }
    }
    NSData* data = _dataWithHTMLXPathQuery(self.rawData, xpath, enc);
    void* dataBytes = (char *)[data bytes];
    unsigned long dataSize = [data  length];
    xmlCharEncoding charEnc = XML_CHAR_ENCODING_NONE;
    if (!self.encoding) {
        charEnc = xmlDetectCharEncoding(dataBytes, (int)dataSize);
    } else {
        CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(self.encoding);
        if (cfenc != kCFStringEncodingInvalidId) {
            CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
            if (cfencstr) {
                NSString* NS_VALID_UNTIL_END_OF_SCOPE encstr = [NSString stringWithString:(__bridge NSString *)cfencstr];
                const char* enc = [encstr UTF8String];
                charEnc = xmlParseCharEncoding(enc);
            }
        }
    }
    _parserContext = htmlCreatePushParserCtxt(&_handler, (__bridge void*)self, dataBytes, (int)dataSize, NULL, charEnc);
    htmlCtxtUseOptions(_parserContext, HTML_PARSE_RECOVER | HTML_PARSE_NONET | HTML_PARSE_COMPACT | HTML_PARSE_NOBLANKS);
    int result = htmlParseDocument(_parserContext);
    return (result==0 && !self.isAborting);
}

- (void)stopParsing {
    if (_parserContext) {
        xmlStopParser(_parserContext);
        _parserContext = NULL;
    }
    self.isAborting = YES;
    _handler.startDocument = NULL;
    _handler.endDocument = NULL;
    _handler.startElement = NULL;
    _handler.endElement = NULL;
    _handler.characters = NULL;
    _handler.comment = NULL;
    _handler.error = NULL;
    _handler.processingInstruction = NULL;
    __strong typeof(self.delegate) delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(parser:parseErrorOccurred:)]) {
        [delegate parser:self parseErrorOccurred:self.parserError];
    }
}

- (void)_resetAccumulateBufferAndReportCharacters {
    if (!self.accumulateBuffer.length) {
        return;
    }
    [self.delegate parser:self foundCharacters:self.accumulateBuffer];
    self.accumulateBuffer = nil;
}

- (void)_accumulateCharacters:(const xmlChar *)characters length:(int)length {
    if (!self.accumulateBuffer) {
        self.accumulateBuffer = [[NSMutableString alloc] initWithBytes:characters
                                                                length:length
                                                              encoding:NSUTF8StringEncoding];
    } else {
        [self.accumulateBuffer appendString:[[NSString alloc] initWithBytesNoCopy:(void *)characters
                                                                           length:length
                                                                         encoding:NSUTF8StringEncoding
                                                                     freeWhenDone:NO]];
    }
}

#pragma mark - Getter & Setter

- (void)setDelegate:(id <LWHTMLParserDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
    if ([delegate respondsToSelector:@selector(parserDidStartDocument:)]) {
        _handler.startDocument = _startDocument;
    } else {
        _handler.startDocument = NULL;
    }
    if ([delegate respondsToSelector:@selector(parserDidEndDocument:)]) {
        _handler.endDocument = _endDocument;
    } else {
        _handler.endDocument = NULL;
    }

    if ([delegate respondsToSelector:@selector(parser:foundCharacters:)]) {
        _handler.characters = _characters;
    } else {
        _handler.characters = NULL;
    }

    if ([delegate respondsToSelector:@selector(parser:didStartElement:attributes:)]) {
        _handler.startElement = _startElement;
    } else {
        if (_handler.characters) {
            _handler.startElement = _startElement_no_delegate;
        } else {
            _handler.startElement = NULL;
        }
    }
    if ([delegate respondsToSelector:@selector(parser:didEndElement:)]) {
        _handler.endElement = _endElement;
    } else {
        if (_handler.characters) {
            _handler.endElement = _endElement_no_delegate;
        } else {
            _handler.endElement = NULL;
        }
    }

    if ([delegate respondsToSelector:@selector(parser:foundComment:)]) {
        _handler.comment = _comment;
    } else {
        _handler.comment = NULL;
    }

    if ([delegate respondsToSelector:@selector(parser:parseErrorOccurred:)]) {
        _handler.error = _lwerror;
    } else {
        _handler.error = NULL;
    }

    if ([delegate respondsToSelector:@selector(parser:foundCDATA:)]) {
        _handler.cdataBlock = _cdataBlock;
    } else {
        _handler.cdataBlock = NULL;
    }

    if ([delegate respondsToSelector:@selector(parser:foundProcessingInstructionWithTarget:data:)]) {
        _handler.processingInstruction = _processingInstruction;
    } else {
        _handler.processingInstruction = NULL;
    }
}

- (NSInteger)lineNumbe {
    return xmlSAX2GetLineNumber(_parserContext);
}

- (NSInteger)columnNumber {
    return xmlSAX2GetColumnNumber(_parserContext);
}

- (NSString *)systemID {
    char* systemID = (char *)xmlSAX2GetSystemId(_parserContext);
    if (!systemID) {
        return nil;
    }
    return [NSString stringWithUTF8String:systemID];
}

- (NSString *)publicID {
    char* publicID = (char* )xmlSAX2GetPublicId(_parserContext);
    if (!publicID) {
        return nil;
    }
    return [NSString stringWithUTF8String:publicID];
}

@end


static void _startDocument(void* context) {
    LWHTMLParser* myself = (__bridge LWHTMLParser* )context;
    [myself.delegate parserDidStartDocument:myself];
}

static void _endDocument(void* context) {
    LWHTMLParser* myself = (__bridge LWHTMLParser* )context;
    [myself.delegate parserDidEndDocument:myself];
}

static void _startElement(void* context, const xmlChar* name, const xmlChar** atts) {
    LWHTMLParser* myself = (__bridge LWHTMLParser* )context;
    [myself _resetAccumulateBufferAndReportCharacters];
    NSString* nameStr = [NSString stringWithUTF8String:(char *)name];
    NSMutableDictionary* attributes = nil;
    if (atts) {
        NSString* key = nil;
        NSString* value = nil;
        attributes = [[NSMutableDictionary alloc] init];
        int i = 0;
        while (1) {
            char* att = (char* )atts[i++];
            if (!key){
                if (!att){
                    break;
                }
                key = [NSString stringWithUTF8String:att];
            } else{
                if (att){
                    value = [NSString stringWithUTF8String:att];
                } else{
                    value = key;
                }
                [attributes setObject:value forKey:key];
                value = nil;
                key = nil;
            }
        }
    }
    [myself.delegate parser:myself didStartElement:nameStr attributes:attributes];
}

static void _startElement_no_delegate(void* context, const xmlChar* name, const xmlChar** atts) {
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    [myself _resetAccumulateBufferAndReportCharacters];
}

static void _endElement(void* context, const xmlChar* chars){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    [myself _resetAccumulateBufferAndReportCharacters];
    NSString* nameStr = [NSString stringWithUTF8String:(char* )chars];
    [myself.delegate parser:myself didEndElement:nameStr];
}

static void _endElement_no_delegate(void* context, const xmlChar* chars){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    [myself _resetAccumulateBufferAndReportCharacters];
}

static void _characters(void* context, const xmlChar* chars, int len){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    [myself _accumulateCharacters:chars length:len];
}

static void _comment(void* context, const xmlChar* chars){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    NSString* string = [NSString stringWithCString:(const char *)chars encoding:myself.encoding];
    [myself.delegate parser:myself foundComment:string];
}

static void _lwerror(void* context, const char* msg, ...){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    char string[256];
    va_list arg_ptr;
    va_start(arg_ptr, msg);
    vsnprintf(string, 256, msg, arg_ptr);
    va_end(arg_ptr);
    NSString* errorMsg = [NSString stringWithUTF8String:string];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
    myself.parserError = [NSError errorWithDomain:@"LWHTMLParser" code:1 userInfo:userInfo];
    [myself.delegate parser:myself parseErrorOccurred:myself.parserError];
}

static void _cdataBlock(void* context, const xmlChar* value, int len){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    NSData* data = [NSData dataWithBytes:(const void *)value length:len];
    [myself.delegate parser:myself foundCDATA:data];
}

static void _processingInstruction (void* context, const xmlChar* target, const xmlChar* data){
    LWHTMLParser* myself = (__bridge LWHTMLParser *)context;
    NSStringEncoding encoding = myself.encoding;
    NSString* targetStr = [NSString stringWithCString:(const char *)target encoding:encoding];
    NSString* dataStr = [NSString stringWithCString:(const char *)data encoding:encoding];
    [myself.delegate parser:myself foundProcessingInstructionWithTarget:targetStr data:dataStr];
}

static NSData* _dataWithHTMLXPathQuery(NSData* document, NSString* query,const char* encoding) {
    xmlDocPtr doc;
    doc = htmlReadMemory([document bytes], (int)[document length], "", encoding, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    if (doc == NULL) {
        return nil;
    }
    NSString* queryedString = _stringWithXPathQuery(doc, query);
    xmlFreeDoc(doc);
    NSData* data;
    data = [queryedString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

static NSString* _stringWithXPathQuery(xmlDocPtr doc, NSString* query) {
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    if (query == nil || ![query isKindOfClass:[NSString class]]) {
        return nil;
    }
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL) {
        return nil;
    }
    xpathObj = xmlXPathEvalExpression((xmlChar* )[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if (!nodes) {
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    NSMutableString* results = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < nodes->nodeNr; i++) {
        NSString* nodeRawString = _rawStringForNode(nodes->nodeTab[i]);
        if (nodeRawString) {
            [results appendString:nodeRawString];
        }
    }
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    return results;
}

static NSString* _rawStringForNode(xmlNodePtr currentNode) {
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);
    NSString* rawContent = [NSString stringWithCString:(const char*)buffer->content encoding:NSUTF8StringEncoding];
    xmlBufferFree(buffer);
    return rawContent;
}

