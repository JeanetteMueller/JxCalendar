//
//  JxCalendarEventCell.m
//  JxCalendar
//
//  Created by Jeanette Müller on 05.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarEventCell.h"

@implementation JxCalendarEventCell

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
    
    [self textViewWithFrame:frame];
    
    [self setNeedsLayout];
}
- (UITextView *)textViewWithFrame:(CGRect)frame{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        _textView.tag = 0;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.font = [UIFont systemFontOfSize:14.0f];
        _textView.textColor = [UIColor blackColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_textView];
    }
    return _textView;
}

@end
