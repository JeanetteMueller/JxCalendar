//
//  JxCalendarLayoutOverview.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarLayoutOverview.h"

@implementation JxCalendarLayoutOverview

- (id)initWithViewController:(JxCalendarOverview *)vc andSize:(CGSize)size{
    self = [self init];
    if (self) {
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        
        self.layouts = [[NSCache alloc] init];
        self.cachedItemAttributes = [[NSCache alloc] init];
        self.cachedDecoAttributes = [[NSCache alloc] init];
        self.cachedHeadlineAttributes = [[NSCache alloc] init];
    }
    
    return self;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemSize;
}
- (CGSize)sizeOfOneMonth{
    return CGSizeZero;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    CGPoint origin = rect.origin;
    
    if ([self.layouts objectForKey:[NSString stringWithFormat:@"%fx%f", origin.x, origin.y]]) {
        return [self.layouts objectForKey:[NSString stringWithFormat:@"%fx%f", origin.x, origin.y]];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.cachedItemAttributes objectForKey:indexPath]) {
        return [self.cachedItemAttributes objectForKey:indexPath];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([self.cachedHeadlineAttributes objectForKey:indexPath]) {
        return [self.cachedHeadlineAttributes objectForKey:indexPath];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    if ([self.cachedDecoAttributes objectForKey:indexPath]) {
        return [self.cachedDecoAttributes objectForKey:indexPath];
    }
    return nil;
}
@end
