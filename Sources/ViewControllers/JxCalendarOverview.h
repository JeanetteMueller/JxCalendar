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

@property (nonatomic, readonly) NSInteger startYear;



- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andStyle:(JxCalendarStyle)style andSize:(CGSize)size;

- (void)switchToYear:(NSInteger)year;



- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year;
- (void)scrollToDate:(NSDate *)date;
@end

