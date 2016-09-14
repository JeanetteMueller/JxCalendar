//
//  JxCalendarWeekHeader.m
//  JxCalendar
//
//  Created by Jeanette Müller on 23.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarWeekHeader.h"

@implementation JxCalendarWeekHeader

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
    
    [self titleLabelWithFrame:frame];
    [self buttonWithFrame:frame];
    [self eventMarkerWithFrame:frame];
    [self setNeedsLayout];
}
- (UILabel *)titleLabelWithFrame:(CGRect)frame{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _titleLabel.tag = 0;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font =  [UIFont fontWithName:@"Helvetica Neue Thin" size:14.0f];;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (UIButton *)buttonWithFrame:(CGRect)frame{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        _button.tag = 0;
        _button.font =  [UIFont systemFontOfSize:18.0f];;
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor clearColor];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_button];
    }
    return _button;
}
- (UIView *)eventMarkerWithFrame:(CGRect)frame{
    if (!_eventMarker) {
        _eventMarker = [[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height-3,frame.size.width,3)];
        _eventMarker.tag = 400;
        _eventMarker.clipsToBounds = YES;
        _eventMarker.backgroundColor = [UIColor cyanColor];
        _eventMarker.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_eventMarker];
        
    }
    return _eventMarker;
}
@end
