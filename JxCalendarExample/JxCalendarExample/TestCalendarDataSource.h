//
//  TestCalendarDataSource.h
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JxCalendar/JxCalendar.h>

@interface TestCalendarDataSource : NSObject <JxCalendarDataSource>

@property (strong, nonatomic) NSMutableArray <NSDate*> *selectedDates;
@property (strong, nonatomic) NSMutableArray <JxCalendarEvent*> *selectedEvents;
@property (strong, nonatomic) NSMutableArray <JxCalendarRangeElement*> *rangedDates;

@end
