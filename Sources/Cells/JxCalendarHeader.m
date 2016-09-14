//
//  JxCalendarHeader.m
//  JxCalendar
//
//  Created by Jeanette Müller on 28.10.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarHeader.h"

@implementation JxCalendarHeader

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
    
    [self setNeedsLayout];
}
- (UILabel *)titleLabelWithFrame:(CGRect)frame{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-10, frame.size.height)];
        _titleLabel.tag = 0;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font =  [UIFont fontWithName:@"Helvetica Neue Thin" size:14.0f];;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}


@end
