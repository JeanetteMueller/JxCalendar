//
//  JxCalendarDefinitions.h
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#include <CoreFoundation/CFBase.h>

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

#define kCalendarLayoutWholeDayHeight               30

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


#define kJxCalendarDayTypeOptionUnknown             @"–"
#define kJxCalendarDayTypeOptionWholeDay            @"Ganzer Tag >"
#define kJxCalendarDayTypeOptionHalfDay             @"Halber Tag >"

#define kJxCalendarDayTypeOptionHalfDayMorning      @"Vormittag >"
#define kJxCalendarDayTypeOptionHalfDayAfternoon    @"Nachmittag >"

#define kJxCalendarDayTypeOptionWorkDay             @"Arbeitstag >"
#define kJxCalendarDayTypeOptionFreeChoice          @"Freie Wahl >"
#define kJxCalendarDayTypeOptionFreeChoiceMax       @"Freie Wahl von/bis >"

typedef NS_ENUM(NSInteger, JxCalendarAppearance) {
    JxCalendarAppearanceNone,
    JxCalendarAppearanceYear,
    JxCalendarAppearanceMonth,
    JxCalendarAppearanceWeek,
    JxCalendarAppearanceDay
};

typedef NS_ENUM(NSInteger, JxCalendarOverviewStyle) {
    JxCalendarOverviewStyleYearGrid,
    JxCalendarOverviewStyleMonthGrid
};

typedef NS_ENUM(NSInteger, JxCalendarSelectionStyle) {
    /* touch on an item opens the detailview, long holf start range-selection */
    JxCalendarSelectionStyleDefault,
    
    /* touch on an item opens the detailview, no aktive long-hold gesture */
    JxCalendarSelectionStyleSelectOnly,
    
    /* touch on an item start a range-selection. another touch ends range-selection. touch and hold start and change range */
    JxCalendarSelectionStyleRangeOnly
    
};

typedef NS_ENUM(NSInteger, JxCalendarDayType) {
    JxCalendarDayTypeUnknown,
    
    /* complete day, 24 hours */
    JxCalendarDayTypeWholeDay,
    
    /* workday, typicaly 8 hours */
    JxCalendarDayTypeWorkDay,
    
    /* half day, typicaly 4 hours */
    JxCalendarDayTypeHalfDay,
    
    /* Half Day 0-12 */
    JxCalendarDayTypeHalfDayMorning,
    
    /* Half Day 12-24 */
    JxCalendarDayTypeHalfDayAfternoon,
    
    /* free choice */
    JxCalendarDayTypeFreeChoice,
    
    /* free choice with on end to max value like x-24 or 0-x */
    JxCalendarDayTypeFreeChoiceMax,
};

typedef NS_OPTIONS(NSUInteger, JxCalendarDayTypeMask) {
    JxCalendarDayTypeMaskUnknown = (1 << JxCalendarDayTypeUnknown),
    JxCalendarDayTypeMaskWholeDay = (1 << JxCalendarDayTypeWholeDay),
    JxCalendarDayTypeMaskWorkDay = (1 << JxCalendarDayTypeWorkDay),
    JxCalendarDayTypeMaskHalfDay = (1 << JxCalendarDayTypeHalfDay),
    JxCalendarDayTypeMaskHalfDayMorning = (1 << JxCalendarDayTypeHalfDayMorning),
    JxCalendarDayTypeMaskHalfDayAfternoon = (1 << JxCalendarDayTypeHalfDayAfternoon),
    JxCalendarDayTypeMaskFreeChoice = (1 << JxCalendarDayTypeFreeChoice),
    JxCalendarDayTypeMaskFreeChoiceMax = (1 << JxCalendarDayTypeFreeChoiceMax),
    
    JxCalendarDayTypeMaskFreeChoices = (JxCalendarDayTypeMaskFreeChoice|JxCalendarDayTypeMaskFreeChoiceMax),
    
    JxCalendarDayTypeMaskAll = (JxCalendarDayTypeMaskWholeDay|JxCalendarDayTypeMaskWorkDay|JxCalendarDayTypeMaskHalfDay|JxCalendarDayTypeMaskHalfDayMorning|JxCalendarDayTypeMaskHalfDayAfternoon|JxCalendarDayTypeMaskFreeChoice|JxCalendarDayTypeMaskFreeChoiceMax)
};

typedef NS_ENUM (NSInteger, JxCalendarRangeStyleInCell){
    JxCalendarRangeStyleInCellVertical,
    JxCalendarRangeStyleInCellHorizontal
};


#endif /* JxCalendarDefinitions_h */
