//
//  JxCalendarDayHeader.m
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarDayHeader.h"

@implementation JxCalendarDayHeader

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
    [self lineWithFrame:frame];
    
    [self setNeedsLayout];
}
- (UILabel *)titleLabelWithFrame:(CGRect)frame{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 45, 49)];
        _titleLabel.tag = 0;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}
- (UIView *)lineWithFrame:(CGRect)frame{
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(50,24,270,1)];
        _line.tag = 0;
        _line.backgroundColor = [UIColor lightGrayColor];
        _line.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_line];
        
    }
    return _line;
}

@end
