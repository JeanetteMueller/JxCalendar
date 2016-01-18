//
//  JxCalendarEvent.h
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxCalendarEvent : NSObject

@property (strong, nonatomic, readonly) NSString *identifier;
@property (strong, nonatomic, readonly) NSCalendar *calendar;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) UIColor *fontColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *borderColor;

@property (strong, nonatomic) UIColor *fontColorSelected;
@property (strong, nonatomic) UIColor *backgroundColorSelected;
@property (strong, nonatomic) UIColor *borderColorSelected;

- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title;



@end
