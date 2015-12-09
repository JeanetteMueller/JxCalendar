//
//  JxCalendarEvent.m
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarEvent.h"

@interface JxCalendarEvent ()

@property (strong, nonatomic, readwrite) NSDate *end;
@property (nonatomic, readwrite) NSTimeInterval duration;

@end

@implementation JxCalendarEvent

- (id)init{
    self = [super init];
    if (self) {
        
        self.fontColor = [UIColor whiteColor];
        
        
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        self.borderColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        //self.borderColor = [UIColor blueColor];
        self.backgroundColor = [self.borderColor colorWithAlphaComponent:0.5f];
    }
    return self;
}
- (id)initWithStart:(NSDate *)start andEnd:(NSDate *)end andTitle:(NSString *)title{
    self = [self init];
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
- (id)initWithStart:(NSDate *)start andDuration:(NSTimeInterval)duration andTitle:(NSString *)title{
    self = [self init];
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
    return [NSString stringWithFormat:@"von %@ bis %@: %@", _start, _end, _title];
}
@end
