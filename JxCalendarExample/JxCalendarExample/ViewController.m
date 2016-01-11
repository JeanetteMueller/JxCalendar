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

@interface ViewController () <JxCalendarDelegate>

@property (strong, nonatomic) TestCalendarDataSource *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
    [self openCalendar:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openCalendar:(id)sender{
    
    self.dataSource = [[TestCalendarDataSource alloc] init];
    
    
    NSLog(@"usable size %f x %f", self.view.frame.size.width, self.view.frame.size.height);
    
    
    JxCalendarOverview *overview = [[JxCalendarOverview alloc] initWithDataSource:_dataSource
                                                                         andStyle:JxCalendarStyleMonthGrid
                                                                         andSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-80)];
    
    overview.delegate = self;
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:overview];
    [nav.navigationBar setTranslucent:NO];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark <JxCalendarDelegate>

- (void)calendarDidSelectDate:(NSDate *)date{
    NSLog(@"calendarDidSelectDate %@", date);
}

- (void)calendarDidSelectEvent:(JxCalendarEvent *)event{
    NSLog(@"calendarDidSelectEvent %@", event);
}
@end
