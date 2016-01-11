//
//  JxCalendarLayoutGrid.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutMonthGrid.h"
#import "JxCalendarDefinitions.h"


@interface JxCalendarLayoutMonthGrid ()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@end

@implementation JxCalendarLayoutMonthGrid


- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size
{
    self = [self init];
    if (self) {
        self.headerReferenceSize = CGSizeMake(size.width, 64.0f);
        
        CGFloat border = 3.;
        CGFloat maxWidth = floor((size.width - border * 6) / 7.);
        self.itemSize = CGSizeMake(maxWidth, maxWidth);
        self.minimumLineSpacing = (size.width - (maxWidth * 7.)) / 6.;
        self.minimumInteritemSpacing = self.minimumLineSpacing;
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.headerReferenceSize = CGSizeMake(320.0f, 64.0f);
        self.itemSize = CGSizeMake(44.0f, 44.0f);
        self.minimumLineSpacing = 2.0f;
        self.minimumInteritemSpacing = 2.0f;
    }
    
    return self;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary];
    
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
            cellLayoutInfo[indexPath] = itemAttributes;
            previousIndexPath = indexPath;
        }
    }
    
    newLayoutInfo[kJxCalendarMonthLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarMonthLayoutHeader] = headerLayoutInfo;
    
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

    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    NSIndexPath *lastHeaderIndexPath = [NSIndexPath indexPathForRow:0 inSection:numOfSections-1];
    UICollectionViewLayoutAttributes *lastLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:lastHeaderIndexPath];
    
    NSInteger numberOfCellsInDecember = [self.collectionView numberOfItemsInSection:numOfSections-1];
    NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:numberOfCellsInDecember-1 inSection:numOfSections-1];
    UICollectionViewLayoutAttributes *lastCellAttributes = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
    
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(lastLayoutAttributes.frame), CGRectGetMaxY(lastCellAttributes.frame) + self.minimumLineSpacing);
    
    return contentSize;
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.layoutInfo[kJxCalendarMonthLayoutCells][indexPath];
}


- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(0.0f, self.headerReferenceSize.height + self.minimumLineSpacing, self.itemSize.width, self.itemSize.height);
        }else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = theoricalRect.origin.x + self.minimumInteritemSpacing + self.itemSize.width;
            if ((indexPath.section - previousIndexPath.section) > 0) {
                theoricalRect.origin.y = theoricalRect.origin.y + self.itemSize.height + self.headerReferenceSize.height + self.minimumLineSpacing;
                theoricalRect.origin.x = 0.0f;
            }else if ((theoricalRect.origin.x + self.itemSize.width) > self.collectionView.frame.size.width) {
                theoricalRect.origin.x = 0.0f;
                theoricalRect.origin.y = theoricalRect.origin.y + self.minimumLineSpacing + self.itemSize.height;
            }
            return theoricalRect;
        }
    }
    else {
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(0.0f, self.headerReferenceSize.height + self.minimumLineSpacing, self.itemSize.width, self.itemSize.height);
        }
        else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = theoricalRect.origin.x + self.minimumInteritemSpacing + self.itemSize.width;
            if ((theoricalRect.origin.x + self.itemSize.width) > self.collectionView.frame.size.width * (indexPath.section+1)) {
                theoricalRect.origin.x =  self.collectionView.frame.size.width * indexPath.section;
                theoricalRect.origin.y = theoricalRect.origin.y + self.minimumLineSpacing + self.itemSize.height;
            }
            if ((indexPath.section - previousIndexPath.section) > 0) {
                theoricalRect.origin.x = self.collectionView.frame.size.width * indexPath.section;
                theoricalRect.origin.y = self.headerReferenceSize.height + self.minimumLineSpacing;
            }
            return theoricalRect;
        }
    }
    
    return CGRectZero;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kJxCalendarMonthLayoutHeader][indexPath];
}

- (CGRect)frameForHeaderAtSection:(NSInteger)section previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(0.0f, 0.0f, self.headerReferenceSize.width, self.headerReferenceSize.height);
        }
        else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = 0.0f;
            theoricalRect.origin.y = theoricalRect.origin.y + self.itemSize.height + self.minimumLineSpacing;
            theoricalRect.size.width = self.headerReferenceSize.width;
            theoricalRect.size.height = self.headerReferenceSize.height;
            return theoricalRect;
        }
    }
    else {
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(0.0f, 0.0f, self.headerReferenceSize.width, self.headerReferenceSize.height);
        }
        else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = section * self.headerReferenceSize.width;
            theoricalRect.origin.y = 0.0f;
            theoricalRect.size.width = self.headerReferenceSize.width;
            theoricalRect.size.height = self.headerReferenceSize.height;
            return theoricalRect;
        }
    }
    
    return CGRectZero;
}
@end
