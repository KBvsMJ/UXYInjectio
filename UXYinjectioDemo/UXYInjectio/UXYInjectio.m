//
//  UXYInjectio.m
//  UXYinjectioDemo
//
//  Created by Heaven on 15/1/25.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import "UXYInjectio.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wundeclared-selector"

#define UXYInjectio_associatedInjectioKey "UXYInjectio_associatedInjectioKey"
#define UXYInjectio_associatedInjectioProtocol "UXYInjectio_associatedInjectioProtocol"
#define UXYInjectio_associatedCurrentObject @"UXYInjectio_associatedCurrentObject"

#pragma mark- NSObject
@interface NSObject (UXYInjectioInner)
@property (nonatomic, copy) NSString *uxySuiteName;             //
@property (nonatomic, copy, readonly) NSString *uxyInjectioProtocol;      //  Protocol_Protocol
@end

#pragma mark- UXYInjectioHelper
@interface UXYInjectioHelper : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSMutableDictionary *injectioDictionary;

@property (nonatomic, strong) NSMutableDictionary *propertyTypeInfo; // {protocol : {property : propertyType}}
@property (nonatomic, strong) NSMutableSet *swizzledClass;

@property (nonatomic, strong) NSDictionary *setterSelectorMap;
@property (nonatomic, strong) NSDictionary *getterSelectorMap;
@property (nonatomic, strong) NSDictionary *propertyTypeMap;

- (void)setupInjectioWithInstance:(NSObject *)instance withSuiteName:(NSString *)name;

- (void)setCurrentObject:(NSObject *)anObject;
@end

#pragma mark- UXYInjectio
@interface UXYInjectio : NSObject

@property (nonatomic, copy) NSString *uxyInjectioName;
@property (nonatomic, strong) id uxyInnerData;
@property (nonatomic, assign) BOOL uxyOptimizeStorage;

- (id)initWithSuiteName:(NSString *)name;
- (BOOL)uxySynchronize;
@end

#pragma mark- NSObject

