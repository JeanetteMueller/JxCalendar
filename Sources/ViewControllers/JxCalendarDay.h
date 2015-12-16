//
//  JxCalendarDayCollectionViewController.h
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"

@interface JxCalendarDay : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, unsafe_unretained) id<JxCalendarDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<JxCalendarDelegate> delegate;

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSDateFormatter *defaultFormatter;

@end
