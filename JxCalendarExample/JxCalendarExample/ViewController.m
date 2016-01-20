//
//  ViewController.m
//  JxCalendarExample
//
//  Created by Jeanette Müller on 09.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "ViewController.h"
#import <JxCalendar/JxCalendar.h>
#import "TestCalendarDataSource.h"

#define DLog(fmt, ...)                               NSLog((@">>> %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LLog()                                       NSLog((@">>> %s [Line %d] "), __PRETTY_FUNCTION__, __LINE__)


@interface ViewController () <JxCalendarDelegate>

@property (strong, nonatomic) TestCalendarDataSource *dataSource;
@property (strong, nonatomic) UINavigationController *navRoot;

@property (nonatomic, readwrite) BOOL startOpened;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    if (!_startOpened) {
        _startOpened = YES;
        [self openCalendar:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openCalendar:(id)sender{
    
    self.dataSource = [[TestCalendarDataSource alloc] init];
    
    
    NSLog(@"usable size %f x %f", self.view.frame.size.width, self.view.frame.size.height);
    
    
    JxCalendarOverview *overview = [[JxCalendarOverview alloc] initWithDataSource:_dataSource
                                                                         andStyle:JxCalendarOverviewStyleMonthGrid
                                                                         andSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-80)
                                                                     andStartDate:[NSDate date]
                                                               andStartAppearance:JxCalendarAppearanceMonth];
    
    overview.delegate = self;
    
    
    self.navRoot = [[UINavigationController alloc] initWithRootViewController:overview];
    [self.navRoot.navigationBar setTranslucent:NO];
    
    [self presentViewController:self.navRoot animated:YES completion:nil];
    
//    self.navRoot.view.frame = CGRectMake(20, 20, self.view.frame.size.width-40, self.view.frame.size.height-40);
//    [self.view addSubview:self.navRoot.view];
}

#pragma mark <JxCalendarDelegate>

- (void)calendarDidSelectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance{
    DLog(@" %@", date);
}

- (void)calendarDidSelectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance{
    DLog(@" %@", event);
}

- (void)calendarWillTransitionFrom:(JxCalendarAppearance)fromAppearance to:(JxCalendarAppearance)toAppearance{
    DLog(@"from %d to %d", fromAppearance, toAppearance);
}
- (void)calendarDidTransitionTo:(JxCalendarAppearance)toAppearance{
    DLog(@"to %d", toAppearance);
}
@end
