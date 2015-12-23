//
//  JxCalendarBasics.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarBasics.h"

@implementation JxCalendarBasics

+ (NSDateComponents *)baseComponentsWithCalendar:(NSCalendar *)calendar andYear:(NSInteger)year{
    
    NSDateComponents *components = [calendar components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday)
                                                      fromDate:[NSDate date]];
    
    
    [components setYear:year];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return components;
}
+ (NSDate *)firstDayOfMonth:(NSInteger)month inCalendar:(NSCalendar *)calendar andYear:(NSInteger)year{
    NSDateComponents *base = [JxCalendarBasics baseComponentsWithCalendar:calendar andYear:year];
    
    if (month > 12) {
        
        NSInteger moreYears = ceil(month/12);
        
        month = (month % 12);
        
        [base setYear:base.year + moreYears ];
    }
    [base setMonth:month];
    [base setDay:1];
    
    return [[NSCalendar currentCalendar] dateFromComponents:base];
}
+ (NSDate *)lastDayOfMonth:(NSInteger)month inCalendar:(NSCalendar *)calendar andYear:(NSInteger)year{
    NSDateComponents *base = [JxCalendarBasics baseComponentsWithCalendar:calendar andYear:year];
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:month inCalendar:calendar andYear:year];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                          inUnit:NSCalendarUnitMonth
                                         forDate:firstDay];
    
    if (month > 12) {
        
        NSInteger moreYears = ceil(month/12);
        
        month = (month % 12);
        
        [base setYear:base.year + moreYears ];
    }
    
    [base setMonth:month];
    [base setDay:range.length];
    return [calendar dateFromComponents:base];
}
+ (NSInteger)normalizedWeekDay:(NSInteger)weekday{
    weekday = weekday -1;
    if (weekday == 0) {
        weekday = 7;
    }
    
    return weekday;
}
+ (NSDateFormatter *)defaultFormatter{
    static NSDateFormatter *formater = nil;
    static dispatch_once_t pred;
    
    if (formater) return formater;
    
    dispatch_once(&pred, ^{
        formater = [[NSDateFormatter alloc] init];
        [formater setLocale:[NSLocale currentLocale]];//  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formater setDateStyle:NSDateFormatterFullStyle];
    });
    
    return formater;
}
@end
