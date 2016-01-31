//
//  UIImageView+LWWebImage.h
//  LWWebImage
//
//  Created by 刘微 on 16/1/4.
//  Copyright © 2016年 Warm+. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWWebImageManager.h"



@interface UIImageView (LWWebImageManager)


@property (nonatomic,strong) NSOperation* loadOperation;
@property (nonatomic,strong) NSString* imageURL;

- (void)lw_setImageWithURL:(NSURL *)URL;


@end
