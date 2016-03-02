//
//  JxCalendarEventDay.h
//  JxCalendar
//
//  Created by Jeanette Müller on 16.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <JxCalendar/JxCalendarEvent.h>

@interface JxCalendarEventDay : JxCalendarEvent



- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andDay:(NSDate *)day;

@end
