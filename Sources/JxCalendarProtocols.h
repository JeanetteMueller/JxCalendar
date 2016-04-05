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
- (JxCalendarRangeElement *)rangeElementForDate:(NSDate *)date;
- (JxCalendarDayTypeMask)availableDayTypesForDate:(NSDate *)date;

- (JxCalendarRangeElement *)preparedRangeElementForDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType andMaximumDayLength:(NSInteger)maxDayHours;

- (JxCalendarDayType)defaultDayTypeForDate:(NSDate *)date; // default: JxCalendarDayTypeWholeDay


- (BOOL)isRangeToolTipAvailableForDate:(NSDate *)date;
- (JxCalendarRangeStyleInCell)rangeStyleForDate:(NSDate *)date; // default: JxCalendarRangeStyleInCellHorizontal

- (UIView *)viewForPullToRefreshHeaderWhileOnAppearance:(JxCalendarAppearance)appearance;
- (UIView *)viewForPullToRefreshFooterWhileOnAppearance:(JxCalendarAppearance)appearance;

- (void)calendar:(JxCalendarOverview *)calendar willDisplayMonth:(NSInteger)month inYear:(NSInteger)year;
- (void)calendar:(JxCalendarOverview *)calendar didHideMonth:(NSInteger)month inYear:(NSInteger)year;
@end


@protocol JxCalendarDelegate <NSObject>

@optional
#pragma mark Appearance
- (NSString *)calendar:(JxCalendarOverview *)calendar titleOnDate:(NSDate *)date whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar willTransitionFrom:(JxCalendarAppearance)fromAppearance to:(JxCalendarAppearance)toAppearance;
- (void)calendar:(JxCalendarOverview *)calendar didTransitionTo:(JxCalendarAppearance)toAppearance;

- (void)calendar:(JxCalendarOverview *)calendar didScroll:(CGPoint)offset whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didReachRefreshOffsetForHeader:(UIView *)header whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didReachRefreshOffsetForFooter:(UIView *)footer whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didRefreshByHeader:(UIView *)header whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didRefreshByFooter:(UIView *)footer whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didLeftRefreshOffsetForHeader:(UIView *)header whileOnAppearance:(JxCalendarAppearance)appearance;
- (void)calendar:(JxCalendarOverview *)calendar didLeftRefreshOffsetForFooter:(UIView *)footer whileOnAppearance:(JxCalendarAppearance)appearance;

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
