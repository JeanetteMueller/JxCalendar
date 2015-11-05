//
//  JxCalendarEvent.h
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxCalendarEvent : NSObject

@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic, readonly) NSDate *end;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *borderColor;

- (id)initWithStart:(NSDate *)start andEnd:(NSDate *)end andTitle:(NSString *)title;
- (id)initWithStart:(NSDate *)start andDuration:(NSTimeInterval)duration andTitle:(NSString *)title;

- (void)setDuration:(NSTimeInterval)duration;
- (void)setEnd:(NSDate *)end;
@end
