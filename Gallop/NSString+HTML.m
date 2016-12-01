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

#import "NSString+HTML.h"

#define IS_WHITESPACE(_c) (_c == ' '|| _c == '\t' || _c == 0xA || _c == 0xB || _c == 0xC || _c == 0xD || _c == 0x85)

@implementation NSString(HTML)

- (NSString *)stringByNormalizingWhitespace {
    NSInteger stringLength = [self length];
    unichar* _characters = calloc(stringLength, sizeof(unichar));
    [self getCharacters:_characters range:NSMakeRange(0, stringLength)];
    NSInteger outputLength = 0;
    BOOL inWhite = NO;
    for (NSInteger i = 0; i<stringLength; i++) {
        unichar oneChar = _characters[i];
        if (IS_WHITESPACE(oneChar)) {
            if (!inWhite) {
                _characters[outputLength] = 32;
                outputLength++;
                inWhite = YES;
            }
        } else {
            _characters[outputLength] = oneChar;
            outputLength++;
            inWhite = NO;
        }
    }
    NSString* retString = [NSString stringWithCharacters:_characters length:outputLength];
    free(_characters);
    return retString;
}


@end
