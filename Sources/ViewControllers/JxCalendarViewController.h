//
//  JxCalendarViewController.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"

@interface JxCalendarViewController : UICollectionViewController

@property (nonatomic, readwrite) JxCalendarOverviewStyle style;

@property (strong, nonatomic) id<JxCalendarDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<JxCalendarDelegate> delegate;

@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic, readwrite) JxCalendarAppearance startAppearance;

@property (nonatomic, readwrite) BOOL renderWeekDayLabels; /* default YES */

- (NSDateComponents *)startComponents;
- (NSDateComponents *)componentsFromDate:(NSDate *)date;

- (JxCalendarOverview *)getCalendarOverview;

@end
