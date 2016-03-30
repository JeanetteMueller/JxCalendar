//
//  JxCalendarLayoutWeek.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutWeek.h"
#import "JxCalendarWeek.h"
#import "JxCalendarEvent.h"
#import "JxCalendarEventDuration.h"
#import "JxCalendarEventDay.h"


@interface JxCalendarLayoutWeek ()

@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation JxCalendarLayoutWeek



- (id)initWithSize:(CGSize)size{
    self = [self init];
    if (self) {
        
        CGFloat borders = 0;
        
        self.minimumLineSpacing = 1.0f;
        self.minimumInteritemSpacing = borders;
        
    
        CGFloat maxWidth = floor(size.width /7)-self.minimumInteritemSpacing;
        self.itemSize = CGSizeMake(maxWidth-1, 64);
        self.headerReferenceSize = CGSizeMake(maxWidth, 64.0f);
        
        
        
        self.sectionInset = UIEdgeInsetsZero;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
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
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *wholeDayLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary];
    
    newLayoutInfo[kJxCalendarWeekLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarWeekLayoutWholeDay] = wholeDayLayoutInfo;
    newLayoutInfo[kJxCalendarWeekLayoutHeader] = headerLayoutInfo;
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;

    for (NSInteger section = 0; section < sectionCount; section++) {
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        itemAttributes.frame = [self frameForHeaderAtSection:indexPath.section];
        itemAttributes.zIndex = 20;
        headerLayoutInfo[indexPath] = itemAttributes;
        
        
        
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            NSDate *thisDate = [self.source getDateForSection:indexPath.section];
            
            itemAttributes.frame = CGRectZero;
            
            
            if (thisDate) {
                
                NSArray *events = [self.source.dataSource eventsAt:thisDate];
                
                if (events.count > indexPath.item) {
                    
                    JxCalendarEvent *e = [events objectAtIndex:indexPath.item];
                    
                    if ([e isKindOfClass:[JxCalendarEventDay class]]) {
                        itemAttributes.frame = [self frameForDayEvent:(JxCalendarEventDay *)e atIndexPath:indexPath];
                        wholeDayLayoutInfo[indexPath] = itemAttributes;
                        itemAttributes.zIndex = 10;
                    }else if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
                        itemAttributes.frame = [self frameForDurationEvent:(JxCalendarEventDuration *)e atIndexPath:indexPath];
                        cellLayoutInfo[indexPath] = itemAttributes;
                        itemAttributes.zIndex = 0;
                    }
                }
            }
            
            
            
            
            newLayoutInfo[kJxCalendarWeekLayoutCells] = cellLayoutInfo;
            newLayoutInfo[kJxCalendarWeekLayoutWholeDay] = wholeDayLayoutInfo;
            newLayoutInfo[kJxCalendarWeekLayoutHeader] = headerLayoutInfo;
            
            self.layoutInfo = newLayoutInfo;
        }
        
        
        
    }
    
    newLayoutInfo[kJxCalendarWeekLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarWeekLayoutWholeDay] = wholeDayLayoutInfo;
    newLayoutInfo[kJxCalendarWeekLayoutHeader] = headerLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
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

- (CGSize)collectionViewContentSize{

    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    double pages = ceil(numOfSections / 7);
    
    CGSize contentSize = CGSizeMake(pages * self.collectionView.frame.size.width,
                                    self.headerReferenceSize.height + self.minimumLineSpacing + (3*(kCalendarLayoutWholeDayHeight+self.minimumLineSpacing)) + 24.5* (60*kCalendarLayoutDaySectionHeightMultiplier));

    return contentSize;
    
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attr = self.layoutInfo[kJxCalendarWeekLayoutCells][indexPath];
    
    if (!attr) {
        attr = self.layoutInfo[kJxCalendarWeekLayoutWholeDay][indexPath];
    }
    return attr;
}


- (CGRect)frameForDayEvent:(JxCalendarEventDay *)event atIndexPath:(NSIndexPath *)indexPath{

    CGFloat x, y, width, height;
    
    x = (self.collectionView.frame.size.width * floor(indexPath.section / 7)) + ((indexPath.section % 7) * (self.headerReferenceSize.width+self.minimumInteritemSpacing));
    y = self.collectionView.contentOffset.y+ self.headerReferenceSize.height + self.minimumLineSpacing;
    width = self.itemSize.width;
    height = kCalendarLayoutWholeDayHeight;
    
    CGRect newRect = CGRectMake(x,
                                y,
                                width,
                                height);
    
    int count = 0;
    while (![self checkIfRectIsAvailable:newRect forType:kJxCalendarWeekLayoutWholeDay]){
        
        newRect.origin.y = newRect.origin.y + kCalendarLayoutWholeDayHeight + self.minimumLineSpacing;
        count++;
    }
    if (count < 3) {
        return newRect;
    }
    return CGRectZero;
}
- (CGRect)frameForDurationEvent:(JxCalendarEventDuration *)event atIndexPath:(NSIndexPath *)indexPath{
    
    NSDateComponents *startComponents = [[self.source.dataSource calendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:event.start];
    CGFloat x = (self.collectionView.frame.size.width * floor(indexPath.section / 7)) + ((indexPath.section % 7) * (self.headerReferenceSize.width+self.minimumInteritemSpacing));
    
    CGRect newRect = CGRectMake(x,
                                self.headerReferenceSize.height + self.minimumLineSpacing + (3*(kCalendarLayoutWholeDayHeight+self.minimumLineSpacing)) + self.minimumLineSpacing + (startComponents.hour * (60*kCalendarLayoutDaySectionHeightMultiplier) + startComponents.minute*kCalendarLayoutDaySectionHeightMultiplier),
                                20,
                                (event.duration/60)*kCalendarLayoutDaySectionHeightMultiplier - (2*self.minimumInteritemSpacing));
    
    while (![self checkIfRectIsAvailable:newRect forType:kJxCalendarWeekLayoutCells]){
        
        newRect.origin.x = newRect.origin.x + newRect.size.width + self.minimumInteritemSpacing;
    }
    
    if (newRect.origin.x+newRect.size.width > (indexPath.section * (self.headerReferenceSize.width+self.minimumInteritemSpacing))+(self.headerReferenceSize.width+self.minimumInteritemSpacing)) {
        return CGRectZero;
    }
    
    return newRect;
}
- (BOOL)checkIfRectIsAvailable:(CGRect)rect forType:(NSString *)type{
    
    if (self.layoutInfo) {
        for (UICollectionViewLayoutAttributes *attributes in [self.layoutInfo[type] allValues]) {
            
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return self.layoutInfo[kJxCalendarWeekLayoutHeader][indexPath];
}

- (CGRect)frameForHeaderAtSection:(NSInteger)section{
    
    CGFloat x = (self.collectionView.frame.size.width * floor(section / 7)) + ((section % 7) * (self.headerReferenceSize.width+self.minimumInteritemSpacing));

    return CGRectMake(x, //section * (self.headerReferenceSize.width + self.minimumInteritemSpacing),
                      self.collectionView.contentOffset.y,
                      self.headerReferenceSize.width,
                      self.headerReferenceSize.height);

}

#pragma mark sticky Headers
- (CGFloat)pageWidth {
    return self.collectionView.frame.size.width;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
    }
    
    return proposedContentOffset;
}
- (CGFloat)flickVelocity {
    return 0.3;
}


//- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
//    return YES;
//}
@end
