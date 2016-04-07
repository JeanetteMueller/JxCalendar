//
//  JxCalendarLayoutOverview.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayout.h"
#import "JxCalendarOverview.h"

@interface JxCalendarLayoutOverview : JxCalendarLayout

@property (strong, nonatomic) JxCalendarViewController *overview;
@property (assign, nonatomic, readwrite) BOOL renderWeekDayLabels;

@property (assign, nonatomic, readwrite) CGSize contentSize;
@property (strong, nonatomic) NSCache *layouts;
@property (strong, nonatomic) NSCache *cachedItemAttributes;
@property (strong, nonatomic) NSCache *cachedDecoAttributes;
@property (strong, nonatomic) NSCache *cachedHeadlineAttributes;

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)sizeOfOneMonth;
@end
