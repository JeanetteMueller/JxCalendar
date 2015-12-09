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
#import "JxCalendarLayoutList.h"

#import "JxCalendarHeader.h"
#import "JxCalendarYearGridCell.h"
#import "JxCalendarListCell.h"
#import "JxCalendarCell.h"

#import "JxCalendarDay.h"
#import "JxCalendarLayoutDay.h"

@interface JxCalendarOverview ()

@property (nonatomic, readwrite) JxCalendarStyle style;
@property (nonatomic, readwrite) NSInteger startYear;
@end

@implementation JxCalendarOverview

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andStyle:(JxCalendarStyle)style andWidth:(CGFloat)width{
    
    //CGFloat width = 200;// CGRectGetWidth(self.collectionView.bounds);
    
    UICollectionViewLayout *layout;
    switch (style) {
        case JxCalendarStyleYearGrid:
            layout = [[JxCalendarLayoutYearGrid alloc] initWithWidth:width];
            break;
        case JxCalendarStyleMonthGrid:
            layout = [[JxCalendarLayoutMonthGrid alloc] initWithWidth:width];
            break;
        case JxCalendarStyleList:
            layout = [[JxCalendarLayoutList alloc] initWithWidth:width];
            break;
    }
    
    self = [super initWithCollectionViewLayout:layout];
    
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
    
    if (!_dataSource) {
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
- (IBAction)closeCalendar:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithTitle:@"Year" style:UIBarButtonItemStylePlain target:self action:@selector(switchToYearGridView)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"Month" style:UIBarButtonItemStylePlain target:self action:@selector(switchToMonthGridView)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(switchToListView)]];
    
    if (self.presentingViewController) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeCalendar:)];
    }
    
    [self switchToYear:self.startYear];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    NSLog(@"viewWillTransitionToSize %f x %f", size.width, size.height);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        NSLog(@"interaction ends");
        switch (self.style) {
            case JxCalendarStyleYearGrid:{
                self.collectionView.pagingEnabled = NO;
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
                
            }break;
            case JxCalendarStyleMonthGrid:{
                self.collectionView.pagingEnabled = NO;
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
                
            }break;
            case JxCalendarStyleList:{
                self.collectionView.pagingEnabled = NO;
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutList alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
                
            }break;
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    
    
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
- (void)switchToYearGridView{
    
    self.style = JxCalendarStyleYearGrid;
    
    [self.collectionView reloadData];
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
        
    } completion:^(BOOL finished) {
        
    }];

}

