//
//  JxCalendarCell.m
//  JxCalendar
//
//  Created by Jeanette Müller on 03.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarCell.h"

@implementation JxCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame");
        [self defaultInitWithFrame:frame];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initWithCoder");
        [self defaultInit];
    }
    return self;
}
- (void)defaultInit{
    [self defaultInitWithFrame:CGRectZero];
}
- (void)defaultInitWithFrame:(CGRect)frame{
    
    [self eventMarkerWithFrame:frame];
    [self rangeToWithFrame:frame];
    [self rangeFromWithFrame:frame];
    [self rangeDotWithFrame:frame];
    [self rangeDotBackgroundWithFrame:frame];
    [self labelWithFrame:frame];
    [self setNeedsLayout];
}
- (UILabel *)labelWithFrame:(CGRect)frame{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.tag = 200;
        _label.clipsToBounds = YES;
        _label.numberOfLines = 0;
        _label.font = [UIFont fontWithName:@"Helvetica Neue Thin" size:15.0f];
        _label.textColor = [UIColor blueColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_label];
    }
    return _label;
}
- (UIView *)eventMarkerWithFrame:(CGRect)frame{
    if (!_eventMarker) {
        _eventMarker = [[UIView alloc] initWithFrame:CGRectMake(0,0,15,15)];
        _eventMarker.tag = 400;
        _eventMarker.clipsToBounds = YES;
        _eventMarker.backgroundColor = [UIColor cyanColor];
        _eventMarker.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_eventMarker];
        
    }
    return _eventMarker;
}
- (UIView *)rangeToWithFrame:(CGRect)frame{
    if (!_rangeTo) {
        _rangeTo = [[UIView alloc] initWithFrame:CGRectMake(-5, 15, 70, 70)];
        _rangeTo.tag = 301;
        _rangeTo.clipsToBounds = YES;
        _rangeTo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_rangeTo];
        
    }
    return _rangeTo;
}
- (UIView *)rangeFromWithFrame:(CGRect)frame{
    if (!_rangeFrom) {
        _rangeFrom = [[UIView alloc] initWithFrame:CGRectMake(35, 15, 70, 70)];
        _rangeFrom.tag = 300;
        _rangeFrom.clipsToBounds = YES;
        _rangeFrom.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_rangeFrom];
        
    }
    return _rangeFrom;
}

- (UIView *)rangeDotWithFrame:(CGRect)frame{
    if (!_rangeDot) {
        _rangeDot = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        _rangeDot.tag = 302;
        _rangeDot.clipsToBounds = YES;
        _rangeDot.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:_rangeDot];
        
    }
    return _rangeDot;
}


- (UIView *)rangeDotBackgroundWithFrame:(CGRect)frame{
    if (!_rangeDotBackground) {
        _rangeDotBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        _rangeDotBackground.tag = 0;
        _rangeDotBackground.clipsToBounds = YES;
        _rangeDotBackground.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        _rangeDotBackground.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [[self rangeDotWithFrame:frame] addSubview:_rangeDotBackground];
    }
    return _rangeDotBackground;
}


//- (void)setNeedsLayout {
//    NSLog(@"setNeedsLayout");
//    [super setNeedsLayout];
//    [self setNeedsDisplay];
//}
//- (void)layoutSubviews{
//    [super layoutSubviews];
//    
//}

@end
