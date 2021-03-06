//
//  JxCalendarWeekEventCell.m
//  JxCalendar
//
//  Created by Jeanette Müller on 16.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarWeekEventCell.h"

@implementation JxCalendarWeekEventCell

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
    
    [self textLabelWithFrame:frame];
    
    [self setNeedsLayout];
}
- (UILabel *)textLabelWithFrame:(CGRect)frame{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, frame.size.width-6, frame.size.height)];
        _textLabel.tag = 200;
        _textLabel.numberOfLines = 1;
        _textLabel.font =  [UIFont fontWithName:@"Helvetica Neue" size:12.0f];;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.minimumScaleFactor = 0.3;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_textLabel];
    }

    return _textLabel;
}
- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

@end
