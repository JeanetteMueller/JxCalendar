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

/* pull down to go one year back in time, bull up on the lower part to go one year forward */
/* default = YES */
@property (nonatomic, readwrite) BOOL pullToSwitchYears;

/* maximum time in range per day */
/* this may be usefull if a workday maximum should be 8 hours and a half day 4 hours */
/* default = 24 */
@property (nonatomic, readwrite) NSInteger lengthOfDayInHours;


- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource
                andStyle:(JxCalendarOverviewStyle)style
                 andSize:(CGSize)size
            andStartDate:(NSDate *)date
      andStartAppearance:(JxCalendarAppearance)appearance
       andSelectionStyle:(JxCalendarSelectionStyle)selectionStyle;

- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year animated:(BOOL)animated;
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance;
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance withDate:(NSDate *)newDate;

- (JxCalendarAppearance)getAppearance;

- (NSIndexPath *)getIndexPathForDate:(NSDate *)date;
- (void)updateRangeForCell:(JxCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

//For internal use only;
- (JxCalendarAppearance)getOverviewAppearance;

@end

