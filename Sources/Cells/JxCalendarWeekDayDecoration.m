//
//  JxCalendarWeekHeader.m
//  JxCalendar
//
//  Created by Jeanette Müller on 23.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarWeekDayDecoration.h"
#import "JxCalendarBasics.h"

@implementation JxCalendarWeekDayDecoration

- (void)awakeFromNib {
    // Initialization code
    
}
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [super applyLayoutAttributes:layoutAttributes];
    
    NSIndexPath *path = layoutAttributes.indexPath;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [calendar components:NSCalendarUnitDay|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitYear|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitWeekday
                                               fromDate:[NSDate new]];
    
    components.year = 2016;
    components.month = 2;
    components.day = path.item+1;
    components.hour = 12;
    
    NSDate *date = [calendar dateFromComponents:components];
    
    NSDateFormatter *weekday = [JxCalendarBasics defaultFormatter];
    [weekday setDateFormat: @"EEE"];

    self.label.text = [NSString stringWithFormat:@"%@", [weekday stringFromDate:date]];
    
}
@end
