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

@protocol JxCalendarDataSource, JxCalendarDelegate;

@interface JxCalendarWeek : JxCalendarViewController

@property (nonatomic, readwrite) NSInteger startYear;
@property (nonatomic, readwrite) NSInteger startMonth;

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size;

- (NSDate *)getDateForSection:(NSInteger)section;
@end
