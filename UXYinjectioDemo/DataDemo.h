//
//  DataDemo.h
//  UXYinjectioDemo
//
//  Created by Heaven on 15/1/25.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "UXYInjectio.h"

@protocol PeopleData <UXYinjectioProtocol>
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) float height2;
@property (nonatomic, assign) double height3;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSUInteger age2;
@property (nonatomic, assign) int age3;
@property (nonatomic, assign) unsigned int age4;
@property (nonatomic, assign) BOOL isAlive;
@property (nonatomic, assign) bool isAlive2;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *num;
@end

@interface People : NSObject <PeopleData>
@end

//
@protocol ManData <UXYinjectioProtocol>
@property (nonatomic, copy) NSString *job;
@property (nonatomic, strong) NSArray *nicknames;
@property (nonatomic, strong) NSDictionary *books;
@end

@interface Man : NSObject <ManData, PeopleData>
@end

//
@protocol AppConfigData <UXYinjectioProtocol>
@property (nonatomic, strong) NSString *version;
@end

@interface AppConfig : NSObject <AppConfigData>
@end