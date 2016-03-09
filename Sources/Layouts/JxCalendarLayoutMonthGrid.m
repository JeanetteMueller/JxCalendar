//
//  JxCalendarLayoutGrid.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutMonthGrid.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"
#import "JxCalendarWeekDayDecoration.h"


@interface JxCalendarLayoutMonthGrid ()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, readwrite) CGFloat decorationHeight;
@end

@implementation JxCalendarLayoutMonthGrid


- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size
{
    self = [self init];
    if (self) {
        self.headerReferenceSize = CGSizeMake(size.width, 64.0f);
        
        CGFloat border = 0.;
        CGFloat maxWidth = floor((size.width - border * 6) / 7.);
        self.itemSize = CGSizeMake(maxWidth, maxWidth);
        self.minimumLineSpacing = floor((size.width - (maxWidth * 7.)) / 6.);
        self.minimumInteritemSpacing = self.minimumLineSpacing;
        
        self.decorationHeight = 26;
        self.renderWeekDayLabels = vc.renderWeekDayLabels;

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
        
        NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
        NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
        
        [self registerClass:[JxCalendarWeekDayDecoration class] forDecorationViewOfKind:@"JxCalendarWeekDayDecoration"];
        [self registerNib:[UINib nibWithNibName:@"JxCalendarWeekDayDecoration" bundle:bundle] forDecorationViewOfKind:@"JxCalendarWeekDayDecoration"];
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
    NSMutableDictionary *decorationLayoutInfo = [NSMutableDictionary dictionary];
    
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
            
            cellLayoutInfo[indexPath] = itemAttributes;
            
            UICollectionViewLayoutAttributes *deco = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"JxCalendarWeekDayDecoration" withIndexPath:indexPath];
            
            deco.frame = [self frameForDecorationAtIndexPath:indexPath itemRect:itemAttributes.frame];
            
            if (!CGRectEqualToRect(deco.frame, CGRectZero)) {
                decorationLayoutInfo[indexPath] = deco;
            }
            
            previousRect = itemAttributes.frame;
            previousIndexPath = indexPath;
        }
    }
    
    newLayoutInfo[kJxCalendarMonthLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarMonthLayoutHeader] = headerLayoutInfo;
    newLayoutInfo[kJxCalendarMonthLayoutDecoration] = decorationLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
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


- (CGRect)frameForDecorationAtIndexPath:(NSIndexPath *)indexPath itemRect:(CGRect)itemRect{
    
    if (indexPath.item >= 7 || !self.renderWeekDayLabels) {
        return CGRectZero;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        

        CGRect theoricalRect = CGRectMake(itemRect.origin.x, itemRect.origin.y - self.decorationHeight - self.minimumLineSpacing, itemRect.size.width, self.decorationHeight);
        
        
        return theoricalRect;
        
    }
    else {
//        if (CGRectEqualToRect(CGRectZero, previousRect)) {
//            return CGRectMake(0.0f, self.headerReferenceSize.height + self.minimumLineSpacing, self.itemSize.width, self.itemSize.height);
//        }
//        else {
//            CGRect theoricalRect = previousRect;
//            theoricalRect.origin.x = theoricalRect.origin.x + self.minimumInteritemSpacing + self.itemSize.width;
//            if ((theoricalRect.origin.x + self.itemSize.width) > self.collectionView.frame.size.width * (indexPath.section+1)) {
//                theoricalRect.origin.x =  self.collectionView.frame.size.width * indexPath.section;
//                theoricalRect.origin.y = theoricalRect.origin.y + self.minimumLineSpacing + self.itemSize.height;
//            }
//            if ((indexPath.section - previousIndexPath.section) > 0) {
//                theoricalRect.origin.x = self.collectionView.frame.size.width * indexPath.section;
//                theoricalRect.origin.y = self.headerReferenceSize.height + self.minimumLineSpacing;
//            }
//            return theoricalRect;
//        }
    }
    
    return CGRectZero;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        
        CGFloat extraPaddingTopForWeekDayLabels = 0.0f;
        
        if (indexPath.item < 7 && self.renderWeekDayLabels) {
            extraPaddingTopForWeekDayLabels = self.decorationHeight + self.minimumLineSpacing;
        }
        
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(0.0f, self.headerReferenceSize.height + self.minimumLineSpacing + extraPaddingTopForWeekDayLabels, self.itemSize.width, self.itemSize.height);
        }else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = theoricalRect.origin.x + self.minimumInteritemSpacing + self.itemSize.width;
            if ((indexPath.section - previousIndexPath.section) > 0) {
                theoricalRect.origin.y = theoricalRect.origin.y + self.itemSize.height + self.headerReferenceSize.height + self.minimumLineSpacing + extraPaddingTopForWeekDayLabels;
                theoricalRect.origin.x = 0.0f;
            }else if ((theoricalRect.origin.x + self.itemSize.width) > self.collectionView.frame.size.width) {
                theoricalRect.origin.x = 0.0f;
                theoricalRect.origin.y = theoricalRect.origin.y + self.minimumLineSpacing + self.itemSize.height + extraPaddingTopForWeekDayLabels;
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
