//
//  JxCalendarLayoutOverview.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayout.h"
#import "JxCalendarOverview.h"

@interface JxCalendarLayoutOverview : JxCalendarLayout

@property (strong, nonatomic) JxCalendarViewController *overview;
@property (nonatomic, readwrite) BOOL renderWeekDayLabels;

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
