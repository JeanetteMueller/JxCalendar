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
    
    NSLog(@"set new itemSize: %f x %f", self.size.width, self.size.height);
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
//    CGRect oldBounds = self.collectionView.bounds;
//    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
//        return YES;
//    }
    return YES;
}


@end
