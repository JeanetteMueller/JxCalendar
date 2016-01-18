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
- (NSArray <JxCalendarEvent *> *)eventsAt:(NSDate *)date{
    
    if (!date) {
        return @[];
    }
    NSDateComponents *components = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    
    NSDateComponents *nowComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    
    if (components.year == nowComponents.year && components.month == nowComponents.month && components.day == 17) {
//    if (components.year == nowComponents.year && components.month == nowComponents.month && components.day == nowComponents.day) {
        
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        
        JxCalendarEventDay *wholeDay1 = [[JxCalendarEventDay alloc] initWithIdentifier:@"day 1" calendar:[self calendar] andTitle:@"Geburtstag 1" andDay:[[self calendar] dateFromComponents:components]];
        JxCalendarEventDay *wholeDay2 = [[JxCalendarEventDay alloc] initWithIdentifier:@"day 2" calendar:[self calendar] andTitle:@"Geburtstag 2" andDay:[[self calendar] dateFromComponents:components]];
        JxCalendarEventDay *wholeDay3 = [[JxCalendarEventDay alloc] initWithIdentifier:@"day 3" calendar:[self calendar] andTitle:@"Geburtstag 3" andDay:[[self calendar] dateFromComponents:components]];
        JxCalendarEventDay *wholeDay4 = [[JxCalendarEventDay alloc] initWithIdentifier:@"day 4" calendar:[self calendar] andTitle:@"Geburtstag 4" andDay:[[self calendar] dateFromComponents:components]];
        
        NSInteger startTime = 15;
        
        [components setHour:startTime];
        
        JxCalendarEventDuration *event1_1 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla1" calendar:[self calendar] andTitle:@"10 min" andStart:[[self calendar] dateFromComponents:components] andDuration:10];
        JxCalendarEventDuration *event1_2 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla2" calendar:[self calendar] andTitle:@"20 min" andStart:[[self calendar] dateFromComponents:components] andDuration:20];
        JxCalendarEventDuration *event1_3 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla3" calendar:[self calendar] andTitle:@"30 min" andStart:[[self calendar] dateFromComponents:components] andDuration:30];
        JxCalendarEventDuration *event1_4 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla4" calendar:[self calendar] andTitle:@"40 min" andStart:[[self calendar] dateFromComponents:components] andDuration:40];
        JxCalendarEventDuration *event1_5 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla5" calendar:[self calendar] andTitle:@"50 min" andStart:[[self calendar] dateFromComponents:components] andDuration:50];
        JxCalendarEventDuration *event1_6 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla6" calendar:[self calendar] andTitle:@"60 min" andStart:[[self calendar] dateFromComponents:components] andDuration:60];
        
        [components setHour:startTime+1];
        
        JxCalendarEventDuration *event1 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla7" calendar:[self calendar] andTitle:@"40 min" andStart:[[self calendar] dateFromComponents:components] andDuration:40];
        
        [components setHour:startTime+2];
        
        JxCalendarEventDuration *event2 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla8" calendar:[self calendar] andTitle:@"1:20h" andStart:[[self calendar] dateFromComponents:components] andDuration:80];
        JxCalendarEventDuration *event3 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla9" calendar:[self calendar] andTitle:@"30 min" andStart:[[self calendar] dateFromComponents:components] andDuration:30];
        JxCalendarEventDuration *event4 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla10" calendar:[self calendar] andTitle:@"2,5h" andStart:[[self calendar] dateFromComponents:components] andDuration:150];
        [components setMinute:30];
        JxCalendarEventDuration *event42 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla10" calendar:[self calendar] andTitle:@"2,5h" andStart:[[self calendar] dateFromComponents:components] andDuration:150];
        
        
        
        
        JxCalendarEventDuration *event41 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla11" calendar:[self calendar] andTitle:@"4,5h" andStart:[[self calendar] dateFromComponents:components] andDuration:270];
        
        [components setHour:startTime+3];
        [components setMinute:20];
        
        JxCalendarEventDuration *event5 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla12" calendar:[self calendar] andTitle:@"30 min" andStart:[[self calendar] dateFromComponents:components] andDuration:40];
        [components setMinute:0];
        JxCalendarEventDuration *event6 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla13" calendar:[self calendar] andTitle:@"2h" andStart:[[self calendar] dateFromComponents:components] andDuration:120];
        
        [components setHour:startTime+4];
        
        JxCalendarEventDuration *event7 = [[JxCalendarEventDuration alloc] initWithIdentifier:@"bla14" calendar:[self calendar] andTitle:@"1h" andStart:[[self calendar] dateFromComponents:components] andDuration:60];
        
        
        return @[wholeDay1, wholeDay2, wholeDay3, wholeDay4,
                 event1_1, event1_2, event1_3, event1_4, event1_5, event1_6,
                 event1, event2, event3, event4, event42,
                 event41,
                 event5, event6,
                 event7];
    }
    
    return @[];
}

@end
