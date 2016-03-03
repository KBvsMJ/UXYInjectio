//
//  ViewController.m
//  UXYinjectioDemo
//
//  Created by Heaven on 15/1/25.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import "ViewController.h"
#import "DataDemo.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *demos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _demos = @[
               @{@"title": @"Build value", @"method": @"buildValue"},
               @{@"title": @"Print value", @"method": @"printValue"},
               @{@"title": @"Auto save", @"method": @"autoSave"},
               ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self buildValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dic = [self.demos objectAtIndex:indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    SEL sel = NSSelectorFromString([self.demos objectAtIndex:indexPath.row][@"method"]);

    if ([self respondsToSelector:sel])
    {
        [self performSelector:sel];
    }
}

- (void)buildValue
{
    People *people = [[People alloc] init];
    [people bindInjectioWithSuiteName:@"bill"];
    people.name     = @"name";
    people.age      = 10;
    people.age2     = 20;
    people.age3     = 30;
    people.age4     = 40;
    people.isAlive  = YES;
    people.isAlive2 = YES;
    people.height   = 180.1;
    people.height2  = 180.2;
    people.height3  = 180.3;
    people.num      = @9999;
    
    Man *man = [[Man alloc] init];
    [man bindInjectioWithSuiteName:@"bill"];
    man.job       = @"develop";
    man.nicknames = @[@"xiaoming", @"xiaolang"];
    man.books     = @{@"book1" : @"objective-c"};
    
    AppConfig *config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user1"];
    config.version = @"1.1";
    
    config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user2"];
    config.version = @"1.2";
    
}

- (void)printValue
{
    People *people = [[People alloc] init];
    [people bindInjectioWithSuiteName:@"bill"];
    NSLog(@"people\n");
    NSLog(@"%@\n", people.name);
    NSLog(@"%ld\n", (long)people.age);
    NSLog(@"%lu\n", (unsigned long)people.age2);
    NSLog(@"%d\n", people.age3);
    NSLog(@"%u\n", people.age4);
    NSLog(@"%d\n", people.isAlive);
    NSLog(@"%d\n", people.isAlive2);
    NSLog(@"%f\n", people.height);
    NSLog(@"%f\n", people.height2);
    NSLog(@"%f\n", people.height3);
    NSLog(@"%@\n", people.num);
    NSLog(@"\n");
    
    
    Man *man = [[Man alloc] init];
    [man bindInjectioWithSuiteName:@"bill"];
    NSLog(@"man\n");
    NSLog(@"%@\n", man.name);
    NSLog(@"%@\n", man.job);
    NSLog(@"%@\n", man.nicknames);
    NSLog(@"%@\n", man.books);
    NSLog(@"\n");
    
    AppConfig *config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user1"];
    NSLog(@"config\n");
    NSLog(@"%@\n", config.version);
    
    config = [[AppConfig alloc] init];
    [config bindInjectioWithSuiteName:@"user2"];
    NSLog(@"config\n");
    NSLog(@"%@\n", config.version);
    
}

- (void)autoSave
{
    NSLog(@"Wait 10s\n");
    for (int i = 0; i < 100; i++)
    {
        People *people = [[People alloc] init];
        [people bindInjectioWithSuiteName:[NSString stringWithFormat:@"autoSave_%04d", i]];
        people.name     = @"name";
        people.age      = i;
        people.age2     = 20;
        people.age3     = 30;
        people.age4     = 40;
        people.isAlive  = YES;
        people.isAlive2 = YES;
        people.height   = 180.1;
        people.height2  = 180.2;
        people.height3  = 180.3;
        people.num      = @9999;
    }
    NSLog(@"Now, you can Enter Background\n");
}
@end
