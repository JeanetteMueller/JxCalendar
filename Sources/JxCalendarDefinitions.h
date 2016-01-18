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
    JxCalendarAppearanceNone,
    JxCalendarAppearanceYear,
    JxCalendarAppearanceMonth,
    JxCalendarAppearanceWeek,
    JxCalendarAppearanceDay
} JxCalendarAppearance;

typedef enum {
    JxCalendarOverviewStyleYearGrid,
    JxCalendarOverviewStyleMonthGrid
} JxCalendarOverviewStyle;

@class JxCalendarOverview, JxCalendarEvent;


@protocol JxCalendarDataSource <NSObject>

- (NSCalendar *)calendar;

- (NSUInteger)numberOfEventsAt:(NSDate *)date;

- (NSArray <JxCalendarEvent*> *)eventsAt:(NSDate *)date;

@optional
- (BOOL)isDaySelected:(NSDate *)date;
- (BOOL)isEventSelected:(JxCalendarEvent *)event;
@end


@protocol JxCalendarDelegate <NSObject>

- (void)calendarDidSelectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidSelectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance;
@optional
- (NSString *)calendarTitleOnDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
@end


#endif /* JxCalendarDefinitions_h */
