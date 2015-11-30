//
//  JxCalendarLayoutDay.m
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutDay.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarEvent.h"



#define kSectionHeight 120
#define kHeaderHeight 49
#define kHeaderHalfHeight 24
#define kHeaderTextWidth 65

@interface JxCalendarLayoutDay ()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *events;
@end

@implementation JxCalendarLayoutDay

- (id)initWithWidth:(CGFloat)width andEvents:(NSArray *)events
{
    self = [self init];
    if (self) {
        
        self.events = events;
        
        self.headerReferenceSize = CGSizeMake(width, kHeaderHeight);
        self.minimumInteritemSpacing = 5;

        
        CGFloat maxWidth = floor((width-kHeaderTextWidth) / 3.5) - self.minimumInteritemSpacing;
        self.itemSize = CGSizeMake(maxWidth, kSectionHeight);
        self.minimumLineSpacing = 0;
        
    }
    return self;
}


- (instancetype)init
{
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
- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.layoutInfo) {
        return;
    }
    NSLog(@"prepareLayout");
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary];
    
    newLayoutInfo[kJxCalendarDayLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarDayLayoutHeader] = headerLayoutInfo;
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;
    CGRect previousRect = CGRectZero;
    NSIndexPath *previousIndexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        itemAttributes.frame = [self frameForHeaderAtSection:indexPath.section previousRect:previousRect previousIndexPath:previousIndexPath];
        
        headerLayoutInfo[indexPath] = itemAttributes;
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForItemAtIndexPath:indexPath previousRect:previousRect previousIndexPath:previousIndexPath];
            previousRect = itemAttributes.frame;
            //JMOLog(@"indexPath(%@) -> %@",indexPath, NSStringFromCGRect(previousRect));
            cellLayoutInfo[indexPath] = itemAttributes;
            previousIndexPath = indexPath;

            newLayoutInfo[kJxCalendarDayLayoutCells] = cellLayoutInfo;
            newLayoutInfo[kJxCalendarDayLayoutHeader] = headerLayoutInfo;
            
            self.layoutInfo = newLayoutInfo;
        }
        previousRect = CGRectZero;
    }
    
    newLayoutInfo[kJxCalendarDayLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarDayLayoutHeader] = headerLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize
{
    NSLog(@"collectionViewContentSize");
    
    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];

    CGFloat maxWidth = self.collectionView.frame.size.width;
    
    if (!self.layoutInfo) {
        [self prepareLayout];
        
    }
    for (UICollectionViewLayoutAttributes *attributes in [self.layoutInfo[kJxCalendarDayLayoutCells] allValues]) {
        
        if (attributes.frame.origin.x + attributes.frame.size.width > maxWidth) {
            maxWidth = attributes.frame.origin.x + attributes.frame.size.width;
        }
    }
    
    for (UICollectionViewLayoutAttributes *attributes in [self.layoutInfo[kJxCalendarDayLayoutHeader] allValues]) {
        CGRect frame = attributes.frame;
        
        frame.size.width = maxWidth;
        
        attributes.frame = frame;
    }
    
    CGSize contentSize = CGSizeMake(maxWidth,
                                    numOfSections * kSectionHeight - kSectionHeight + kHeaderHeight);
    
    return contentSize;
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kJxCalendarDayLayoutCells][indexPath];
}


- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath
{
    
    JxCalendarEvent *event;
    
    if (_events.count > indexPath.section) {
        NSArray *eventsOfThisHour = [_events objectAtIndex:indexPath.section];
        NSLog(@"eventsOfThisHour %@", eventsOfThisHour);
        
        if (eventsOfThisHour.count > indexPath.item) {
            event = [eventsOfThisHour objectAtIndex:indexPath.item];
        }
    }
    

    CGFloat itemHeight = event.duration*2;
    
    if (itemHeight < kSectionHeight/3) {
        itemHeight = kSectionHeight/3;
    }
    
    if (CGRectEqualToRect(CGRectZero, previousRect)) {
        
        CGRect theoricalRect = CGRectMake(kHeaderTextWidth,
                                          (indexPath.section * kSectionHeight)+ self.headerReferenceSize.height- kHeaderHalfHeight +self.minimumInteritemSpacing,
                                          self.itemSize.width,
                                          itemHeight);
        
        while (![self checkIfRectIsAvailable:theoricalRect]){
            theoricalRect.origin.x = theoricalRect.origin.x + self.itemSize.width+ self.minimumInteritemSpacing;
        }

        return theoricalRect;
    }
    else {
        
        CGRect theoricalRect = previousRect;
        
            theoricalRect.origin.x = theoricalRect.origin.x + self.itemSize.width + self.minimumInteritemSpacing;
            theoricalRect.origin.y = (indexPath.section * kSectionHeight) + self.headerReferenceSize.height- kHeaderHalfHeight + self.minimumInteritemSpacing;
            theoricalRect.size.height = itemHeight;
            
        
        while (![self checkIfRectIsAvailable:theoricalRect]){
            theoricalRect.origin.x = theoricalRect.origin.x + self.itemSize.width + self.minimumInteritemSpacing;
        }
        
        return theoricalRect;
    }
    
    
    return CGRectZero;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kJxCalendarDayLayoutHeader][indexPath];
}

- (CGRect)frameForHeaderAtSection:(NSInteger)section previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath
{
    
    CGRect theoricalRect = previousRect;
    theoricalRect.origin.x = 0.0f;
    theoricalRect.origin.y = section * kSectionHeight;
    theoricalRect.size.width = self.headerReferenceSize.width;
    theoricalRect.size.height = self.headerReferenceSize.height;
    return theoricalRect;
    
    
    return CGRectZero;
}
- (BOOL)checkIfRectIsAvailable:(CGRect)rect{
    
    NSLog(@"rect %f x %f size %f x %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    if (self.layoutInfo) {
        for (UICollectionViewLayoutAttributes *attributes in [self.layoutInfo[kJxCalendarDayLayoutCells] allValues]) {
            
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                return NO;
            }
            
        }
    }
    
    
    return YES;
}
@end
