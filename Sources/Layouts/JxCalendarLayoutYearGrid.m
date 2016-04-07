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

@property (assign, nonatomic, readwrite) CGSize startSize;

@end

@implementation JxCalendarLayoutYearGrid

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size{
    self = [self init];
    
    if (self) {
        self.startSize = size;
        
        CGFloat borders = .0f;
        
        self.sectionInset = UIEdgeInsetsMake(3, 3, 0, 3);
        
        self.headerReferenceSize = CGSizeMake(size.width/3 - self.sectionInset.left-self.sectionInset.right,
                                              40);
        
        self.minimumInteritemSpacing = borders;
        self.minimumLineSpacing = borders;
        CGFloat itemwidth = floor((self.headerReferenceSize.width - 6*self.minimumInteritemSpacing)  / 7);
        
        self.itemSize = CGSizeMake(itemwidth, itemwidth);
        
        self.footerReferenceSize = CGSizeZero;
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
    }
    
    return self;
}

#pragma mark - Layout

- (CGSize)sizeOfOneMonth{
    
    return CGSizeMake(self.headerReferenceSize.width,
                      self.headerReferenceSize.height + self.minimumLineSpacing + ((self.itemSize.height+self.minimumLineSpacing)*6 ) + self.minimumLineSpacing);
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSArray *attr = [super layoutAttributesForElementsInRect:rect];
    if (attr) {
        return attr;
    }
    
    CGPoint origin = rect.origin;

    CGRect area = CGRectMake(origin.x, origin.y-(rect.size.height/2), rect.size.width, rect.size.height*rect.size.height);
    
    
    NSMutableArray *allAttributes = [NSMutableArray array];

    NSInteger section = floor(origin.y / ([self sizeOfOneMonth].height + self.sectionInset.top + self.sectionInset.bottom));

    section = section*3;
    
    for (NSInteger s = section-3; s <= section+29; s++) {
        if (s >= 0 && s < [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView]) {
            
            BOOL intersect = NO;
            
            NSMutableArray *sectionAttributes = [NSMutableArray array];
            
            
            UICollectionViewLayoutAttributes *headerAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                atIndexPath:[NSIndexPath indexPathForItem:0 inSection:s]];
            
            [sectionAttributes addObject:headerAttr];
            
            if (CGRectIntersectsRect(area, headerAttr.frame) ) {
                intersect = YES;
            }
            
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:s];
            
            for (NSInteger item = 0; item < itemCount; item++) {
                
                NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:s];
                
                UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:path];
                [sectionAttributes addObject:itemAttributes];
                
                if (CGRectIntersectsRect(area, itemAttributes.frame) ) {
                    intersect = YES;
                }
            }
            
            if (intersect) {
                [allAttributes addObjectsFromArray:sectionAttributes];
            }
            
        }
    }
    
    [self.layouts setObject:allAttributes forKey:[NSString stringWithFormat:@"%fx%f", origin.x, origin.y]];
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize{
    
    if (self.contentSize.width > 0 && self.contentSize.height > 0) {
        return self.contentSize;
    }
    
    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    NSIndexPath *lastHeaderIndexPath = [NSIndexPath indexPathForRow:0 inSection:numOfSections-1];
    UICollectionViewLayoutAttributes *lastLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:lastHeaderIndexPath];
    
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(lastLayoutAttributes.frame),
                                    lastLayoutAttributes.frame.origin.y + [self sizeOfOneMonth].height);
    
    if (contentSize.height < self.collectionView.frame.size.height) {
        contentSize.height = self.collectionView.frame.size.height+1;
    }
    self.contentSize = contentSize;
    return contentSize;
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes *itemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    if (itemAttributes) {
        return itemAttributes;
    }
    itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat unschaerfe = (self.headerReferenceSize.width - (self.itemSize.width*7 + self.minimumInteritemSpacing*6)) /2;
    
    CGFloat abstandVonLinksSection = (indexPath.section %3) * ([self sizeOfOneMonth].width+self.sectionInset.left+self.sectionInset.right);
    
    CGFloat abstandVonObenSection = floor(indexPath.section/3) * ([self sizeOfOneMonth].height+self.sectionInset.top + self.sectionInset.bottom);
    
    itemAttributes.frame = CGRectMake(abstandVonLinksSection + self.sectionInset.left + ((indexPath.item % 7) * self.itemSize.width) + unschaerfe,
                                      
                                      abstandVonObenSection + self.sectionInset.top + self.headerReferenceSize.height + self.minimumLineSpacing + (floor(indexPath.item/7)*(self.itemSize.height+self.minimumLineSpacing)),
                                      
                                      self.itemSize.width,
                                      self.itemSize.height);
    
    [self.cachedItemAttributes setObject:itemAttributes forKey:indexPath];
    
    return itemAttributes;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *itemAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if (itemAttributes) {
        return itemAttributes;
    }
    
    itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    itemAttributes.frame = CGRectMake((indexPath.section %3) * ([self sizeOfOneMonth].width+self.sectionInset.left+self.sectionInset.right) + self.sectionInset.left,
                                      floor(indexPath.section /3)*([self sizeOfOneMonth].height + self.sectionInset.top + self.sectionInset.bottom)+self.sectionInset.top,
                                      self.headerReferenceSize.width,
                                      self.headerReferenceSize.height);
    
    [self.cachedHeadlineAttributes setObject:itemAttributes forKey:indexPath];
    return itemAttributes;
}

@end
