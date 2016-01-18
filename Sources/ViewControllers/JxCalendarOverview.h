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

- (void)switchToYear:(NSInteger)year;
- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year;
- (void)scrollToDate:(NSDate *)date;

@end

