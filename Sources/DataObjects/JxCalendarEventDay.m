//
//  JxCalendarEventDay.m
//  JxCalendar
//
//  Created by Jeanette Müller on 16.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarEventDay.h"

@implementation JxCalendarEventDay

- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andDay:(NSDate *)day{
    self = [super initWithIdentifier:identifier calendar:calendar andTitle:title];
    if (self) {
        self.backgroundColor = [self.borderColor colorWithAlphaComponent:0.9f];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|
                                        NSCalendarUnitMonth|
                                        NSCalendarUnitDay|
                                        NSCalendarUnitMinute
                                                   fromDate:day];
        
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        
        self.start = [calendar dateFromComponents:components];
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@| Whole Day at %@", [super description], self.start];
}
@end
