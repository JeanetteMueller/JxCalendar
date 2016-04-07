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

@property (assign, nonatomic, readwrite) JxCalendarOverviewStyle style;

@property (strong, nonatomic) id<JxCalendarDataSource> dataSource;
@property (assign, nonatomic, unsafe_unretained) id<JxCalendarDelegate> delegate;

@property (strong, nonatomic) NSDate *startDate;
@property (assign, nonatomic, readwrite) JxCalendarAppearance startAppearance;

@property (assign, nonatomic, readwrite) BOOL renderWeekDayLabels; /* default YES */
@property (assign, nonatomic, readwrite) BOOL initialScrollDone;

- (NSDateComponents *)startComponents;
- (NSDateComponents *)componentsFromDate:(NSDate *)date;

- (JxCalendarOverview *)getCalendarOverview;
- (void)startUpdateRefreshViews;
- (void)updateRefreshViews;

- (JxCalendarAppearance)getAppearance;
- (void)startRefreshForHeader;
- (void)startRefreshForFooter;

- (void)finishRefreshForHeader;
- (void)finishRefreshForFooter;

@end
