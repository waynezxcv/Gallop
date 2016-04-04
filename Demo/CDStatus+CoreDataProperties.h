//
//  CDStatus+CoreDataProperties.h
//  LWAsyncDisplayViewDemo
//
//  Created by 刘微 on 16/4/4.
//  Copyright © 2016年 WayneInc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDStatus.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDStatus (CoreDataProperties)

@property (nullable, nonatomic, retain) NSURL* avatar;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSArray* imgs;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *statusID;
@property (nullable, nonatomic, retain) NSArray* commentList;

@end

NS_ASSUME_NONNULL_END
