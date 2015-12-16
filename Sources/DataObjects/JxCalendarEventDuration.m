//
//  JxCalendarEventDuration.m
//  JxCalendar
//
//  Created by Jeanette Müller on 16.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarEventDuration.h"

@interface JxCalendarEventDuration ()

@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *end;
@property (nonatomic) NSTimeInterval duration;
@end

@implementation JxCalendarEventDuration

- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andStart:(NSDate *)start andEnd:(NSDate *)end{
    self = [self initWithIdentifier:identifier calendar:(NSCalendar *)calendar andTitle:title];
    if (self) {
        
        self.start = start;
        [self setEnd:end];
        
        if (!title) {
            title = @"";
        }
        self.title = title;
        
    }
    return self;
}
- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title andStart:(NSDate *)start andDuration:(NSTimeInterval)duration{
    self = [self initWithIdentifier:identifier calendar:(NSCalendar *)calendar andTitle:title];
    if (self) {
        
        self.start = start;
        [self setDuration:duration];
        
        if (!title) {
            title = @"";
        }
        self.title = title;
        
    }
    return self;
}
- (void)setDuration:(NSTimeInterval)duration{
    _end = [NSDate dateWithTimeInterval:duration sinceDate:_start];
    _duration = duration;
}
- (void)setEnd:(NSDate *)end{
    _end = end;
    _duration = [end timeIntervalSinceDate:_start];
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@|von %@ bis %@", [super description], _start, _end];
}
@end
