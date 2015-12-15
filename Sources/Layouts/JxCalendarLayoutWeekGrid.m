//
//  JxCalendarLayoutGrid.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutWeekGrid.h"

@implementation JxCalendarLayoutWeekGrid

- (id)initWithViewController:(JxCalendarViewController *)vc andSize:(CGSize)size{
    self = [super init];
    
    if (self) {
        
        [self setNewSize:size];
        
        
        
        CGFloat borders = 1.0f;
        
        self.sectionInset = UIEdgeInsetsZero;
        
        
        //self.sectionInset = UIEdgeInsetsMake(borders, borders, 20, borders);
    
//        CGFloat itemwidth = size.width - (2*borders);
//        CGFloat itemheight = 50;
//        
//        itemwidth = self.size.width/7;
//        itemheight = self.size.height-10;// [[UIScreen mainScreen] bounds].size.height;
        
        //self.itemSize = CGSizeMake(self.size.width/7, self.size.height);
        self.minimumInteritemSpacing = borders;
        self.minimumLineSpacing = borders;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.headerReferenceSize = CGSizeZero;
        
    }
    return self;
}
- (CGSize)itemSize{
    
    return CGSizeMake(ceilf(self.size.width/7)-1, self.size.height);
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame = itemAttributes.frame;
    
    frame.size = CGSizeMake(self.size.width/7, self.size.height);
    
    itemAttributes.frame = frame;
    
    //NSLog(@"itemAttributes %@", itemAttributes);
    
    return itemAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
//    
//    CGRect frame = itemAttributes.frame;
//    
//    frame.size = CGSizeMake(self.size.width, self.size.height);
//    
//    itemAttributes.frame = frame;
    return itemAttributes;
}
- (CGFloat)pageWidth {
    return (self.itemSize.width+1) * 7;
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
@end
