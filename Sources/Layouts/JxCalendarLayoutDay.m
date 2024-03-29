//
//  JxCalendarLayoutDay.m
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutDay.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"
#import "JxCalendarEvent.h"
#import "JxCalendarEventDuration.h"
#import "JxCalendarDay.h"

#define kJxCalendarLayoutDayMinimumEventHeight 0
#define kJxCalendarLayoutDayOverlapItemsPhone  .3
#define kJxCalendarLayoutDayOverlapItemsPad    .0

@interface JxCalendarLayoutDay ()

@property (strong, nonatomic) NSMutableDictionary *layoutInfo;
@property (strong, nonatomic) NSDate *day;

@end

@implementation JxCalendarLayoutDay

- (CGFloat)overlapingEventsIndicator{
    if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad){
        return kJxCalendarLayoutDayOverlapItemsPad;
    }
    return kJxCalendarLayoutDayOverlapItemsPhone;
}
- (id)initWithSize:(CGSize)size andDay:(NSDate *)day{
    self = [self init];
    if (self) {
        self.size = size;
        self.day = day;
        
        CGFloat multiplier = 3.5;
        
        self.headerReferenceSize = CGSizeMake(self.size.width, kCalendarLayoutDayHeaderHeight);
        self.minimumInteritemSpacing = 1;

        CGFloat maxWidth = floor((self.size.width-kCalendarLayoutDayHeaderTextWidth) / multiplier) - self.minimumInteritemSpacing;
        if (maxWidth > 150) {
            maxWidth = 150;
        }
        self.itemSize = CGSizeMake(maxWidth, (60*kCalendarLayoutDaySectionHeightMultiplier));
        self.minimumLineSpacing = 1;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

#pragma mark - Layout

- (void)invalidateLayout{
    self.layoutInfo = nil;
    [super invalidateLayout];
}

- (void)prepareLayout{
    [super prepareLayout];
    
    if (self.layoutInfo) {
        return;
    }
    
    self.layoutInfo = [NSMutableDictionary dictionary];
    
    
    self.layoutInfo[kJxCalendarDayLayoutCells] = [NSMutableDictionary dictionary];
    self.layoutInfo[kJxCalendarDayLayoutWholeDay] = [NSMutableDictionary dictionary];
    self.layoutInfo[kJxCalendarDayLayoutHeader] = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        itemAttributes.frame = [self frameForHeaderAtSection:indexPath.section];
        itemAttributes.zIndex = 0;
        self.layoutInfo[kJxCalendarDayLayoutHeader][indexPath] = itemAttributes;
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            itemAttributes.frame = CGRectZero;
            
            JxCalendarEvent *e = [self eventForIndexPath:indexPath];
            
            if ([e isKindOfClass:[JxCalendarEventDay class]]) {
                itemAttributes.frame = [self frameForDayEvent:(JxCalendarEventDay *)e atIndexPath:indexPath];
                itemAttributes.zIndex = 20;
                self.layoutInfo[kJxCalendarDayLayoutWholeDay][indexPath] = itemAttributes;
            }else if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
                itemAttributes.frame = [self frameForDurationEvent:(JxCalendarEventDuration *)e atIndexPath:indexPath];
                itemAttributes.zIndex = 10;
                self.layoutInfo[kJxCalendarDayLayoutCells][indexPath] = itemAttributes;
            }else{
                NSLog(@"aaahm something's wrong!!!");
            }
            
            
        }
    }
    

}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    for (NSMutableDictionary *list in self.layoutInfo.allValues) {
        for (UICollectionViewLayoutAttributes *attributes in [list allValues]) {
            
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }
    }
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize{
    CGFloat maxWidth = self.collectionView.frame.size.width;
    CGFloat maxHeight = self.collectionView.frame.size.height;
    if (!self.layoutInfo) {
        [self prepareLayout];
        
    }
    
    for (NSMutableDictionary *list in self.layoutInfo.allValues) {
        for (UICollectionViewLayoutAttributes *attributes in [list allValues]) {
            if (attributes.frame.origin.x + attributes.frame.size.width > maxWidth) {
                maxWidth = attributes.frame.origin.x + attributes.frame.size.width;
            }
            
            if (attributes.frame.origin.y + attributes.frame.size.height > maxHeight) {
                maxHeight = attributes.frame.origin.y + attributes.frame.size.height;
            }
        }
    }

    return CGSizeMake(maxWidth, maxHeight);
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (self.layoutInfo[kJxCalendarDayLayoutCells][indexPath]) {
        return self.layoutInfo[kJxCalendarDayLayoutCells][indexPath];
    }
    if (self.layoutInfo[kJxCalendarDayLayoutWholeDay][indexPath]) {
        return self.layoutInfo[kJxCalendarDayLayoutWholeDay][indexPath];
    }
    return nil;
}

- (NSArray <JxCalendarEvent*> *)eventsForWholeDay{
    NSMutableArray *items = [NSMutableArray array];
    
    if ([self.source.dataSource respondsToSelector:@selector(eventsAt:)]) {
        for (JxCalendarEvent *e in [self.source.dataSource eventsAt:_day]) {
            if ([e isKindOfClass:[JxCalendarEventDay class]]) {
                JxCalendarEventDay *event = (JxCalendarEventDay *)e;
                [items addObject:event];
            }
        }
    }
    return items;
}

