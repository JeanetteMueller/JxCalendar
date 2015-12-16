//
//  JxCalendarDefinitions.h
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//



#ifndef JxCalendarDefinitions_h
#define JxCalendarDefinitions_h

#define kPullToSwitchContextOffset 80

#define kJxCalendarYearLayoutCells @"JxCalendarYearLayoutCells"
#define kJxCalendarYearLayoutHeader @"JxCalendarYearLayoutHeader"

#define kJxCalendarWeekLayoutCells @"JxCalendarWeekLayoutCells"
#define kJxCalendarWeekLayoutWholeDay @"JxCalendarWeekLayoutWholeDay"
#define kJxCalendarWeekLayoutHeader @"JxCalendarWeekLayoutHeader"

#define kJxCalendarMonthLayoutCells @"JxCalendarMonthLayoutCells"
#define kJxCalendarMonthLayoutHeader @"JxCalendarMonthLayoutHeader"

#define kJxCalendarDayLayoutCells       @"JxCalendarDayLayoutCells"
#define kJxCalendarDayLayoutWholeDay @"JxCalendarDayLayoutWholeDay"
#define kJxCalendarDayLayoutHeader      @"JxCalendarDayLayoutHeader"

#define kCalendarLayoutDaySectionHeightMultiplier 2
#define kCalendarLayoutDayHeaderHeight 49
#define kCalendarLayoutDayHeaderHalfHeight 24
#define kCalendarLayoutDayHeaderTextWidth 65

#define kCalendarLayoutWholeDayHeight 20

typedef enum {
    JxCalendarStyleYearGrid,
    JxCalendarStyleMonthGrid
} JxCalendarStyle;

@class JxCalendarOverview;


@protocol JxCalendarDataSource <NSObject>

- (NSCalendar *)calendar;

- (NSUInteger)numberOfEventsAt:(NSDate *)date;

- (NSArray *)eventsAt:(NSDate *)date;

@end


@protocol JxCalendarDelegate <NSObject>

- (void)calendar:(JxCalendarOverview *)calendarOverview didSelectDate:(NSDate *)date;

@end


#endif /* JxCalendarDefinitions_h */
