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

#import <UIKit/UIKit.h>



//*** LWTextStorage和LWImageStorage的父类  ***//

@interface LWStorage : NSObject<NSCopying,NSCoding>


@property (nullable,nonatomic,copy) NSString* identifier;
@property (nonatomic,assign) NSInteger tag;
@property (nonatomic,assign) BOOL clipsToBounds;
@property (nonatomic,getter = isOpaque) BOOL opaque;
@property (nonatomic,getter = isHidden) BOOL hidden;
@property (nonatomic,assign) CGFloat alpha;
@property (nonatomic,assign) CGRect frame;
@property (nonatomic,assign) CGRect bounds;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;
@property (nonatomic,assign) CGPoint center;
@property (nonatomic,assign) CGPoint position;

@property (nonatomic,assign) CGFloat cornerRadius;
@property (nonatomic,strong,nullable) UIColor* cornerBackgroundColor;
@property (nonatomic,strong,nullable) UIColor* cornerBorderColor;
@property (nonatomic,assign) CGFloat cornerBorderWidth;

@property (nonatomic,assign,nullable) UIColor* shadowColor;
@property (nonatomic,assign) CGFloat shadowOpacity;
@property (nonatomic,assign) CGSize shadowOffset;
@property (nonatomic,assign) CGFloat shadowRadius;

@property (nonatomic,assign) CGFloat contentsScale;
@property (nonatomic,strong,nullable) UIColor* backgroundColor;
@property (nonatomic,assign) UIViewContentMode contentMode;

- (id)initWithIdentifier:(NSString *)identifier;

@end
