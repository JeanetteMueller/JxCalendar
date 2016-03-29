//
//  JxCalendarDayCollectionViewController.h
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarViewController.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"

@interface JxCalendarDay : JxCalendarViewController <UICollectionViewDelegateFlowLayout>

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size andStartDate:(NSDate *)start;

@end
