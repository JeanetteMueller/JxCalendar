//
//  JxCalender.h
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"

#import "JxCalendarViewController.h"

@protocol JxCalendarDataSource, JxCalendarDelegate;

@interface JxCalendarOverview : JxCalendarViewController


- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andStyle:(JxCalendarOverviewStyle)style andSize:(CGSize)size andStartDate:(NSDate *)date andStartAppearance:(JxCalendarAppearance)appearance;


- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year animated:(BOOL)animated;
- (void)scrollToDate:(NSDate *)date;

- (void)switchToAppearance:(JxCalendarAppearance)newAppearance;
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance withDate:(NSDate *)newDate;

- (JxCalendarAppearance)getAppearance;

@end

