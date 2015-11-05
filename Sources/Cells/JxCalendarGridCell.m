//
//  JxCalendarGridCell.m
//  JxCalendar
//
//  Created by Jeanette Müller on 27.10.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarGridCell.h"
#import "JxCalendarLayoutMonthGrid.h"
#import "JxCalendarLayoutYearGrid.h"

@implementation JxCalendarGridCell


- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout{
    [super willTransitionFromLayout:oldLayout toLayout:newLayout];
    
    NSLog(@"willTransitionFromLayout");
    
    if ([newLayout isKindOfClass:[JxCalendarLayoutYearGrid class]]) {
        NSLog(@"--- is jetzt year");
        
        UILabel *textLabel = (UILabel *)[self viewWithTag:333];
        
        textLabel.font = [textLabel.font fontWithSize:10];
    }
    if ([newLayout isKindOfClass:[JxCalendarLayoutMonthGrid class]]) {
        NSLog(@"--- is jetzt month");
        
        UILabel *textLabel = (UILabel *)[self viewWithTag:333];
        
        textLabel.font = [textLabel.font fontWithSize:15];
    }
    
}
- (void)didTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout{
    [super didTransitionFromLayout:oldLayout toLayout:newLayout];
    NSLog(@"didTransitionFromLayout");

    if ([newLayout isKindOfClass:[JxCalendarLayoutYearGrid class]]) {
        NSLog(@"--- is jetzt year");
        
        UILabel *textLabel = (UILabel *)[self viewWithTag:333];
        
        textLabel.font = [textLabel.font fontWithSize:10];
    }
    if ([newLayout isKindOfClass:[JxCalendarLayoutMonthGrid class]]) {
        NSLog(@"--- is jetzt month");
        
        UILabel *textLabel = (UILabel *)[self viewWithTag:333];
        
        textLabel.font = [textLabel.font fontWithSize:15];
    }
}
@end
