# UXYInjectio
UXYInjectio can use Protocol to share data that data has been autosaved.

## How To Use
1. create a Protocol (inherit UXYinjectioProtocol), define the property in that Protocol
2. let the class support Protocol
3. call method sharedWithSuiteName to bind a suite name
4. this data is autosaved

```
@protocol AppConfigData <UXYinjectioProtocol>
@property (nonatomic, strong) NSString *version;
@end

@interface AppConfig : NSObject <AppConfigData>
@end
@implementation AppConfig
@end
```

```
{
	AppConfig *config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user1"];
    config.version = @"1.1";
 }
    
{
    AppConfig *config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user1"];
    NSLog(@"config\n");
    NSLog(@"%@\n", config.version);
}

```

The value parameter can be only property list objects: NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary. For NSArray and NSDictionary objects, their contents must be property list objects.

```
@protocol PeopleData <UXYinjectioProtocol>
@property (nonatomic, assign) float height2;
@property (nonatomic, assign) int age3;
@property (nonatomic ,assign) BOOL isAlive;
@property (nonatomic, copy) NSString *name;
@end

@protocol ManData <UXYinjectioProtocol>
@property (nonatomic, strong) NSArray *nicknames;
@property (nonatomic, strong) NSDictionary *books;
@end
```

You can use any instance with any Protocol. The same suite name is same data.

```
@interface People : NSObject <PeopleData>
@end
@implementation People
@end

@interface Man : NSObject <ManData, PeopleData>
@end
@implementation Man
@end

{
	People *people = [[People alloc] init];
    [people bindInjectioWithSuiteName:@"bill"];
    people.name = @"name";
    
    Man *man = [[Man alloc] init];
    [man bindInjectioWithSuiteName:@"bill"];
    NSLog(@"%@\n", man.name);
}
```

You can use different suite name to distinguish the data.

```
    AppConfig *config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user1"];
	config.version = @"1.1";
    
    config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user2"];
	config.version = @"1.2";

```
UXYInjectio is based on NSUserDefaults. Call method immediatelySaveInjectio to synchronize.When the app enters the background  it will be called automatically..
