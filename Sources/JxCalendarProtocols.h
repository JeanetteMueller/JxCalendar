//
//  JxCalendarProtocols.h
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import "JxCalendarDefinitions.h"
#import "JxCalendarRangeElement.h"

#ifndef JxCalendarProtocols_h
#define JxCalendarProtocols_h

@class JxCalendarOverview, JxCalendarEvent, JxCalendarRangeElement;

@protocol JxCalendarScrollTo <NSObject>

- (void)scrollToEvent:(JxCalendarEvent *)event;
- (void)scrollToDate:(NSDate *)date;

@end

@protocol JxCalendarDataSource <NSObject>

- (NSCalendar *)calendar;

- (NSUInteger)numberOfEventsAt:(NSDate *)date;

- (NSArray <JxCalendarEvent*> *)eventsAt:(NSDate *)date;

- (NSArray <JxCalendarRangeElement *> *)rangedDates;

@optional
- (BOOL)isDaySelectable:(NSDate *)date;
- (BOOL)isDaySelected:(NSDate *)date;
- (BOOL)isEventSelected:(JxCalendarEvent *)event;

- (BOOL)shouldDisplayNavbarButtonsWhileOnAppearance:(JxCalendarAppearance)appearance;


- (BOOL)isDayRangeable:(NSDate *)date;
- (BOOL)isStartOfRange:(NSDate *)date;
- (BOOL)isEndOfRange:(NSDate *)date;
- (BOOL)isPartOfRange:(NSDate *)date;
- (JxCalendarDayType)dayTypeOfDateInRange:(NSDate *)date;
- (JxCalendarRangeElement *)rangeElementForDate:(NSDate *)date;
- (JxCalendarDayTypeMask)availableDayTypesForDate:(NSDate *)date;
- (BOOL)isRangeToolTipAvailableForDate:(NSDate *)date;
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
- (BOOL)calendarShouldStartRanging;
- (void)calendarDidStartRanging;
- (void)calendarDidRange:(JxCalendarRangeElement *)rangeElement whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidEndRanging;
- (void)calendarDidDeRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarShouldClearRange;



/* BETTER VERSION */

#pragma mark Selections
- (BOOL)calendarSelectionStyleSwitchable:(JxCalendarOverview *)calendar;

#pragma mark Select
- (void)calendarShouldClearSelections:(JxCalendarOverview *)calendar ;
- (void)calendar:(JxCalendarOverview *)calendar didSelectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didDeselectDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didSelectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didDeselectEvent:(JxCalendarEvent *)event whileOnAppearance:(JxCalendarAppearance)appearance;

#pragma mark Range
- (BOOL)calendarShouldStartRanging:(JxCalendarOverview *)calendar;
- (void)calendarDidStartRanging:(JxCalendarOverview *)calendar;
- (void)calendar:(JxCalendarOverview *)calendar didRange:(JxCalendarRangeElement *)rangeElement whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidEndRanging:(JxCalendarOverview *)calendar;
- (void)calendar:(JxCalendarOverview *)calendar didDeRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarShouldClearRange:(JxCalendarOverview *)calendar;
@end

#endif /* JxCalendarProtocols_h */
