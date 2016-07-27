//
//  JxCalendarRangeElement.m
//  JxCalendar
//
//  Created by Jeanette Müller on 09.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import "JxCalendarRangeElement.h"
@interface JxCalendarRangeElement ()

@property (assign, nonatomic, readwrite) JxCalendarDayType dayType;

@property (strong, nonatomic, readwrite) NSDate *date;
@property (strong, nonatomic, readwrite) NSDate *start;
@property (strong, nonatomic, readwrite) NSDate *end;

@end

@implementation JxCalendarRangeElement

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType inCalendar:(NSCalendar *)calendar andMaximumDayLength:(NSInteger)maxDayHours{
    self = [super init];
    if (self) {
        self.date = date;
        self.dayType = dayType;
        
        NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                   fromDate:self.date];
        
        switch (dayType) {
            case JxCalendarDayTypeFreeChoiceMin:{
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeFreeChoiceMax:{
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours-1;
                components.minute = 59;
                components.second = 59;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeUnknown:
            case JxCalendarDayTypeWholeDay:
            case JxCalendarDayTypeWorkDay:
            case JxCalendarDayTypeFreeChoice:{
                
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            
                components.hour = maxDayHours-1;
                components.minute = 59;
                components.second = 59;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeHalfDay:
            case JxCalendarDayTypeHalfDayMorning:{
                
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
            case JxCalendarDayTypeHalfDayAfternoon:{
                
                components.hour = maxDayHours/2;
                components.minute = 0;
                components.second = 0;
                
                self.start = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
                
                components.hour = maxDayHours-1;
                components.minute = 59;
                components.second = 59;
                
                self.end = [calendar dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
            }break;
        }
    }
    return self;
}

- (id)initWithDate:(NSDate *)date andDayType:(JxCalendarDayType)dayType withStartDate:(NSDate *)start andEndDate:(NSDate *)end{
    self = [super init];
    if (self) {
        self.date = date;
        self.dayType = dayType;
        self.start = start;
        self.end = end;

    }
    return self;
}

- (NSTimeInterval)duration{
    return [self.end timeIntervalSinceDate:self.start];
}

- (BOOL)isFromValueWhileFreeChoiceMaxWithCalendar:(NSCalendar *)calendar{
    if (self.dayType == JxCalendarDayTypeFreeChoiceMax) {
        NSDateComponents *startComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.start];
        
        if (startComponents.hour == 0 && startComponents.minute == 0 && startComponents.second == 0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"RangeElement %@ (%@ - %@)", _date, _start, _end];
}

@end
