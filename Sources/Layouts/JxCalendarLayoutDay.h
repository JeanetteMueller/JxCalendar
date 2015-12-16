//
//  JxCalendarLayoutDay.h
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayout.h"

@class JxCalendarDay;

@interface JxCalendarLayoutDay : JxCalendarLayout

@property (strong, nonatomic) JxCalendarDay *source;

- (id)initWithSize:(CGSize)size andDay:(NSDate *)day;

@end
