//
//  JxCalendarLayoutDay.h
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayout.h"

#define kCalendarLayoutDaySectionHeight 120
#define kCalendarLayoutDayHeaderHeight 49
#define kCalendarLayoutDayHeaderHalfHeight 24
#define kCalendarLayoutDayHeaderTextWidth 65

@interface JxCalendarLayoutDay : JxCalendarLayout

- (id)initWithWidth:(CGFloat)width andEvents:(NSArray *)events andCalendar:(NSCalendar *)calendar;

@end
