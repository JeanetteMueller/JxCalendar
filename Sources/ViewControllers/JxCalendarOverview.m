//
//  JxCalender.m
//  JxCalendar
//
//  Created by Jeanette Müller on 30.09.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarOverview.h"
#import "JxCalendarLayoutYearGrid.h"
#import "JxCalendarLayoutMonthGrid.h"
#import "JxCalendarLayoutWeekGrid.h"
#import "JxCalendarLayoutWeek.h"

#import "JxCalendarHeader.h"
#import "JxCalendarCell.h"

#import "JxCalendarDay.h"
#import "JxCalendarLayoutDay.h"
#import "JxCalendarBasics.h"
#import "JxCalendarWeek.h"

@interface JxCalendarOverview ()


@property (nonatomic, readwrite) NSInteger startYear;
@end

@implementation JxCalendarOverview

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andStyle:(JxCalendarStyle)style andSize:(CGSize)size{
    
    UICollectionViewLayout *layout;
    switch (style) {
        case JxCalendarStyleYearGrid:
            layout = [[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size];
            break;
        case JxCalendarStyleMonthGrid:
            layout = [[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size];
            break;
    }
    
    self = [super initWithCollectionViewLayout:layout];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self) {
        self.style = style;
        self.dataSource = dataSource;
    }
    return self;
}
- (NSCalendar *)calendar{
    return [self.dataSource calendar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_startYear) {
        self.startYear = 2015;
    }
    //self.dataSource = [[TestCalendarDataSource alloc] init];
    
    if (!self.dataSource) {
        NSLog(@"cant find a DataSource");
        abort();
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];

    // Register cell classes
    [self.collectionView registerClass:[JxCalendarCell class] forCellWithReuseIdentifier:@"JxCalendarCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarCell" bundle:bundle] forCellWithReuseIdentifier:@"JxCalendarCell"];

    [self.collectionView registerClass:[JxCalendarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarHeader" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    
    // Do any additional setup after loading the view.
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self switchToYear:self.startYear];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    NSLog(@"viewWillTransitionToSize %f x %f", size.width, size.height);
    
    
    
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        switch (self.style) {
            case JxCalendarStyleYearGrid:{
                self.collectionView.pagingEnabled = NO;
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size] animated:YES];
                
            }break;
            case JxCalendarStyleMonthGrid:{
                self.collectionView.pagingEnabled = NO;
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size] animated:YES];
                
            }break;

        }
        
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//        
//    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)switchToYear:(NSInteger)year{
    
    self.startYear = year;
    
    if (self.navigationController) {
        self.navigationItem.title = [NSString stringWithFormat:@"%ld", (long)_startYear];
    }
}
- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year{
    
    if (self.startYear != year) {
        
        [self switchToYear:year];

        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            
        } completion:^(BOOL finished) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
            
            NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
            
            UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
            
            [self.collectionView setContentOffset:CGPointMake(0, y) animated:YES];
        }];
        
    }else{
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
        
        NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
        
        CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
        
        [self.collectionView setContentOffset:CGPointMake(0, y) animated:YES];
    }
    
}
- (void)scrollToDate:(NSDate *)date{
    
    NSIndexPath *path = [self getIndexPathForDate:date];
    
    NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
    
    [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 12;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSDate *current = [self getDateForIndexPath:indexPath];
    
    switch (self.style) {
        case JxCalendarStyleYearGrid:{
            JxCalendarLayoutYearGrid *layout = (JxCalendarLayoutYearGrid *)collectionViewLayout;
            
            return [layout sizeForItemAtIndexPath:indexPath];
        }break;
        case JxCalendarStyleMonthGrid:{
            JxCalendarLayoutMonthGrid *layout = (JxCalendarLayoutMonthGrid *)collectionViewLayout;
            
            return [layout sizeForItemAtIndexPath:indexPath];
        }break;

    }

    return CGSizeMake(0,1);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:section+1 inCalendar:[self calendar] andYear:_startYear];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:section+1 inCalendar:[self calendar] andYear:_startYear];
    
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                          fromDate:firstDay];
    
    NSDateComponents *lastComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                          fromDate:lastDay];
    
    

    
    return lastComponents.day + [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + (7-[JxCalendarBasics normalizedWeekDay:lastComponents.weekday]);
}

- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:_startYear];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:_startYear];
    
    NSDateComponents *firstComponents = [[self calendar] components:(
                                                               NSCalendarUnitHour |
                                                               NSCalendarUnitMinute |
                                                               NSCalendarUnitSecond |
                                                               NSCalendarUnitDay |
                                                               NSCalendarUnitMonth |
                                                               NSCalendarUnitYear |
                                                               NSCalendarUnitWeekday
                                                               )
                                                     fromDate:firstDay];
    
    NSDateComponents *lastComponents = [[self calendar] components:(
                                                              NSCalendarUnitHour |
                                                              NSCalendarUnitMinute |
                                                              NSCalendarUnitSecond |
                                                              NSCalendarUnitDay |
                                                              NSCalendarUnitMonth |
                                                              NSCalendarUnitYear |
                                                              NSCalendarUnitWeekday
                                                              )
                                                    fromDate:lastDay];
    
    NSInteger weekDay = [JxCalendarBasics normalizedWeekDay:firstComponents.weekday];
    
    if (indexPath.item+1 >= weekDay && lastComponents.day > (indexPath.item+1 - weekDay)) {
        NSDateComponents *comp = [JxCalendarBasics baseComponentsWithCalendar:[self calendar] andYear:_startYear];
        
        NSInteger month = indexPath.section+1;
        
        if (month > 12) {
            
            NSInteger moreYears = ceil(month/12);
            
            month = month % 12;
            
            [comp setYear:comp.year + moreYears ];
        }
        
        [comp setMonth:month];
        [comp setDay:(indexPath.item+1 - weekDay)+1];
        
        [comp setHour:0];
        [comp setMinute:0];
        [comp setSecond:0];
        return [[self calendar] dateFromComponents:comp];
    }
    return nil;
}
- (NSIndexPath *)getIndexPathForDate:(NSDate *)date{

    
    
    NSDateComponents *components = [[self calendar] components:(
                                                                NSCalendarUnitHour |
                                                                NSCalendarUnitMinute |
                                                                NSCalendarUnitSecond |
                                                                NSCalendarUnitDay |
                                                                NSCalendarUnitMonth |
                                                                NSCalendarUnitYear |
                                                                NSCalendarUnitWeekday
                                                                )
                                                      fromDate:date];
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:components.month inCalendar:[self calendar] andYear:_startYear];
    
    NSLog(@"firstDay %@", firstDay);
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                                           fromDate:firstDay];
    
    
    NSLog(@"day %ld", (long)components.day);
    
    NSInteger weekday = components.weekday-1;
    if (weekday < 1) {
        weekday = 7;
    }
    
    NSLog(@"weekday %ld", (long)weekday);
    
    NSLog(@"month %ld", (long)components.month);
    
    NSInteger extraCells = ([JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1);
    
    NSLog(@"extraCells %ld", (long)extraCells);
    
    NSInteger row = ceil(((extraCells + components.day)-1) / 7);
    
    NSLog(@"row %ld", (long)row);
    
    
    
    return [NSIndexPath indexPathForItem:(row * 7 + (weekday-1))  inSection:components.month-1];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarHeader" forIndexPath:indexPath];
        header.clipsToBounds = YES;
        UILabel *titleLabel = [header viewWithTag:333];
        
        NSInteger month = indexPath.section+1;
        
        titleLabel.text = [NSString stringWithFormat:@"%@", [[[JxCalendarBasics defaultFormatter] monthSymbols] objectAtIndex:month-1]];
        
        switch (self.style) {
            case JxCalendarStyleYearGrid:
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    titleLabel.font = [titleLabel.font fontWithSize:18];
                }else{
                    titleLabel.font = [titleLabel.font fontWithSize:14];
                }
                
                
                break;
            case JxCalendarStyleMonthGrid:
                titleLabel.font = [titleLabel.font fontWithSize:16];
                break;
        }
        header.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        return header;
    }
    return nil;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"JxCalendarCell";
    
    JxCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self updateCell:cell atIndexPath:indexPath];

    return cell;
}
- (void)updateCell:(JxCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *thisDate = [self getDateForIndexPath:indexPath];
    
    [[cell viewWithTag:999] removeFromSuperview];
    cell.vc = nil;
    
    if (thisDate) {
        
        NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday
                                                              fromDate:thisDate];
        
        switch (self.style) {
            case JxCalendarStyleYearGrid:{
                cell.label.text = [NSString stringWithFormat:@"%li", (long)dateComponents.day];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    cell.label.font = [cell.label.font fontWithSize:14];
                }else{
                    cell.label.font = [cell.label.font fontWithSize:10];
                }
                cell.label.textAlignment = NSTextAlignmentCenter;
            }break;
            case JxCalendarStyleMonthGrid:{
                cell.label.text = [NSString stringWithFormat:@"%li", (long)dateComponents.day];
                cell.label.font = [cell.label.font fontWithSize:22];
                cell.label.textAlignment = NSTextAlignmentCenter;
            }break;
        }
        
        if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
            cell.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
        }else{
            cell.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
        }
        
        if ([self.dataSource numberOfEventsAt:thisDate] > 0) {
            cell.eventMarker.hidden = NO;
        }else{
            cell.eventMarker.hidden = YES;
        }
        
    }else{
        cell.label.text = @" ";
        cell.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1];
        cell.eventMarker.hidden = YES;
    }
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (self.style == JxCalendarStyleWeekGrid) {
//        return;
//    }
    __block NSDate *date = [self getDateForIndexPath:indexPath];
    
    if (date) {
        if (self.style == JxCalendarStyleYearGrid) {
            
            __weak __typeof(self)weakSelf = self;
            [self switchToMonthGridViewWithCallback:^(BOOL finished) {
                //scroll to date
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                NSDateComponents *components = [[strongSelf calendar] components:(
                                                                            NSCalendarUnitMonth |
                                                                            NSCalendarUnitYear
                                                                            )
                                                                  fromDate:date];
                
                [strongSelf scrollToMonth:components.month inYear:components.year];
            }];
            return;
        }
    
    
        [self.delegate calendar:self didSelectDate:date];
        
        JxCalendarLayoutDay *layout = [[JxCalendarLayoutDay alloc] initWithSize:self.collectionView.bounds.size
                                                                         andDay:date];
        
        JxCalendarDay *day = [[JxCalendarDay alloc] initWithCollectionViewLayout:layout];
        layout.source = day;
        
        day.dataSource = self.dataSource;
        day.delegate = self.delegate;
        
        [day setCurrentDate:date];
        
        if (self.navigationController) {
            [self.navigationController pushViewController:day animated:YES];
        }else{
            [self presentViewController:day animated:YES completion:nil];
        }
    }else{
        
        [self.collectionView setContentOffset:CGPointMake(18000, 0)];
    }
    
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (![scrollView isEqual:self.collectionView]) {
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            if (cell.vc) {
                cell.vc.collectionView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
            }
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
        BOOL switchToDifferentYear = NO;
        
        if (scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
            NSLog(@"gehe ein jahr zurück");
            
            [self switchToYear:_startYear-1];
            switchToDifferentYear = YES;
        }else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
            NSLog(@"gehe ein jahr vor ");
            
            [self switchToYear:_startYear+1];
            switchToDifferentYear = YES;
        }
        
        if (switchToDifferentYear) {
            [self.collectionView reloadData];
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView.collectionViewLayout invalidateLayout];
                
            } completion:^(BOOL finished) {
                [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
            }];
        }
        
    }
}
@end
