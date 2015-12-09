//
//  TestCalendarDataSource.m
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "TestCalendarDataSource.h"
#import <JxCalendar/JxCalendar.h>

@implementation TestCalendarDataSource 




#pragma mark - <JxCalendarDataSource>
- (NSCalendar *)calendar{

    return [NSCalendar currentCalendar];
}
- (NSUInteger)numberOfEventsAt:(NSDate *)date{
    
    NSArray *eventDays = [self eventsAt:date];
    
    NSInteger count = 0;
    for (NSArray *events in eventDays) {
        count += events.count;
    }
    
    
    return count;
}
- (NSArray *)eventsAt:(NSDate *)date{
    
    NSDateComponents *components = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    
    if (components.year == 2015 && components.month == 12 && components.day == 9) {
        
        [components setHour:12];
        
        JxCalendarEvent *event1 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:40 andTitle:@"40 min"];
        
        [components setHour:14];
        
        JxCalendarEvent *event2 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:80 andTitle:@"1:20 h"];
        
        JxCalendarEvent *event3 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:30 andTitle:@"30 min"];
        
        JxCalendarEvent *event4 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:150 andTitle:@"2,5h"];
        
        [components setMinute:30];
        
        JxCalendarEvent *event41 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:270 andTitle:@"4,5h"];
        
        [components setHour:15];
        [components setMinute:0];
        JxCalendarEvent *event5 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:30 andTitle:@"30 min"];
        
        JxCalendarEvent *event6 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:120 andTitle:@"2 h"];
        
        [components setHour:16];
        
        JxCalendarEvent *event7 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:60 andTitle:@"1 h"];
        
        
        return @[@[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[event1],
                 @[],
                 @[event2, event3, event4, event41],
                 @[event5, event6],
                 @[event7],
                 @[],
                 @[],
                 
                 @[],
                 @[],
                 @[],
                 @[],
                 @[],
                 @[]
                 ];
    }
    
    return @[];
}

@end