id uxyForwardingTargetForSelectorMethodIMP(id self, SEL _cmd, SEL aSelector)
{
    id injectio = UXYInjectioHelper.sharedInstance.injectioDictionary[((NSObject *)self).uxySuiteName];
    
    return injectio ? ({ UXYInjectioHelper.sharedInstance.currentObject = self; injectio; }) :
    ({
        NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(uxyForwardingTargetForSelectorMethodIMP:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target        = self;
        invocation.selector      = @selector(uxyForwardingTargetForSelectorMethodIMP:);
        [invocation setArgument:&aSelector atIndex:2];
        [invocation invoke];
        id returnValue;
        [invocation getReturnValue:&returnValue];
        returnValue;
    });
}

@implementation NSObject (UXYInjectioInner)

@dynamic uxySuiteName;
@dynamic uxyInjectioProtocol;

- (void)bindInjectioWithSuiteName:(NSString *)name
{
    self.uxySuiteName = name;
    [UXYInjectioHelper.sharedInstance setupInjectioWithInstance:self withSuiteName:name];
}

-(BOOL)immediatelySaveInjectio
{
    return ((NSUserDefaults *)(UXYInjectioHelper.sharedInstance.injectioDictionary[self.uxySuiteName])).synchronize;
}
- (NSString *)uxySuiteName
{
    return objc_getAssociatedObject(self, UXYInjectio_associatedInjectioKey);
}
- (void)setUxySuiteName:(NSString *)uxySuiteName
{
    objc_setAssociatedObject(self, UXYInjectio_associatedInjectioKey, uxySuiteName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)uxyInjectioProtocol
{
    return objc_getAssociatedObject(self, UXYInjectio_associatedInjectioProtocol) ?:
    ({ NSMutableString *mString = @"".mutableCopy;
        uint protocolCount = 0;
        __unsafe_unretained Protocol **protocolArray = class_copyProtocolList([self class], &protocolCount);
        for (int i = 0; i < protocolCount; i++)
        {
            protocol_conformsToProtocol(protocolArray[i], @protocol(UXYinjectioProtocol)) ? [mString appendFormat:@"_%@", [NSString stringWithCString:protocol_getName(protocolArray[i]) encoding:4]] : nil;
        }
        NSString *key = mString.copy;
        objc_setAssociatedObject(self, UXYInjectio_associatedInjectioProtocol, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
        key;
    });
}

@end

#pragma mark- UXYInjectioHelper
@implementation UXYInjectioHelper
#pragma mark - def

#pragma mark - override
- (instancetype)init
{
    self = [super init];
    if (self) {
        _injectioDictionary = @{}.mutableCopy;
        _propertyTypeInfo   = @{}.mutableCopy;
        _swizzledClass      = NSMutableSet.set;
        [self registerNotification];
    }
    return self;
}
#pragma mark - api
+ (instancetype)sharedInstance;
{
    static dispatch_once_t once;
    static id object;
    dispatch_once(&once, ^{
        object = [[self alloc] init];
    });
    return object;
}

- (void)setupInjectioWithInstance:(NSObject *)instance withSuiteName:(NSString *)name
{
    [self buildProtocolPropertyTypeNameInfoWithInstance:instance];
    [self injectioForKey:name withClass:[self class]];
    [self hookForwardingSelectorWithClass:[instance class]];
}

- (id)injectioForKey:(NSString *)key withClass:(Class)clazz
{
    NSString *injectioKey = key ?: @"";
    return _injectioDictionary[injectioKey] ?: ({ _injectioDictionary[injectioKey] = [[UXYInjectio alloc] initWithSuiteName:injectioKey]; _injectioDictionary[injectioKey]; });
}
- (void)setCurrentObject:(id)anObject
{
    NSThread.currentThread.threadDictionary[UXYInjectio_associatedCurrentObject] = anObject;
}

- (id)currentObject
{
    return NSThread.currentThread.threadDictionary[UXYInjectio_associatedCurrentObject];
}
#pragma mark - private
- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUserDefaults) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUserDefaults) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)saveUserDefaults
{
    UIApplication *application = UIApplication.sharedApplication;
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *key in _injectioDictionary)
        {
            UXYInjectio *injectio = _injectioDictionary[key];
            [injectio uxySynchronize];
        }
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
}

