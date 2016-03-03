//
//  UXYInjectio.h
//  UXYinjectioDemo
//
//  Created by Heaven on 15/1/25.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UXYinjectioProtocol;

@interface NSObject (UXYInjectio)

- (void)bindInjectioWithSuiteName:(NSString *)name;
- (BOOL)immediatelySaveInjectio;

@end

/*
 实现原理
 1 UXYInjectioHelper hook对象的快速消息转发方法(forwardingTargetForSelector)
 2 在快速消息转发的时候吧方法传递给SuiteName对应的UXYInjectio对象处理
 3 在UXYInjectio对象的标准消息转发方法里用NSUserDefaults对象处理set get方法
*/