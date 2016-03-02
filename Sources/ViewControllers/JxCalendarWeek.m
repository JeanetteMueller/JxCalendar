//
//  JxCalendarWeek.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarWeek.h"
#import "JxCalendarBasics.h"
#import "JxCalendarLayoutWeek.h"
#import "JxCalendarWeekHeader.h"
#import "JxCalendarWeekEventCell.h"
#import "JxCalendarEvent.h"
#import "JxCalendarEventDay.h"
#import "JxCalendarDayHeader.h"
#import "JxCalendarLayoutDay.h"
#import "JxCalendarDay.h"
#import "UIViewController+CalendarBackButtonHandler.h"

@interface JxCalendarWeek ()

@property (nonatomic, readwrite) BOOL initialScrollDone;

@end

@implementation JxCalendarWeek

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size andStartDate:(NSDate *)start{
    
    JxCalendarLayoutWeek *layout = [[JxCalendarLayoutWeek alloc] initWithSize:size];
    
    self = [super initWithCollectionViewLayout:layout];
    
    layout.source = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self) {
        self.dataSource = dataSource;
        self.startDate = start;
        
        if (!self.startDate) {
            
            self.startDate = [NSDate date];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.dataSource) {
        NSLog(@"cant find a DataSource");
        abort();
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.directionalLockEnabled = YES;
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    // Register cell classes
//    [self.collectionView registerClass:[JxCalendarCell class] forCellWithReuseIdentifier:@"JxCalendarCell"];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarCell" bundle:bundle] forCellWithReuseIdentifier:@"JxCalendarCell"];
    
    [self.collectionView registerClass:[JxCalendarWeekEventCell class] forCellWithReuseIdentifier:@"JxCalendarWeekEventCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarWeekEventCell" bundle:bundle] forCellWithReuseIdentifier:@"JxCalendarWeekEventCell"];
    
    
    [self.collectionView registerClass:[JxCalendarWeekHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarWeekHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarWeekHeader" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarWeekHeader"];
    

    // Do any additional setup after loading the view.
    
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        
        if ([self.delegate respondsToSelector:@selector(calendarTitleOnDate:whileOnAppearance:)]) {
        
            NSString *newTitle = [self.delegate calendarTitleOnDate:self.startDate whileOnAppearance:JxCalendarAppearanceWeek];
            
            if (newTitle) {
                self.navigationItem.title = newTitle;
            }
        }else{
            NSDateComponents *startComponents = [self startComponents];
            
            NSArray *symbols = [[JxCalendarBasics defaultFormatter] monthSymbols];
            
            NSString *monthName = [symbols objectAtIndex:startComponents.month-1];
            
            self.navigationItem.title = [NSString stringWithFormat:@"%@ %ld", monthName, startComponents.year];
        }
        
    }
    
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([(JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout headerReferenceSize].height, 0, 0, 0);
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
        [self.delegate calendarDidTransitionTo:JxCalendarAppearanceWeek];
    }
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    NSLog(@"viewWillTransitionToSize %f x %f", size.width, size.height);
    
    
    
    //    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    

            self.collectionView.pagingEnabled = NO;
            
            [self.collectionView.collectionViewLayout invalidateLayout];
    
    JxCalendarLayoutWeek *layout = [[JxCalendarLayoutWeek alloc] initWithSize:size];
    layout.source = self;
    
            [self.collectionView setCollectionViewLayout:layout animated:NO];
            
   
    [self viewDidLayoutSubviews];
    
    //    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    //
    //    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    JxCalendarLayoutWeek *layout = (JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout;
    
    if (!self.initialScrollDone) {
        self.initialScrollDone = YES;
        NSDate *now = [NSDate date];
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:now];
        
        
        NSInteger section = [self sectionForDay:[self startComponents].day];
        
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:floor(section/7)*7];
        
        [self.collectionView setContentOffset:CGPointMake([self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath].frame.origin.x,
                                                          components.hour*(60*kCalendarLayoutDaySectionHeightMultiplier) + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing))-kCalendarLayoutDayHeaderHalfHeight) animated:NO];
    }
    UIColor *color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
    
    
    for (int r = 0; r < 25; r++) {
        
        CGFloat baseTopDistance = layout.headerReferenceSize.height + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing)) + r * (60*kCalendarLayoutDaySectionHeightMultiplier);
        
        UILabel *time = [self.collectionView viewWithTag:9900+r];
        if (!time) {
            time = [[UILabel alloc] init];
            time.tag = 9900+r;
            time.backgroundColor = [UIColor whiteColor];
            time.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            time.textColor = color;
            time.textAlignment = NSTextAlignmentCenter;
            time.text = [NSString stringWithFormat:@"%d Uhr", r];
            
            [self.collectionView addSubview:time];
            
            [self.collectionView sendSubviewToBack:time];
        }
        
        UIView *row = [self.collectionView viewWithTag:9800+r];
        if (!row) {
            row = [[UIView alloc] init];
            row.tag = 9800+r;
            row.backgroundColor = color;
            
            [self.collectionView addSubview:row];
            [self.collectionView sendSubviewToBack:row];
        }
        
        time.frame = CGRectMake(self.collectionView.contentOffset.x + 5,
                                baseTopDistance-10,
                                45,
                                20);
        
        row.frame = CGRectMake(self.collectionView.contentOffset.x,
                               baseTopDistance,
                               self.collectionView.frame.size.width,
                               1);
        
        
        
    }
    
}
- (BOOL)navigationShouldPopOnBackButton{
    
    if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
        
        JxCalendarOverview *overview = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        
        
        [self.delegate calendarWillTransitionFrom:JxCalendarAppearanceWeek to:[overview getOverviewAppearance]];
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSCalendar *)calendar{
    return [self.dataSource calendar];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)sectionForDay:(NSInteger)day{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday)
                                                           fromDate:firstDay];
    
    return [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + day - 1;
}
#pragma mark <JxCalendarScrollTo>
- (void)scrollToEvent:(JxCalendarEvent *)event{
    [self scrollToDate:event.start];
}
- (void)scrollToDate:(NSDate *)date{
    NSLog(@"week scroll to date");
    NSDateComponents *dateComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday) fromDate:date];
    
    if (dateComponents) {
    
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:[self getSectionForDate:date]];
        
        if ([self.collectionView numberOfSections] > path.section && [self.collectionView numberOfItemsInSection:path.section] > 0) {
            
            NSIndexPath *headPath = [NSIndexPath indexPathForItem:0 inSection:path.section+7-[JxCalendarBasics normalizedWeekDay:dateComponents.weekday]];
            
            UICollectionViewLayoutAttributes *headAttr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headPath];
            
            UICollectionViewLayoutAttributes *attr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            [self.collectionView scrollRectToVisible:CGRectMake(headAttr.frame.origin.x, attr.frame.origin.y, attr.frame.size.width, 50) animated:YES];
            
        }
    }
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday)
                                                           fromDate:firstDay];
    
    NSDateComponents *lastComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday)
                                                          fromDate:lastDay];
    
    
    
    
    return lastComponents.day + [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + (7-[JxCalendarBasics normalizedWeekDay:lastComponents.weekday]);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDate *thisDate = [self getDateForSection:section];
    if (thisDate) {
        
        NSArray *events = [self.dataSource eventsAt:thisDate];
        
        return events.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JxCalendarWeekEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JxCalendarWeekEventCell" forIndexPath:indexPath];
    
    NSDate *thisDate = [self getDateForSection:indexPath.section];
    
    
    NSArray *events = [self.dataSource eventsAt:thisDate];
    
    JxCalendarEvent *e = [events objectAtIndex:indexPath.item];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:333];
    textLabel.numberOfLines = 0;
    
    
    if ([e isKindOfClass:[JxCalendarEventDay class]]) {
        JxCalendarEventDay *event = (JxCalendarEventDay *)e;
        textLabel.text = event.title;
    }else{
        textLabel.text = @"";
    }
    
    
    
    if ([self.dataSource respondsToSelector:@selector(isEventSelected:)] && [self.dataSource isEventSelected:e]) {
        textLabel.textColor = e.fontColorSelected;
        cell.backgroundColor = e.backgroundColorSelected;
        [cell.layer setBorderColor:[UIColor redColor].CGColor];
    }else{
        textLabel.textColor = e.fontColor;
        cell.backgroundColor = e.backgroundColor;
        [cell.layer setBorderColor:e.borderColor.CGColor];
    }
    
    
    [cell.layer setBorderWidth:1.5f];
    [cell.layer setCornerRadius:5];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"indexpath %ld section %ld", (long)indexPath.item, (long)indexPath.section);
    
    if (self.delegate) {
        
        NSDate *thisDate = [self getDateForSection:indexPath.section];
        
        
        NSArray *events = [self.dataSource eventsAt:thisDate];
        
        JxCalendarEvent *event = [events objectAtIndex:indexPath.item];
        if (event) {
            [self.delegate calendarDidSelectEvent:event whileOnAppearance:JxCalendarAppearanceWeek];
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        
    }
}
- (IBAction)openDayView:(UIButton *)sender{
    
    NSDate *date = [self getDateForSection:sender.tag-1000];
    
    if (date) {
        
        if ([self.dataSource isDaySelected:date]) {
            if ([self.delegate respondsToSelector:@selector(calendarDidDeselectDate:whileOnAppearance:)]) {
                [self.delegate calendarDidDeselectDate:date whileOnAppearance:JxCalendarAppearanceWeek];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(calendarDidSelectDate:whileOnAppearance:)]) {
                [self.delegate calendarDidSelectDate:date whileOnAppearance:JxCalendarAppearanceWeek];
            }
        }
        
        [self.collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
            [self.delegate calendarWillTransitionFrom:JxCalendarAppearanceWeek to:JxCalendarAppearanceDay];
        }
        
        JxCalendarDay *day = [[JxCalendarDay alloc] initWithDataSource:self.dataSource andSize:self.collectionView.bounds.size andStartDate:date];

        day.delegate = self.delegate;
        
        if (self.navigationController) {
            [self.navigationController pushViewController:day animated:YES];
        }else{
            [self presentViewController:day animated:YES completion:nil];
        }
    }
    
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarWeekHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarWeekHeader" forIndexPath:indexPath];
        
        [header.button addTarget:self action:@selector(openDayView:) forControlEvents:UIControlEventTouchUpInside];
        
        header.clipsToBounds = YES;
        UILabel *titleLabel = [header viewWithTag:333];
        
        NSDate *thisDate = [self getDateForSection:indexPath.section];
        if (thisDate) {
            NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday
                                                                  fromDate:thisDate];
            
            header.button.tag = indexPath.section+1000;
            
            NSDateFormatter *weekday = [JxCalendarBasics defaultFormatter];
            [weekday setDateFormat: @"EEE"];
            
            titleLabel.text = [NSString stringWithFormat:@"%li.\n%@", (long)dateComponents.day, [weekday stringFromDate:thisDate]];
            
            if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                header.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
            }else{
                header.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
            }
            
            if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:thisDate]) {
                
                header.layer.borderColor = [UIColor redColor].CGColor;
                titleLabel.textColor = [UIColor redColor];
            }else{
                header.layer.borderColor = [UIColor darkGrayColor].CGColor;
                titleLabel.textColor = [UIColor darkGrayColor];
            }
            header.layer.borderWidth = 1.0f;
            
            header.eventMarker.hidden = !([self.dataSource eventsAt:thisDate].count > 0);
            
        }else{
            titleLabel.text = @"";
            header.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1];
            header.layer.borderColor = self.collectionView.backgroundColor.CGColor;
        }
        
        
        
        
        return header;
    }
    return nil;
}
- (NSInteger)getSectionForDate:(NSDate *)date{
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
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
    NSInteger weekDay = [JxCalendarBasics normalizedWeekDay:firstComponents.weekday];
    
    NSDateComponents *dateComponents = [[self calendar] components:(
                                                                    NSCalendarUnitHour |
                                                                    NSCalendarUnitMinute |
                                                                    NSCalendarUnitSecond |
                                                                    NSCalendarUnitDay |
                                                                    NSCalendarUnitMonth |
                                                                    NSCalendarUnitYear |
                                                                    NSCalendarUnitWeekday
                                                                    )
                                                          fromDate:date];
    
    return dateComponents.day + weekDay-1-1;
    
}
- (NSDate *)getDateForSection:(NSInteger)section{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    
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
    
    if (section+1 >= weekDay && lastComponents.day > (section+1 - weekDay)) {
        NSDateComponents *comp = [JxCalendarBasics baseComponentsWithCalendar:[self calendar] andYear:[self startComponents].year];
        
        NSInteger month = [self startComponents].month;
        
        if (month > 12) {
            
            NSInteger moreYears = ceil(month/12);
            
            month = month % 12;
            
            [comp setYear:comp.year + moreYears ];
        }
        
        [comp setMonth:month];
        [comp setDay:(section+1 - weekDay)+1];
        
        [comp setHour:0];
        [comp setMinute:0];
        [comp setSecond:0];
        return [[self calendar] dateFromComponents:comp];
    }
    return nil;

}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    for (int r = 0; r < 25; r++) {
//        UIView *label = [self.collectionView viewWithTag:9900+r];
//        UIView *row = [self.collectionView viewWithTag:9800+r];
//        
//        CGRect labelRect = label.frame;
//        
//        labelRect.origin.x = scrollView.contentOffset.x + 5;
//        
//        label.frame = labelRect;
//        
//        
//        CGRect rowRect = row.frame;
//        
//        rowRect.origin.x = scrollView.contentOffset.x ;
//        
//        row.frame = rowRect;
//    }
//    
//}
@end
