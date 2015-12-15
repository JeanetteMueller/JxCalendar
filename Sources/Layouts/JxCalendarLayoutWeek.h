//
//  JxCalendarLayoutWeek.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutOverview.h"

@class JxCalendarWeek;

@interface JxCalendarLayoutWeek : JxCalendarLayout

@property (strong, nonatomic) JxCalendarWeek *source;

- (id)initWithSize:(CGSize)size;

@end
