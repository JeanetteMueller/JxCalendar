//
//  JxCalendarLayout.h
//  JxCalendar
//
//  Created by Jeanette Müller on 01.10.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxCalendarLayout : UICollectionViewFlowLayout

@property (assign, nonatomic, readwrite) CGSize size;

- (void)setNewSize:(CGSize)size;

@end
