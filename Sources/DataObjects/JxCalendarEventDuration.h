//
//  JxCalendarEventDuration.h
//  JxCalendar
//
//  Created by Jeanette Müller on 16.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <JxCalendar/JxCalendar.h>

@interface JxCalendarEventDuration : JxCalendarEvent

@property (strong, nonatomic, readonly) NSDate *end;
@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andStart:(NSDate *)start andEnd:(NSDate *)end;
- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andStart:(NSDate *)start andDuration:(NSTimeInterval)duration;

- (void)setDuration:(NSTimeInterval)duration;
- (void)setEnd:(NSDate *)end;

@end