- (JxCalendarEventDuration *)eventForIndexPath:(NSIndexPath *)indexPath{
   
    NSMutableArray *items = [NSMutableArray array];
    if ([self.source.dataSource respondsToSelector:@selector(eventsAt:)]) {
        NSArray <JxCalendarEvent*> *events = [self.source.dataSource eventsAt:_day];
        
        for (JxCalendarEvent *e in events) {
            if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
                JxCalendarEventDuration *event = (JxCalendarEventDuration *)e;
                
                NSDateComponents *components = [[self.source.dataSource calendar] components:NSCalendarUnitHour fromDate:event.start];
                
                if (components.hour == indexPath.section) {
                    [items addObject:event];
                }
            }else if ([e isKindOfClass:[JxCalendarEventDay class]]) {
                if (indexPath.section == 0) {
                    JxCalendarEventDay *event = (JxCalendarEventDay *)e;
                    [items addObject:event];
                }
            }
        }
        
        if (items.count > indexPath.item) {
            return [items objectAtIndex:indexPath.item];
        }
    }
    return nil;
}

- (CGRect)frameForDurationEvent:(JxCalendarEventDuration *)event atIndexPath:(NSIndexPath *)indexPath{

    NSDateComponents *startComponents;
    if (event) {
        startComponents = [[self.source.dataSource calendar] components:( NSCalendarUnitHour |
                                                     NSCalendarUnitMinute |
                                                     NSCalendarUnitSecond |
                                                     NSCalendarUnitDay |
                                                     NSCalendarUnitMonth |
                                                     NSCalendarUnitYear |
                                                     NSCalendarUnitWeekday   )
                                           fromDate:event.start];
    }
    
    
    CGFloat itemHeight = (event.duration/60)*kCalendarLayoutDaySectionHeightMultiplier - (2*self.minimumLineSpacing) - 1;
    
    if (itemHeight < kJxCalendarLayoutDayMinimumEventHeight) {
        itemHeight = kJxCalendarLayoutDayMinimumEventHeight;
    }
    CGRect rect = CGRectMake(kCalendarLayoutDayHeaderTextWidth,
                             indexPath.section * (60*kCalendarLayoutDaySectionHeightMultiplier) + [self wholeDayAreaHeight] + self.minimumLineSpacing + 1 + startComponents.minute*kCalendarLayoutDaySectionHeightMultiplier,
                             self.itemSize.width,
                             itemHeight);
    
    if (![self.source getCalendarOverview].ignoreOverlapping) {
        while (![self checkIfRectIsAvailable:rect forType:kJxCalendarDayLayoutCells]){
            rect.origin.x = rect.origin.x + self.itemSize.width + self.minimumInteritemSpacing - (rect.size.width * [self overlapingEventsIndicator]);
        }
    }
    return rect;
}

- (CGRect)frameForDayEvent:(JxCalendarEventDay *)event atIndexPath:(NSIndexPath *)indexPath{

    CGRect rect = CGRectMake(kCalendarLayoutDayHeaderTextWidth,
                             self.collectionView.contentOffset.y,
                             self.itemSize.width*2 + self.minimumInteritemSpacing,
                             kCalendarLayoutWholeDayHeight);
    
    int count = 0;
    while (![self checkIfRectIsAvailable:rect forType:kJxCalendarDayLayoutWholeDay]){
        
        rect.origin.y = rect.origin.y + kCalendarLayoutWholeDayHeight+self.minimumLineSpacing;
    
        count++;
        
        if (count == 3) {
            count = 0;
            
            rect.origin.x = rect.origin.x + (self.itemSize.width+self.minimumInteritemSpacing)*2;
            rect.origin.y = self.collectionView.contentOffset.y;
        }
    }
    if (count < 3) {
        return rect;
    }
    return CGRectZero;
}

#pragma mark - Headers Layout

- (CGFloat)wholeDayAreaHeight{
    return 3*(kCalendarLayoutWholeDayHeight+self.minimumLineSpacing);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return self.layoutInfo[kJxCalendarDayLayoutHeader][indexPath];
}

- (CGRect)frameForHeaderAtSection:(NSInteger)section{
    return CGRectMake((self.collectionView.contentOffset.x >= 0)?self.collectionView.contentOffset.x: 0,
                      section * (60*kCalendarLayoutDaySectionHeightMultiplier) + [self wholeDayAreaHeight]- kCalendarLayoutDayHeaderHalfHeight,
                      MAX(self.collectionView.frame.size.width, self.collectionView.frame.size.height),
                      self.headerReferenceSize.height);
}

- (BOOL)checkIfRectIsAvailable:(CGRect)rect forType:(NSString *)type{
    for (NSMutableDictionary *list in @[self.layoutInfo[kJxCalendarDayLayoutWholeDay], self.layoutInfo[kJxCalendarDayLayoutCells]]) {
        for (UICollectionViewLayoutAttributes *attributes in [list allValues]) {
            
            CGRect newRect = CGRectMake(rect.origin.x + (rect.size.width * [self overlapingEventsIndicator]),
                                        rect.origin.y,
                                        rect.size.width * [self overlapingEventsIndicator],
                                        rect.size.height);
            
//            NSLog(@"rect 1: %f x %f size %f x %f", attributes.frame.origin.x, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height);
//            NSLog(@"rect 2: %f x %f size %f x %f\n", newRect.origin.x, newRect.origin.y, newRect.size.width, newRect.size.height);
//
            if (CGRectIntersectsRect(attributes.frame,newRect)) {
                return NO;
            }
        }
    }
    
    return YES;
}
@end
