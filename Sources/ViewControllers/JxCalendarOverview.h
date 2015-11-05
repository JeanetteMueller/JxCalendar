//
//  JxCalender.h
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"

@protocol JxCalendarDataSource, JxCalendarDelegate;

@interface JxCalendarOverview : UICollectionViewController

@property (nonatomic, readonly) NSInteger startYear;

@property (strong, nonatomic) id<JxCalendarDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<JxCalendarDelegate> delegate;

- (void)switchToYear:(NSInteger)year;

- (void)switchToYearGridView;
- (void)switchToMonthGridView;
- (void)switchToListView;

@end

