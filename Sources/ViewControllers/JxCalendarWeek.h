//
//  JxCalendarWeek.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"
#import "JxCalendarViewController.h"
#import "JxCalendarEvent.h"

@protocol JxCalendarDataSource, JxCalendarDelegate;

@interface JxCalendarWeek : JxCalendarViewController <JxCalendarScrollTo>

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size andStartDate:(NSDate *)start;

- (NSDate *)getDateForSection:(NSInteger)section;

@end
