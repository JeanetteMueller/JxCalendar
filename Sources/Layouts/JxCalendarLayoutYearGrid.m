//
//  JxCalendarLayoutGrid.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutYearGrid.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarProtocols.h"
#import "JxCalendarViewController.h"



@interface JxCalendarLayoutYearGrid ()
@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, readwrite) CGSize startSize;
@end

@implementation JxCalendarLayoutYearGrid

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size{
    self = [super init];
    
    if (self) {
        
        self.startSize = size;
        
        CGFloat itemsPerRow = 7;
        
        CGFloat borders = .0f;
        
        
        self.sectionInset = UIEdgeInsetsMake(3, 3, 0, 3);
        
        self.headerReferenceSize = CGSizeMake(size.width/3 - self.sectionInset.left-self.sectionInset.right,
                                              40);
        
        self.minimumInteritemSpacing = borders;
        self.minimumLineSpacing = borders;
        CGFloat itemwidth = floor((self.headerReferenceSize.width - (itemsPerRow-1)*self.minimumInteritemSpacing)  / itemsPerRow);
        
        self.itemSize = CGSizeMake(itemwidth,
                                   itemwidth);
        
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
        self.footerReferenceSize = CGSizeZero;
        
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
    
    newLayoutInfo[kJxCalendarYearLayoutCells] = cellLayoutInfo;
    newLayoutInfo[kJxCalendarYearLayoutHeader] = headerLayoutInfo;
    
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
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(lastLayoutAttributes.frame),
                                    CGRectGetMaxY(lastLayoutAttributes.frame) + ((self.itemSize.height+self.minimumLineSpacing) * 6 ) + self.sectionInset.bottom);
    
    if (contentSize.height < self.collectionView.frame.size.height) {
        contentSize.height = self.collectionView.frame.size.height;
    }
    return contentSize;

}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kJxCalendarYearLayoutCells][indexPath];
}


- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath
{

    if (CGRectEqualToRect(CGRectZero, previousRect)) {
        return CGRectMake(self.sectionInset.left,
                          self.headerReferenceSize.height + self.minimumLineSpacing + self.sectionInset.top,
                          self.itemSize.width,
                          self.itemSize.height);
    }
    else {
        CGRect theoricalRect = previousRect;
        theoricalRect.origin.x = theoricalRect.origin.x + self.minimumInteritemSpacing + self.itemSize.width;
        if ((indexPath.section - previousIndexPath.section) > 0) {
            theoricalRect.origin.x = self.sectionInset.left + (indexPath.section % 3 * (self.headerReferenceSize.width + self.sectionInset.left + self.sectionInset.right));
            theoricalRect.origin.y = floor(indexPath.section / 3) * ((self.itemSize.height+self.minimumLineSpacing) * 6 + self.headerReferenceSize.height + self.minimumInteritemSpacing + self.sectionInset.bottom) + self.headerReferenceSize.height+self.minimumInteritemSpacing + self.sectionInset.top;
            
        }else if ((theoricalRect.origin.x + self.itemSize.width) > ((indexPath.section % 3 * (self.headerReferenceSize.width + self.sectionInset.left + self.sectionInset.right)) + self.headerReferenceSize.width+self.sectionInset.left+self.minimumInteritemSpacing)) {
            
            theoricalRect.origin.x = self.sectionInset.left + (indexPath.section % 3 * (self.headerReferenceSize.width + self.sectionInset.left + self.sectionInset.right));
            theoricalRect.origin.y = theoricalRect.origin.y + self.minimumLineSpacing + self.itemSize.height ;
        }
        return theoricalRect;
    }

    return CGRectZero;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[kJxCalendarYearLayoutHeader][indexPath];
}

- (CGRect)frameForHeaderAtSection:(NSInteger)section previousRect:(CGRect)previousRect previousIndexPath:(NSIndexPath*)previousIndexPath
{
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (CGRectEqualToRect(CGRectZero, previousRect)) {
            return CGRectMake(self.sectionInset.left, self.sectionInset.top, self.headerReferenceSize.width, self.headerReferenceSize.height);
        }
        else {
            CGRect theoricalRect = previousRect;
            theoricalRect.origin.x = self.sectionInset.left+ (section % 3 * (self.headerReferenceSize.width + self.sectionInset.left +self.sectionInset.right));
            
            theoricalRect.origin.y = floor(section / 3) * ((self.itemSize.height+self.minimumLineSpacing) * 6 + self.headerReferenceSize.height + self.minimumInteritemSpacing + self.sectionInset.bottom)+ self.sectionInset.top ;//
            //theoricalRect.origin.y = (theoricalRect.origin.y + self.itemSize.height + self.minimumLineSpacing);
            
            
            theoricalRect.size.width = self.headerReferenceSize.width;
            theoricalRect.size.height = self.headerReferenceSize.height;
            return theoricalRect;
        }
    }
    else {
//        if (CGRectEqualToRect(CGRectZero, previousRect)) {
//            return CGRectMake(self.sectionInset.left, self.sectionInset.top, self.headerReferenceSize.width, self.headerReferenceSize.height);
//        }
//        else {
//            CGRect theoricalRect = previousRect;
//            theoricalRect.origin.x = section * self.headerReferenceSize.width;
//            theoricalRect.origin.y = 0.0f;
//            theoricalRect.size.width = self.headerReferenceSize.width;
//            theoricalRect.size.height = self.headerReferenceSize.height;
//            return theoricalRect;
//        }
    }
    
    return CGRectZero;
}
/*
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    
    if (attributes) {
        return [self applyLayoutAttributes:attributes.copy];
    }
    return nil;
}
- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttrs = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attr in attrs) {
        [newAttrs addObject:[self applyLayoutAttributes:attr.copy]];
    }
    return newAttrs;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *attrs = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (attrs){
        return [self applyLayoutAttributes:attrs.copy];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes{
    
    CGFloat sectionWidth = self.headerReferenceSize.width+self.minimumInteritemSpacing;
    
    if (attributes.representedElementKind != nil) {
        //header oder footer
        NSInteger section = attributes.indexPath.section;
        
        CGFloat row = self.itemSize.height;
        
        while (section >= 3) {
            section = section -3;
            
            row += (self.itemSize.height*9) + self.headerReferenceSize.height + self.footerReferenceSize.height;
        }
        
        CGFloat xPageOffset = (CGFloat)section * (sectionWidth+self.sectionInset.left+self.sectionInset.right) + self.sectionInset.left;
        CGFloat xCellOffset = xPageOffset;
        CGFloat yCellOffset = row;
        
        attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.headerReferenceSize.width, self.headerReferenceSize.height);
    }else if(self.collectionView){
        //zellen
        NSInteger section = attributes.indexPath.section;
        
        CGFloat row = self.itemSize.height;
        
        while (section >= 3) {
            section = section -3;
            
            row += (self.itemSize.height*9) + self.headerReferenceSize.height + self.footerReferenceSize.height;
        }
        
        CGFloat xPageOffset = (CGFloat)section * (sectionWidth+self.sectionInset.left+self.sectionInset.right) +self.sectionInset.left;
        CGFloat xCellOffset = xPageOffset + ((CGFloat)(attributes.indexPath.item % 7) * self.itemSize.width);
        CGFloat yCellOffset = self.headerReferenceSize.height + row +  (attributes.indexPath.item / 7 * self.itemSize.height);
        
        attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width-self.minimumInteritemSpacing, self.itemSize.height-self.minimumLineSpacing);
        
    }else{
        NSLog(@"no collection view");
    }
    return attributes;
}
*/
@end