- (void)swizzleInstanceMethodWithClass:(Class)clazz originalSel:(SEL)original replacementSel:(SEL)replacement
{
    Method a = class_getInstanceMethod(clazz, original);
    Method b = class_getInstanceMethod(clazz, replacement);
    
    if (class_addMethod(clazz, original, method_getImplementation(b), method_getTypeEncoding(b)))
    {
        class_replaceMethod(clazz, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    }
    else
    {
        method_exchangeImplementations(a, b);
    }
}

- (void)hookForwardingSelectorWithClass:(Class)clazz
{
    if ([clazz instancesRespondToSelector:@selector(uxyForwardingTargetForSelectorMethodIMP:)])
        return;
    
    Method a = class_getInstanceMethod(clazz, @selector(forwardingTargetForSelector:));
    
    class_addMethod(clazz, @selector(uxyForwardingTargetForSelectorMethodIMP:), (IMP)uxyForwardingTargetForSelectorMethodIMP, "@@::");
    class_addMethod(clazz, @selector(forwardingTargetForSelector:), (IMP)uxyForwardingTargetForSelectorMethodIMP, "@@::");
    class_replaceMethod(clazz, @selector(uxyForwardingTargetForSelectorMethodIMP:), method_getImplementation(a), method_getTypeEncoding(a));
}

- (void)buildProtocolPropertyTypeNameInfoWithInstance:(NSObject *)instance
{
    if (_propertyTypeInfo[instance.uxyInjectioProtocol])
        return;
    
    NSMutableDictionary *mdic = [@{} mutableCopy];
    uint protocolCount        = 0;
    __unsafe_unretained Protocol **protocolArray = class_copyProtocolList([instance class], &protocolCount);
    for (int i = 0; i < protocolCount; i++)
    {
        if (!protocol_conformsToProtocol(protocolArray[i], @protocol(UXYinjectioProtocol)))
            continue;
        
        uint propertyCount = 0;
        objc_property_t *properties = protocol_copyPropertyList(protocolArray[i], &propertyCount);
        for (int j = 0; j < propertyCount; j++)
        {
            objc_property_t property   = properties[j];
            NSString *propertyName     = [NSString stringWithCString:property_getName(property) encoding:4].lowercaseString;
            NSString *propertyTypeName = [self typeNameWithProperty:property];
            if (propertyTypeName.length == 0)
                continue;
            
            mdic[propertyName] = propertyTypeName;
        }
        free(properties);
    }
    
    _propertyTypeInfo[instance.uxyInjectioProtocol] = mdic.copy;
}

- (NSString *)typeNameWithProperty:(objc_property_t)property
{
    NSString *typeName = nil;
    NSString *propertyType = [[NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] substringFromIndex:1];

    if ([propertyType hasPrefix:@"@"])
    {
        NSRange range = [propertyType rangeOfString:@","];
        range    = (range.length == 0) ? range : NSMakeRange(2, range.location - 3);
        typeName = (range.location + range.length <= propertyType.length) ? [propertyType substringWithRange:range] : nil;
        typeName = (![typeName hasSuffix:@">"]) ? typeName : [typeName substringToIndex:[typeName rangeOfString:@"<"].location];
        typeName = self.propertyTypeMap[typeName];
    }
    else
    {
        typeName = self.propertyTypeMap[[propertyType substringToIndex:1]];
    }
    
    return typeName;
}


- (NSDictionary *)setterSelectorMap
{
    return _setterSelectorMap ?: ({ _setterSelectorMap = @{
                                                            @"object": @"setObject:forKey:",
                                                            @"data": @"setObject:forKey:",
                                                            @"array": @"setObject:forKey:",
                                                            @"dictionary": @"setObject:forKey:",
                                                            @"integer": @"setInteger:forKey:",
                                                            @"bool": @"setBool:forKey:",
                                                            @"float": @"setFloat:forKey:",
                                                            @"double": @"setDouble:forKey:",
                                                            }; _setterSelectorMap; });
}
- (NSDictionary *)getterSelectorMap
{
    return _getterSelectorMap ?: ({ _getterSelectorMap = @{
                                                           @"object": @"objectForKey:",
                                                           @"data": @"dataForKey:",
                                                           @"array" : @"arrayForKey:",
                                                           @"dictionary" : @"dictionaryForKey:",
                                                           @"integer": @"integerForKey:",
                                                           @"bool" :@"boolForKey:",
                                                           @"float": @"floatForKey:",
                                                           @"double": @"doubleForKey:",
                                                           }; _getterSelectorMap; });
}

- (NSDictionary *)propertyTypeMap
{
    return _propertyTypeMap ?: ({_propertyTypeMap = @{
                                                      @"NSString" : @"object",
                                                      @"NSNumber" : @"object",
                                                      @"NSData" : @"data",
                                                      @"NSArray" : @"array",
                                                      @"NSDictionary" : @"dictionary",
                                                      @"q" : @"integer",
                                                      @"Q" : @"integer",
                                                      @"i" : @"integer",
                                                      @"I" : @"integer",
                                                      @"B"  : @"bool",
                                                      @"c"  : @"bool",      // BOOL,char type: c
                                                      @"d" : @"double",
                                                      @"f" : @"float",
                                                      }; _propertyTypeMap;});
}
@end

#pragma mark- UXYInjectio
@implementation UXYInjectio
#pragma mark - def

#pragma mark - override
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _uxyInnerData = NSUserDefaults.standardUserDefaults;
    }
    return self;
}

