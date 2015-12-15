//
//  JxCalendarLayoutOverview.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutOverview.h"

@implementation JxCalendarLayoutOverview

- (id)initWithViewController:(JxCalendarOverview *)vc andSize:(CGSize)size{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemSize;
}
@end
