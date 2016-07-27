//
//  JxCalender.h
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"
#import "JxCalendarViewController.h"

@class JxCalendarCell;

@protocol JxCalendarDataSource, JxCalendarDelegate;

@interface JxCalendarOverview : JxCalendarViewController <JxCalendarScrollTo>

/* style how to use scrolling and if there is a pullto event on the edges or not */
@property (assign, nonatomic, readonly) JxCalendarScrollingStyle scrollingStyle;

/* maximum time in range per day */
/* this may be usefull if a workday maximum should be 8 hours and a half day 4 hours */
/* default = 24 */
@property (assign, nonatomic, readwrite) NSInteger lengthOfDayInHours;

/* display proportional ranged time on cell */
/* default = NO */
@property (assign, nonatomic, readwrite) BOOL proportionalRangeTime;

/* display FreeChoice RangeElements as duration */
/* default is hh:mm - hh:mm */
/* duration means hh:mm h */
@property (assign, nonatomic, readwrite) BOOL displayRangeTimeAdDuration;

/* if selected week or day is current day */
@property (assign, nonatomic, readwrite) BOOL scrollToCurrentTimeAndDate;


/* Internal Use only */
@property (assign, nonatomic, readonly) JxCalendarAppearance overviewAppearance;
@property (assign, nonatomic, readonly) JxCalendarAppearance appearance;


/* Init */
- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource
                andStyle:(JxCalendarOverviewStyle)style
                 andSize:(CGSize)size
            andStartDate:(NSDate *)date
      andStartAppearance:(JxCalendarAppearance)appearance
       andSelectionStyle:(JxCalendarSelectionStyle)selectionStyle
       andScrollingStyle:(JxCalendarScrollingStyle)scrollingStyle;

- (NSMutableArray <JxCalendarRangeElement *> *)defineRangeForStartDate:(NSDate *)start toEndDate:(NSDate *)end;

- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year animated:(BOOL)animated;
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance;
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance withDate:(NSDate *)newDate;

- (void)updateContentForStartDate:(NSDate *)start till:(NSDate *)end;

- (NSIndexPath *)getIndexPathForDate:(NSDate *)date;
- (void)updateRangeForCell:(JxCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/* For internal use only */
- (BOOL)nextCellIsInRangeWithIndexPath:(NSIndexPath *)indexPath;
- (BOOL)lastCellIsInRangeWithIndexPath:(NSIndexPath *)indexPath;

- (void)startRefreshForHeader;
- (void)startRefreshForFooter;

- (void)finishRefreshForHeader;
- (void)finishRefreshForFooter;
@end

