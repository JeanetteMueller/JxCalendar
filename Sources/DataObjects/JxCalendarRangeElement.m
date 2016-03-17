//
//  JxCalendarRangeElement.m
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import "JxCalendarRangeElement.h"

@implementation JxCalendarRangeElement

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType inCalendar:(NSCalendar *)calendar andMaximumDayLength:(NSInteger)maxDayHours{
    self = [super init];
    if (self) {
        self.date = date;
        self.dayType = dayType;
        
        NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                   fromDate:self.date];
        
        switch (dayType) {
            case JxCalendarDayTypeUnknown:
            case JxCalendarDayTypeWholeDay:
            case JxCalendarDayTypeWorkDay:
            case JxCalendarDayTypeFreeChoice:{
                
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            
                components.hour = maxDayHours-1;
                components.minute = 59;
                components.second = 59;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeHalfDay:
            case JxCalendarDayTypeHalfDayMorning:{
                
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeHalfDayAfternoon:{
                
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours-1;
                components.minute = 59;
                components.second = 59;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
        }
    }
    return self;
}
- (id)initWithDate:(NSDate *)date withStartDate:(NSDate *)start andEndDate:(NSDate *)end{
    self = [super init];
    if (self) {
        self.date = date;
        self.dayType = JxCalendarDayTypeFreeChoice;
        self.start = start;
        self.end = end;
    }
    return self;
}
- (NSTimeInterval)duration{
    return [self.end timeIntervalSinceDate:self.start];
}
@end
