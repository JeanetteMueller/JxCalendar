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

@property (strong, nonatomic) NSDate *date;
@property (nonatomic, readwrite) JxCalendarDayType dayType;

@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *end;

@property (nonatomic, readonly) NSTimeInterval duration;

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType inCalendar:(NSCalendar *)calendar andMaximumDayLength:(NSInteger)maxDayHours;
- (id)initWithDate:(NSDate *)date withStartDate:(NSDate *)start andEndDate:(NSDate *)end;
@end
