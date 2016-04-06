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

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    CGFloat origin = rect.origin.y;
    
    if ([self.layouts objectForKey:[NSString stringWithFormat:@"%f", origin]]) {
        //NSLog(@"layoutAttributesForElementsInRect");
        return [self.layouts objectForKey:[NSString stringWithFormat:@"%f", origin]];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.cachedItemAttributes objectForKey:indexPath]) {
        //NSLog(@"layoutAttributesForItemAtIndexPath: %ld - %ld", indexPath.section, indexPath.item);
        return [self.cachedItemAttributes objectForKey:indexPath];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([self.cachedHeadlineAttributes objectForKey:indexPath]) {
        //NSLog(@"layoutAttributesForSupplementaryViewOfKind: %@ %ld - %ld", kind, indexPath.section, indexPath.item);
        return [self.cachedHeadlineAttributes objectForKey:indexPath];
    }
    return nil;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    if ([self.cachedDecoAttributes objectForKey:indexPath]) {
        //NSLog(@"layoutAttributesForDecorationViewOfKind: %@ %ld - %ld", elementKind, indexPath.section, indexPath.item);
        return [self.cachedDecoAttributes objectForKey:indexPath];
    }
    return nil;
}
@end
