//
//  JxCalendarEvent.m
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarEvent.h"

@interface JxCalendarEvent ()
@property (strong, nonatomic, readwrite) NSString *identifier;
@property (strong, nonatomic, readwrite) NSCalendar *calendar;



@end

@implementation JxCalendarEvent

- (id)initWithIdentifier:(NSString *)identifier calendar:(NSCalendar *)calendar andTitle:(NSString *)title{
    self = [super init];
    if (self) {
        
        self.identifier = identifier;
        self.calendar = calendar;
        self.title = title;
        
        self.fontColor = [UIColor whiteColor];
        
        
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        self.borderColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        
        //self.borderColor = [UIColor blueColor];
        self.backgroundColor = [self.borderColor colorWithAlphaComponent:0.75f];
    }
    return self;
}


- (NSString *)description{
    return [NSString stringWithFormat:@"Event %@ (%@)", _title, _identifier];
}
@end
