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
@property (strong, nonatomic) JxCalendarOverview *overview;

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
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openCalendar:(id)sender{
    
    self.dataSource = [[TestCalendarDataSource alloc] init];
    
    
    //NSLog(@"usable size %f x %f", self.view.frame.size.width, self.view.frame.size.height);
    
    
    _overview = [[JxCalendarOverview alloc] initWithDataSource:_dataSource
                                                      andStyle:JxCalendarOverviewStyleMonthGrid
                                                       andSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-80)
                                                  andStartDate:[NSDate date]
                                            andStartAppearance:JxCalendarAppearanceMonth
                                             andSelectionStyle:JxCalendarSelectionStyleDefault];
    
    _overview.delegate = self;
    _overview.renderWeekDayLabels = YES;
    _overview.lengthOfDayInHours = 8;
    
    
    self.navRoot = [[UINavigationController alloc] initWithRootViewController:_overview];
    [self.navRoot.navigationBar setTranslucent:NO];
    
    [self presentViewController:self.navRoot animated:YES completion:nil];
    
//    self.navRoot.view.frame = CGRectMake(20, 20, self.view.frame.size.width-40, self.view.frame.size.height-40);
//    [self.view addSubview:self.navRoot.view];
}

#pragma mark <JxCalendarDelegate>
- (BOOL)calendarShouldStartRanging{
    return YES;
}
- (BOOL)calendarSelectionStyleSwitchable{
    return YES;
}
- (void)calendarShouldClearSelections{
    
    [self.dataSource.selectedDates removeAllObjects];
    [self.dataSource.selectedEvents removeAllObjects];
}
- (void)calendarDidSelectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance{
    //DLog(@" %@", date);
    
    [self.dataSource.selectedDates addObject:date];
}
- (void)calendarDidDeselectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance{
    //DLog(@" %@", date);
    
    [self.dataSource.selectedDates removeObject:date];
}
- (void)calendarDidSelectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance{
    //DLog(@" %@", event);
    
    [self.dataSource.selectedEvents addObject:event];
}
- (void)calendarDidDeselectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance{
    //DLog(@" %@", event);
    
    [self.dataSource.selectedEvents removeObject:event];
}
- (void)calendarWillTransitionFrom:(JxCalendarAppearance)fromAppearance to:(JxCalendarAppearance)toAppearance{
    //DLog(@"from %d to %d", fromAppearance, toAppearance);
}
- (void)calendarDidTransitionTo:(JxCalendarAppearance)toAppearance{
    //DLog(@"to %d", toAppearance);
    
    if (toAppearance == JxCalendarAppearanceWeek || toAppearance == JxCalendarAppearanceDay) {
        
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate new]];
        components.day = 17;
        
        NSDate *date = [[self.dataSource calendar] dateFromComponents:components];
        
        DLog(@"date %@", date);

        NSArray *events = [self.dataSource eventsAt:date];
        
        DLog(@"events %@", events);
        if (events.count > 0) {
            [_overview scrollToEvent:events[9]];
        }
        
    }
}

#pragma mark Range
- (void)calendarShouldClearRange{
    [self.dataSource.rangedDates removeAllObjects];
}
- (void)calendarDidRange:(JxCalendarRangeElement *)rangeElement whileOnAppearance:(JxCalendarAppearance)appearance{
    
    NSInteger index = [self indexOfDateInRange:rangeElement.date];
    
    if (index >= 0) {
        [self.dataSource.rangedDates replaceObjectAtIndex:index withObject:rangeElement];
        NSLog(@"replace date");
    }else{
        [self.dataSource.rangedDates addObject:rangeElement];
        NSLog(@"add date");
    }
    
}
- (void)calendarDidDeRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance{
    
    for (JxCalendarRangeElement *rangeElement in self.dataSource.rangedDates) {
        if ([rangeElement.date isEqual:date]) {
            [self.dataSource.rangedDates removeObject:rangeElement];
            return;
        }
    }
}
- (NSInteger)indexOfDateInRange:(NSDate *)date{
    NSInteger index = 0;
    for (JxCalendarRangeElement *rangeElement in self.dataSource.rangedDates) {
        
        if ([rangeElement.date isEqual:date]) {
            return index;
        }
        index++;
    }
    return -1;
}

@end
