//
//  JxCalendarDefinitions.h
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//



#ifndef JxCalendarDefinitions_h
#define JxCalendarDefinitions_h

#define kPullToSwitchContextOffset                  80

#define kJxCalendarYearLayoutCells                  @"JxCalendarYearLayoutCells"
#define kJxCalendarYearLayoutHeader                 @"JxCalendarYearLayoutHeader"

#define kJxCalendarWeekLayoutCells                  @"JxCalendarWeekLayoutCells"
#define kJxCalendarWeekLayoutWholeDay               @"JxCalendarWeekLayoutWholeDay"
#define kJxCalendarWeekLayoutHeader                 @"JxCalendarWeekLayoutHeader"

#define kJxCalendarMonthLayoutCells                 @"JxCalendarMonthLayoutCells"
#define kJxCalendarMonthLayoutHeader                @"JxCalendarMonthLayoutHeader"
#define kJxCalendarMonthLayoutDecoration            @"JxCalendarMonthLayoutDecoration"

#define kJxCalendarDayLayoutCells                   @"JxCalendarDayLayoutCells"
#define kJxCalendarDayLayoutWholeDay                @"JxCalendarDayLayoutWholeDay"
#define kJxCalendarDayLayoutHeader                  @"JxCalendarDayLayoutHeader"

#define kCalendarLayoutDaySectionHeightMultiplier    2
#define kCalendarLayoutDayHeaderHeight              49
#define kCalendarLayoutDayHeaderHalfHeight          24
#define kCalendarLayoutDayHeaderTextWidth           65

#define kCalendarLayoutWholeDayHeight               20

#define kJxCalendarBackgroundColor                  [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0]

#define kJxCalendarDayBackgroundColor               [UIColor whiteColor]
#define kJxCalendarDayBorderColor                   kJxCalendarDayBackgroundColor
#define kJxCalendarDayTextColor                     [UIColor blackColor]
#define kJxCalendarWeekendBackgroundColor           [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:1.0]
#define kJxCalendarWeekendBorderColor               kJxCalendarWeekendBackgroundColor
#define kJxCalendarWeekendTextColor                 [UIColor blackColor]

#define kJxCalendarSelectedDayBackgroundColor       kJxCalendarDayBackgroundColor
#define kJxCalendarSelectedWeekendBackgroundColor   kJxCalendarWeekendBackgroundColor
#define kJxCalendarSelectedDayBorderColor           [UIColor redColor]
#define kJxCalendarSelectedDayTextColor             [UIColor redColor]

#define kJxCalendarRangeDotBackgroundColor          [UIColor colorWithRed:1.0 green:0.9321 blue:0.7866 alpha:1.0]
#define kJxCalendarRangeDotBorderColor              [UIColor colorWithRed:0.9818 green:0.7086 blue:0.3623 alpha:1.0]
#define kJxCalendarRangeDotBorderWidth              1.5f
#define kJxCalendarRangeBackgroundColor             kJxCalendarRangeDotBackgroundColor

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