// 标准消息转发
// 返回方法签名,如果非空,走forwardInvocation:开始转发消息
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *propertyName;
    NSString *typeKey = ((NSObject *)UXYInjectioHelper.sharedInstance.currentObject).uxyInjectioProtocol;
    if ( ({ propertyName = [self setterNameFromSelector:aSelector]; propertyName; }) )
    {
        NSString *className   = UXYInjectioHelper.sharedInstance.propertyTypeInfo[typeKey][propertyName];
        NSString *replaceName = UXYInjectioHelper.sharedInstance.setterSelectorMap[className];
        SEL replaceSelector   = NSSelectorFromString(replaceName);
        
        return [_uxyInnerData methodSignatureForSelector:replaceSelector];
    }
    
    if ( ({ propertyName = [self getterNameFromSelector:aSelector]; propertyName; }) )
    {
        NSString *className   = UXYInjectioHelper.sharedInstance.propertyTypeInfo[typeKey][propertyName];
        NSString *replaceName = UXYInjectioHelper.sharedInstance.getterSelectorMap[className];
        SEL replaceSelector   = NSSelectorFromString(replaceName);
        
        return [_uxyInnerData methodSignatureForSelector:replaceSelector];
    }
    
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *propertyName = [self setterNameFromSelector:anInvocation.selector];
    NSString *typeKey      = ((NSObject *)UXYInjectioHelper.sharedInstance.currentObject).uxyInjectioProtocol;
    if (propertyName)
    {
        NSString *className   = UXYInjectioHelper.sharedInstance.propertyTypeInfo[typeKey][propertyName];
        NSString *replaceName = UXYInjectioHelper.sharedInstance.setterSelectorMap[className];
        anInvocation.selector = NSSelectorFromString(replaceName);
        anInvocation.target   = UXYInjectioHelper.sharedInstance.currentObject;
        [anInvocation setArgument:&propertyName atIndex:3];  // self, _cmd, obj, key
        [anInvocation invokeWithTarget:_uxyInnerData];
        
        if (_uxyOptimizeStorage)
            return;
        
        [_uxyInnerData synchronize];
        
        return;
    }
    
    propertyName = [self getterNameFromSelector:anInvocation.selector];
    if (propertyName)
    {
        NSString *className   = UXYInjectioHelper.sharedInstance.propertyTypeInfo[typeKey][propertyName];
        NSString *replaceName = UXYInjectioHelper.sharedInstance.getterSelectorMap[className];
        anInvocation.selector = NSSelectorFromString(replaceName);
        anInvocation.target   = UXYInjectioHelper.sharedInstance.currentObject;
        [anInvocation setArgument:&propertyName atIndex:2]; // self, _cmd, key
        [anInvocation invokeWithTarget:_uxyInnerData];
        
        if (!_uxyOptimizeStorage)
        {
            [_uxyInnerData synchronize];
        }
        
        return;
    }
}

#pragma mark - api
- (id)initWithSuiteName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _uxyInjectioName = name;
        _uxyInnerData    = [[NSUserDefaults alloc] initWithSuiteName:name];
    }
    return self;
}
- (BOOL)uxySynchronize
{
    return  [_uxyInnerData synchronize];
}
#pragma mark - private
- (NSString *)getterNameFromSelector:(SEL)aSelector
{
    NSString *name = NSStringFromSelector(aSelector);
    
    return [name rangeOfString:@":"].length == 0 ? name.lowercaseString : nil;
}

- (NSString *)setterNameFromSelector:(SEL)aSelector
{
    NSString *name = NSStringFromSelector(aSelector);
    NSArray *array = [name componentsSeparatedByString:@":"];
    
    return ([name hasPrefix:@"set"] && array.count == 2) ? [name substringWithRange:NSMakeRange(3, name.length - 4)].lowercaseString : nil;
}

@end


#pragma clang diagnostic pop

