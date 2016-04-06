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

#define kJxCalendarWeekDayDecoration @"JxCalendarWeekDayDecoration"

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size{
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

- (instancetype)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.headerReferenceSize = CGSizeMake(320.0f, 64.0f);
        self.itemSize = CGSizeMake(44.0f, 44.0f);
        self.minimumLineSpacing = 2.0f;
        self.minimumInteritemSpacing = 2.0f;
        
        NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
        NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
        
        [self registerClass:[JxCalendarWeekDayDecoration class] forDecorationViewOfKind:kJxCalendarWeekDayDecoration];
        [self registerNib:[UINib nibWithNibName:kJxCalendarWeekDayDecoration bundle:bundle] forDecorationViewOfKind:kJxCalendarWeekDayDecoration];
    }
    
    return self;
}

#pragma mark - Layout

- (CGSize)sizeOfOneMonth{
    
    CGFloat extraPaddingTopForWeekDayLabels = 0.0f;
    
    if (self.renderWeekDayLabels) {
        extraPaddingTopForWeekDayLabels = self.decorationHeight + self.minimumLineSpacing;
    }
    return CGSizeMake(self.headerReferenceSize.width,
                      self.headerReferenceSize.height + self.minimumLineSpacing + ((self.itemSize.height+self.minimumLineSpacing)*6 ) + self.minimumLineSpacing + extraPaddingTopForWeekDayLabels);
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *attr = [super layoutAttributesForElementsInRect:rect];
    if (attr) {
        return attr;
    }
    
    NSMutableArray *allAttributes = [NSMutableArray array];
    
    CGFloat origin = rect.origin.y;
    NSInteger section = floor(origin / [self sizeOfOneMonth].height);
    NSInteger range = 3;
    
    for (NSInteger s = section-range; s <= section+range; s++) {
        if (s >= 0 && s < [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView]) {
            [allAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:s]]];
            
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:s];
            
            for (NSInteger item = 0; item < itemCount; item++) {
                
                NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:s];
                
                UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:path];
                [allAttributes addObject:itemAttributes];
                
                UICollectionViewLayoutAttributes *deco = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kJxCalendarWeekDayDecoration withIndexPath:path];
    
                deco.frame = [self frameForDecorationAtIndexPath:path itemRect:itemAttributes.frame];
    
                if (!CGRectEqualToRect(deco.frame, CGRectZero)) {
                    [allAttributes addObject:deco];
                }
            }
        }
    }
    [self.layouts setObject:allAttributes forKey:[NSString stringWithFormat:@"%f", origin]];
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize{
    
    if (self.contentSize.width > 0 && self.contentSize.height > 0) {
        return self.contentSize;
    }
    
    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    NSIndexPath *lastHeaderIndexPath = [NSIndexPath indexPathForRow:0 inSection:numOfSections-1];
    UICollectionViewLayoutAttributes *lastLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:lastHeaderIndexPath];
    
    self.contentSize =  CGSizeMake(CGRectGetMaxX(lastLayoutAttributes.frame), lastLayoutAttributes.frame.origin.y + [self sizeOfOneMonth].height);
    
    return self.contentSize;
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *itemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (itemAttributes) {
        return itemAttributes;
    }
    
    itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGFloat extraPaddingTopForWeekDayLabels = 0.0f;
    
    if (self.renderWeekDayLabels) {
        extraPaddingTopForWeekDayLabels = self.decorationHeight + self.minimumLineSpacing;
    }
    
    itemAttributes.frame = CGRectMake((indexPath.item % 7) * self.itemSize.width,
                              (indexPath.section*[self sizeOfOneMonth].height) + self.headerReferenceSize.height + self.minimumLineSpacing + (floor(indexPath.item/7)*(self.itemSize.height+self.minimumLineSpacing)) + extraPaddingTopForWeekDayLabels,
                              self.itemSize.width,
                              self.itemSize.height);

    [self.cachedItemAttributes setObject:itemAttributes forKey:indexPath];
    return itemAttributes;
}

#pragma mark - Decoration Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *deco = [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
    if (deco) {
        return deco;
    }
    
    deco = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kJxCalendarWeekDayDecoration withIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    deco.frame = [self frameForDecorationAtIndexPath:indexPath itemRect:itemAttributes.frame];
    
    [self.cachedDecoAttributes setObject:deco forKey:indexPath];
    return deco;
}

- (CGRect)frameForDecorationAtIndexPath:(NSIndexPath *)indexPath itemRect:(CGRect)itemRect{
    
    if (indexPath.item >6 || !self.renderWeekDayLabels) {
        return CGRectZero;
    }
    
    return CGRectMake(itemRect.origin.x, itemRect.origin.y - self.decorationHeight - self.minimumLineSpacing, itemRect.size.width, self.decorationHeight);
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *itemAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if (itemAttributes) {
        return itemAttributes;
    }
    
    itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    CGFloat extraPaddingTopForWeekDayLabels = 0.0f;
    
    if (self.renderWeekDayLabels) {
        extraPaddingTopForWeekDayLabels = self.decorationHeight + self.minimumLineSpacing;
    }
    
    itemAttributes.frame = CGRectMake(0,
                                      indexPath.section * (self.headerReferenceSize.height + self.minimumLineSpacing + ((self.itemSize.height+self.minimumLineSpacing)*6 ) + self.minimumLineSpacing + extraPaddingTopForWeekDayLabels),
                                      self.headerReferenceSize.width,
                                      self.headerReferenceSize.height);
    
    [self.cachedHeadlineAttributes setObject:itemAttributes forKey:indexPath];
    return itemAttributes;
}

@end
