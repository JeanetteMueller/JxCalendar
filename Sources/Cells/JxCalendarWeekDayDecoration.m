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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInitWithFrame:frame];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultInit];
    }
    return self;
}
- (void)defaultInit{
    [self defaultInitWithFrame:CGRectZero];
}
- (void)defaultInitWithFrame:(CGRect)frame{
    
    [self labelWithFrame:frame];
    [self setNeedsLayout];
}
- (UILabel *)labelWithFrame:(CGRect)frame{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.tag = 200;
        _label.numberOfLines = 0;
        _label.font = [UIFont fontWithName:@"Helvetica Neue Thin" size:14.0f];
        _label.textColor = [UIColor blackColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_label];
    }
    return _label;
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

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

@end
