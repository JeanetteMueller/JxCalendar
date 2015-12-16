//
//  JxCalendarBasics.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JxCalendarBasics : NSObject

+ (NSDateComponents *)baseComponentsWithCalendar:(NSCalendar *)calendar andYear:(NSInteger)year;
+ (NSDate *)firstDayOfMonth:(NSInteger)month inCalendar:(NSCalendar *)calendar andYear:(NSInteger)year;
+ (NSDate *)lastDayOfMonth:(NSInteger)month inCalendar:(NSCalendar *)calendar andYear:(NSInteger)year;
+ (NSInteger)normalizedWeekDay:(NSInteger)weekday;

+ (NSDateFormatter *)defaultFormatter;
@end
