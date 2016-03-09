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
