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

typedef enum {
    /* touch on an item opens the detailview, long holf start range-selection */
    JxCalendarSelectionStyleDefault,
    
    /* touch on an item opens the detailview, no aktive long-hold gesture */
    JxCalendarSelectionStyleSelectOnly,
    
    /* touch on an item start a range-selection. another touch ends range-selection. touch and hold start and change range */
    JxCalendarSelectionStyleRangeOnly
    
} JxCalendarSelectionStyle;

@class JxCalendarOverview, JxCalendarEvent;

@protocol JxCalendarScrollTo <NSObject>

- (void)scrollToEvent:(JxCalendarEvent *)event;
- (void)scrollToDate:(NSDate *)date;

@end

@protocol JxCalendarDataSource <NSObject>

- (NSCalendar *)calendar;

- (NSUInteger)numberOfEventsAt:(NSDate *)date;

- (NSArray <JxCalendarEvent*> *)eventsAt:(NSDate *)date;

@optional
- (BOOL)isDaySelectable:(NSDate *)date;
- (BOOL)isDaySelected:(NSDate *)date;
- (BOOL)isEventSelected:(JxCalendarEvent *)event;

- (BOOL)shouldDisplayNavbarButtonsWhileOnAppearance:(JxCalendarAppearance)appearance;

- (BOOL)isDayRangeable:(NSDate *)date;
- (BOOL)isStartOfRange:(NSDate *)date;
- (BOOL)isEndOfRange:(NSDate *)date;
- (BOOL)isPartOfRange:(NSDate *)date;

@end


@protocol JxCalendarDelegate <NSObject>

@optional
#pragma mark Appearance
- (NSString *)calendarTitleOnDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarWillTransitionFrom:(JxCalendarAppearance)fromAppearance to:(JxCalendarAppearance)toAppearance;
- (void)calendarDidTransitionTo:(JxCalendarAppearance)toAppearance;

#pragma mark Selections
- (BOOL)calendarSelectionStyleSwitchable;

#pragma mark Select
- (void)calendarShouldClearSelections;
- (void)calendarDidSelectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidDeselectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidSelectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidDeselectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance;


#pragma mark Range
- (void)calendarShouldClearRange;
- (void)calendarDidRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidDeRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;

@end


#endif /* JxCalendarDefinitions_h */
