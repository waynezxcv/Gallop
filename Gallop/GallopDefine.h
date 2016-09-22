//
//  GallopDefine.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/7/26.
//  Copyright © 2016年 WayneInc. All rights reserved.
//

#ifndef GallopDefine_h
#define GallopDefine_h

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif  

#ifndef SCREEN_BOUNDS
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#endif

#ifndef RGB
#define RGB(A,B,C,D) [UIColor colorWithRed:A/255.0f green:B/255.0f blue:C/255.0f alpha:D]
#endif


#endif /* GallopDefine_h */
