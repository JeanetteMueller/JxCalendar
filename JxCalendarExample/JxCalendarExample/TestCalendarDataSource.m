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
    return eventDays.count;
}
- (NSArray *)eventsAt:(NSDate *)date{
    
    if (!date) {
        return @[];
    }
    NSDateComponents *components = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    
    NSDateComponents *nowComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components.year == nowComponents.year && components.month == 1 && components.day == 2) {
//    if (components.year == nowComponents.year && components.month == nowComponents.month && components.day == nowComponents.day) {
        
        [components setHour:2];
        JxCalendarEvent *event1_1 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:10 andTitle:@"10 min"];
        JxCalendarEvent *event1_2 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:20 andTitle:@"20 min"];
        JxCalendarEvent *event1_3 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:30 andTitle:@"30 min"];
        JxCalendarEvent *event1_4 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:40 andTitle:@"40 min"];
        JxCalendarEvent *event1_5 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:50 andTitle:@"50 min"];
        JxCalendarEvent *event1_6 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:60 andTitle:@"60 min"];
        
        [components setHour:3];
        
        JxCalendarEvent *event1 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:40 andTitle:@"40 min"];
        
        [components setHour:4];
        
        JxCalendarEvent *event2 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:80 andTitle:@"1:20 h"];
        
        JxCalendarEvent *event3 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:30 andTitle:@"30 min"];
        
        JxCalendarEvent *event4 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:150 andTitle:@"2,5h"];
        
        [components setMinute:30];
        
        JxCalendarEvent *event41 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:270 andTitle:@"4,5h"];
        
        [components setHour:6];
        [components setMinute:0];
        JxCalendarEvent *event5 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:30 andTitle:@"30 min"];
        
        JxCalendarEvent *event6 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:120 andTitle:@"2 h"];
        
        [components setHour:16];
        
        JxCalendarEvent *event7 = [[JxCalendarEvent alloc] initWithStart:[[self calendar] dateFromComponents:components] andDuration:60 andTitle:@"1 h"];
        
        
        return @[event1_1, event1_2, event1_3, event1_4, event1_5, event1_6,
                 event1, event2, event3, event4, event41,
                 event5, event6,
                 event7];
    }
    
    return @[];
}

@end
