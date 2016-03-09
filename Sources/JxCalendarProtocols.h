//
//  JxCalendarProtocols.h
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import "JxCalendarDefinitions.h"

#ifndef JxCalendarProtocols_h
#define JxCalendarProtocols_h

@class JxCalendarOverview, JxCalendarEvent;

@protocol JxCalendarScrollTo <NSObject>

- (void)scrollToEvent:(JxCalendarEvent *)event;
- (void)scrollToDate:(NSDate *)date;

@end

@protocol JxCalendarDataSource <NSObject>

@property (strong, nonatomic) NSMutableArray <NSDictionary*> *rangedDates;

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
- (JxCalendarDayType)dayTypeOfDateInRange:(NSDate *)date;
- (JxCalendarDayType)availableDayTypesForDate:(NSDate *)date;
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
- (void)calendarDidRangeDate:(NSDate *)date withDayType:(JxCalendarDayType)dayType whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidRangeDate:(NSDate *)date withStartDate:(NSDate *)start andEndDate:(NSDate *)end whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendarDidDeRangeDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;

@end

#endif /* JxCalendarProtocols_h */
