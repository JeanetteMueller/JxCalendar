//
//  JxCalendarLayoutGrid.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutList.h"

@implementation JxCalendarLayoutList

- (id)initWithWidth:(CGFloat)width{
    self = [super init];
    
    if (self) {
        
        CGFloat borders = 2.0f;
        
        self.sectionInset = UIEdgeInsetsMake(borders, borders, 20, borders);
    
        CGFloat itemwidth = width - (2*borders);
        
        self.itemSize = CGSizeMake(itemwidth, 50);
        self.minimumInteritemSpacing = borders;
        self.minimumLineSpacing = borders;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.headerReferenceSize = CGSizeMake(width, 30);
        
    }
    return self;
}

@end