- (void)switchToMonthGridView{
    [self switchToMonthGridViewWithCallback:nil];
}
- (void)switchToMonthGridViewWithCallback:(void (^)(BOOL finished))callback{
    
    self.style = JxCalendarStyleMonthGrid;
    
    [self.collectionView reloadData];
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
        
    } completion:callback];

}
- (void)switchToListView{
    
    self.style = JxCalendarStyleList;

    [self.collectionView reloadData];

    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutList alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)] animated:YES];
        
    } completion:^(BOOL finished) {
        
    }];
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
- (NSDateFormatter *)defaultFormatter{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setLocale:[NSLocale currentLocale]];//  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formater setDateStyle:NSDateFormatterFullStyle];
    return formater;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 12;
}
- (NSDateComponents *)baseComponents{
    
    NSDateComponents *components = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday)
                                         fromDate:[NSDate date]];
    
    
    [components setYear:_startYear];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    return components;
}
- (NSDate *)firstDayOfMonth:(NSInteger)month{
    NSDateComponents *base = [self baseComponents];
    
    if (month > 12) {
        
        NSInteger moreYears = ceil(month/12);
        
        month = (month % 12);
        
        [base setYear:base.year + moreYears ];
    }
    [base setMonth:month];
    [base setDay:1];
    
    return [[NSCalendar currentCalendar] dateFromComponents:base];
}
- (NSDate *)lastDayOfMonth:(NSInteger)month{
    NSDateComponents *base = [self baseComponents];
    NSDate *firstDay = [self firstDayOfMonth:month];
    NSRange range = [[self calendar] rangeOfUnit:NSCalendarUnitDay
                                    inUnit:NSCalendarUnitMonth
                                   forDate:firstDay];
    
    if (month > 12) {
        
        NSInteger moreYears = ceil(month/12);
        
        month = (month % 12);
        
        [base setYear:base.year + moreYears ];
    }
    
    [base setMonth:month];
    [base setDay:range.length];
    return [[self calendar] dateFromComponents:base];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *currentDate = [self getDateForIndexPath:indexPath];
    
    switch (self.style) {
        case JxCalendarStyleYearGrid:{
            JxCalendarLayoutYearGrid *layout = (JxCalendarLayoutYearGrid *)collectionView.collectionViewLayout;
            
            return layout.itemSize;
        }break;
        case JxCalendarStyleMonthGrid:{
            JxCalendarLayoutMonthGrid *layout = (JxCalendarLayoutMonthGrid *)collectionView.collectionViewLayout;
            
            return layout.itemSize;
        }break;
        case JxCalendarStyleList:{
            if (currentDate) {
                JxCalendarLayoutList *layout = (JxCalendarLayoutList *)collectionView.collectionViewLayout;
                
                return layout.itemSize;
            }
        }break;
    }

    return CGSizeMake(0,1);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDate *firstDay = [self firstDayOfMonth:section+1];
    NSDate *lastDay = [self lastDayOfMonth:section+1];
    
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                          fromDate:firstDay];
    
    NSDateComponents *lastComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                          fromDate:lastDay];
    
    

    
    return lastComponents.day + [self normalizedWeekDay:firstComponents.weekday]-1 + (7-[self normalizedWeekDay:lastComponents.weekday]);
}
- (NSInteger)normalizedWeekDay:(NSInteger)weekday{
    weekday = weekday -1;
    if (weekday == 0) {
        weekday = 7;
    }
    
    return weekday;
}
- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *firstDay = [self firstDayOfMonth:indexPath.section+1];
    NSDate *lastDay = [self lastDayOfMonth:indexPath.section+1];
    
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
    
    NSInteger weekDay = [self normalizedWeekDay:firstComponents.weekday];
    
    if (indexPath.item+1 >= weekDay && lastComponents.day > (indexPath.item+1 - weekDay)) {
        NSDateComponents *comp = [self baseComponents];
        
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
    
    NSDate *firstDay = [self firstDayOfMonth:components.month];
    
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
    
    NSInteger extraCells = ([self normalizedWeekDay:firstComponents.weekday]-1);
    
    NSLog(@"extraCells %ld", (long)extraCells);
    
    NSInteger row = ceil(((extraCells + components.day)-1) / 7);
    
    NSLog(@"row %ld", (long)row);
    
    
    
    return [NSIndexPath indexPathForItem:(row * 7 + (weekday-1))  inSection:components.month-1];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarHeader" forIndexPath:indexPath];
        
        UILabel *titleLabel = [header viewWithTag:333];
        
        NSInteger month = indexPath.section+1;
        
        titleLabel.text = [NSString stringWithFormat:@"%@", [[[self defaultFormatter] monthSymbols] objectAtIndex:month-1]];
        
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
            case JxCalendarStyleList:
                titleLabel.font = [titleLabel.font fontWithSize:20];
                break;
        }
        //header.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
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
    
    if (thisDate) {
        
        NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitWeekday
                                                              fromDate:thisDate];
        
        switch (self.style) {
            case JxCalendarStyleYearGrid:
                cell.label.text = [NSString stringWithFormat:@"%ld", (long)dateComponents.day];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    cell.label.font = [cell.label.font fontWithSize:14];
                }else{
                    cell.label.font = [cell.label.font fontWithSize:10];
                }
                cell.label.textAlignment = NSTextAlignmentCenter;
                break;
            case JxCalendarStyleMonthGrid:
                cell.label.text = [NSString stringWithFormat:@"%ld", (long)dateComponents.day];
                cell.label.font = [cell.label.font fontWithSize:22];
                cell.label.textAlignment = NSTextAlignmentCenter;
                break;
            case JxCalendarStyleList:
                cell.label.text = [NSString stringWithFormat:@"%@ (%lu)", [[self defaultFormatter] stringFromDate:thisDate], (unsigned long)[self.dataSource numberOfEventsAt:thisDate]];
                cell.label.font = [cell.label.font fontWithSize:18];
                cell.label.textAlignment = NSTextAlignmentLeft;
                break;
        }
        
        if ([self normalizedWeekDay:dateComponents.weekday] > 5) {
            cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
        }else{
            cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        }
        
        if ([self.dataSource numberOfEventsAt:thisDate] > 0) {
            cell.eventMarker.hidden = NO;
        }else{
            cell.eventMarker.hidden = YES;
        }
        
    }else{
        cell.label.text = @" ";
        cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
        cell.eventMarker.hidden = YES;
    }
}
#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __block NSDate *date = [self getDateForIndexPath:indexPath];
    
    if (date) {
        if (_style == JxCalendarStyleYearGrid) {
            
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
        
        JxCalendarDay *day = [[JxCalendarDay alloc] initWithCollectionViewLayout:[[JxCalendarLayoutDay alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds)
                                                                                                                  andEvents:[self.dataSource eventsAt:date]
                                                                                                                andCalendar:[self calendar]]];
        
        day.dataSource = self.dataSource;
        day.delegate = self.delegate;
        
        [day setCurrentDate:date];
        day.defaultFormatter = [self defaultFormatter];
        
        if (self.navigationController) {
            [self.navigationController pushViewController:day animated:YES];
        }else{
            [self presentViewController:day animated:YES completion:nil];
        }
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
    //NSLog(@"scrollView.contentOffset.y %f", scrollView.contentOffset.y + scrollView.contentInset.top);
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
