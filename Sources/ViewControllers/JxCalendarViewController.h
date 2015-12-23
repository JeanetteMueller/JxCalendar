//
//  JxCalendarViewController.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxCalendarDefinitions.h"

@interface JxCalendarViewController : UICollectionViewController

@property (nonatomic, readwrite) JxCalendarStyle style;

@property (strong, nonatomic) id<JxCalendarDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<JxCalendarDelegate> delegate;

@property (nonatomic, readwrite) NSInteger startYear;

@end
