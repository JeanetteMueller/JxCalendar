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
        CGFloat itemwidth = (self.headerReferenceSize.width - (itemsPerRow-1)*self.minimumInteritemSpacing)  / itemsPerRow;
        
        self.itemSize = CGSizeMake(itemwidth,
                                   itemwidth);
        
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
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
    NSMutableArray *allAttributes = [NSMutableArray array];

    CGFloat origin = rect.origin.y;
    NSInteger section = floor(origin / ([self sizeOfOneMonth].height + self.sectionInset.top + self.sectionInset.bottom));

    section = section*3;
    
    for (NSInteger s = section-3; s <= section+29; s++) {
        if (s >= 0 && s < [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView]) {
            [allAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:s]]];
            
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:s];
            
            for (NSInteger item = 0; item < itemCount; item++) {
                
                NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:s];
                
                UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:path];
                [allAttributes addObject:itemAttributes];
                
            }
        }
    }
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize{

    NSInteger numOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    NSIndexPath *lastHeaderIndexPath = [NSIndexPath indexPathForRow:0 inSection:numOfSections-1];
    UICollectionViewLayoutAttributes *lastLayoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:lastHeaderIndexPath];
    
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(lastLayoutAttributes.frame),
                                    lastLayoutAttributes.frame.origin.y + [self sizeOfOneMonth].height);
    
    if (contentSize.height < self.collectionView.frame.size.height) {
        contentSize.height = self.collectionView.frame.size.height+1;
    }
    return contentSize;
}

#pragma mark - Cells Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    itemAttributes.frame = CGRectMake(((indexPath.section %3)* ([self sizeOfOneMonth].width+self.sectionInset.left+self.sectionInset.right)) + self.sectionInset.left + ((indexPath.item % 7) * self.itemSize.width),
                                      
                                      (floor(indexPath.section/3)*([self sizeOfOneMonth].height+self.sectionInset.top + self.sectionInset.bottom)+self.sectionInset.top) + self.headerReferenceSize.height + self.minimumLineSpacing + (floor(indexPath.item/7)*(self.itemSize.height+self.minimumLineSpacing)),
                                      
                                      self.itemSize.width,
                                      self.itemSize.height);
    
    return itemAttributes;
}

#pragma mark - Headers Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    itemAttributes.frame = CGRectMake((indexPath.section %3) * ([self sizeOfOneMonth].width+self.sectionInset.left+self.sectionInset.right) + self.sectionInset.left, floor(indexPath.section /3)*([self sizeOfOneMonth].height + self.sectionInset.top + self.sectionInset.bottom)+self.sectionInset.top, self.headerReferenceSize.width, self.headerReferenceSize.height);
    
    return itemAttributes;
}

@end
