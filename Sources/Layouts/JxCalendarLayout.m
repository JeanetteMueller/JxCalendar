//
//  JxCalendarLayout.m
//  JxCalendar
//
//  Created by Jeanette Müller on 01.10.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayout.h"

@implementation JxCalendarLayout

- (void)setNewSize:(CGSize)size{
    self.size = size;
    
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}


@end
