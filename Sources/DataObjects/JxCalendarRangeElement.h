//
//  JxCalendarRangeElement.h
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JxCalendarDefinitions.h"

@interface JxCalendarRangeElement : NSObject

@property (nonatomic, readonly) JxCalendarDayType dayType;

@property (strong, nonatomic, readonly) NSDate *date;
@property (strong, nonatomic, readonly) NSDate *start;
@property (strong, nonatomic, readonly) NSDate *end;

@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType inCalendar:(NSCalendar *)calendar andMaximumDayLength:(NSInteger)maxDayHours;
- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType withStartDate:(NSDate *)start andEndDate:(NSDate *)end;

- (BOOL)isFromValueWhileFreeChoiceMaxWithCalendar:(NSCalendar *)calendar;
@end
