//
//  JxCalendarRangeElement.m
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import "JxCalendarRangeElement.h"

@implementation JxCalendarRangeElement

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType{
    self = [super init];
    if (self) {
        self.date = date;
        self.dayType = dayType;
        
        if (dayType == JxCalendarDayTypeFreeChoice) {
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                       fromDate:self.date];
            
            components.hour = 0;
            components.minute = 0;
            components.second = 0;
            
            self.start = [calendar dateFromComponents:components];
            
            components.hour = 24;
            components.minute = 0;
            components.second = 0;
            
            self.end = [calendar dateFromComponents:components];
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
@end
