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
#import "JxCalendarEventDuration.h"
#import "JxCalendarDay.h"
#import "UIViewController+CalendarBackButtonHandler.h"

@interface JxCalendarWeek ()

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
            
            self.startDate = [NSDate new];
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
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.directionalLockEnabled = YES;
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    [self.collectionView registerClass:[JxCalendarWeekEventCell class] forCellWithReuseIdentifier:@"JxCalendarWeekEventCell"];
    [self.collectionView registerClass:[JxCalendarWeekHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarWeekHeader"];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSDateComponents *startComponents = [self startComponents];
    
    if (self.navigationController) {
        
        if ([self.delegate respondsToSelector:@selector(calendar:titleOnDate:whileOnAppearance:)]) {
        
            NSString *newTitle = [self.delegate calendar:[self getCalendarOverview] titleOnDate:self.startDate whileOnAppearance:JxCalendarAppearanceWeek];
            
            if (newTitle) {
                self.navigationItem.title = newTitle;
            }
        }else{
            
            
            NSArray *symbols = [[JxCalendarBasics defaultFormatter] monthSymbols];
            
            NSString *monthName = [symbols objectAtIndex:startComponents.month-1];
            
            self.navigationItem.title = [NSString stringWithFormat:@"%@ %ld", monthName, (long)startComponents.year];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(calendar:willDisplayMonth:inYear:)]) {
        [self.dataSource calendar:[self getCalendarOverview] willDisplayMonth:startComponents.month inYear:startComponents.year];
    }
    
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([(JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout headerReferenceSize].height, 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(calendar:didTransitionTo:)]) {
        [self.delegate calendar:[self getCalendarOverview] didTransitionTo:JxCalendarAppearanceWeek];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    self.collectionView.pagingEnabled = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    JxCalendarLayoutWeek *layout = [[JxCalendarLayoutWeek alloc] initWithSize:size];
    layout.source = self;
    
    [self.collectionView setCollectionViewLayout:layout animated:NO];
    
    [self viewDidLayoutSubviews];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewDidLayoutSubviews{
    JxCalendarLayoutWeek *layout = (JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout;
    
    if (!self.initialScrollDone) {
        if ([self getCalendarOverview].scrollToCurrentTimeAndDate) {
            NSDate *now = [NSDate new];
            
            
            NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:now];
            
            
            NSInteger section = [self sectionForDay:[self startComponents].day];
            
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:floor(section/7)*7];
            
            CGFloat offset = components.hour*(60*kCalendarLayoutDaySectionHeightMultiplier) + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing))-kCalendarLayoutDayHeaderHalfHeight;
            
            if (offset > self.collectionView.contentSize.height-self.collectionView.frame.size.height) {
                offset = self.collectionView.contentSize.height-self.collectionView.frame.size.height;
            }
            [self.collectionView setContentOffset:CGPointMake([self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headerIndexPath].frame.origin.x,
                                                              offset) animated:NO];
        }
        
    }
    UIColor *color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    
    for (int r = 0; r < 25; r++) {
        
        CGFloat baseTopDistance = layout.headerReferenceSize.height + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing)) + layout.minimumLineSpacing + r * (60*kCalendarLayoutDaySectionHeightMultiplier);
        
        UILabel *time = [self.collectionView viewWithTag:9900+r];
        if (!time) {
            time = [[UILabel alloc] init];
            time.tag = 9900+r;
            time.backgroundColor = [UIColor clearColor];
            time.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
            time.textColor = color;
            time.textAlignment = NSTextAlignmentCenter;
            time.text = [NSString stringWithFormat:@"%d Uhr", r];
            
            [self.collectionView addSubview:time];
        }
        
        UIView *row = [self.collectionView viewWithTag:9800+r];
        if (!row) {
            row = [[UIView alloc] init];
            row.tag = 9800+r;
            row.backgroundColor = color;
            
            [self.collectionView addSubview:row];
        }
        [self.collectionView sendSubviewToBack:time];
        [self.collectionView sendSubviewToBack:row];
        time.frame = CGRectMake(self.collectionView.contentOffset.x + 5,
                                baseTopDistance-10,
                                45,
                                20);
        
        row.frame = CGRectMake(time.frame.origin.x+time.frame.size.width,
                               baseTopDistance,
                               self.collectionView.frame.size.width - (5+ time.frame.size.width),
                               1);
        
        
        
    }
    [super viewDidLayoutSubviews];
}
- (void)viewWillDisappear:(BOOL)animated{
    
    if ([self.dataSource respondsToSelector:@selector(calendar:didHideMonth:inYear:)]) {
        NSDateComponents *startComponents = [self startComponents];
        [self.dataSource calendar:[self getCalendarOverview] didHideMonth:startComponents.month inYear:startComponents.year];
    }
    
    [super viewWillDisappear:animated];
}
- (BOOL)navigationShouldPopOnBackButton{
    
    if ([self.delegate respondsToSelector:@selector(calendar:willTransitionFrom:to:)]) {
        
        JxCalendarOverview *overview = [self getCalendarOverview];
        
        [self.delegate calendar:overview willTransitionFrom:JxCalendarAppearanceWeek to:overview.overviewAppearance];
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

- (NSInteger)sectionForDay:(NSInteger)day{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:[self startComponents].month inCalendar:[self calendar] andYear:[self startComponents].year];
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday)
                                                           fromDate:firstDay];
    
    return [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + day - 1;
}

#pragma mark <JxCalendarScrollTo>

- (void)scrollToEvent:(JxCalendarEvent *)event{
    NSDateComponents *dateComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday) fromDate:event.start];
    
    if (dateComponents) {
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:[self getSectionForDate:event.start]];
        
        if ([self.collectionView numberOfSections] > path.section && [self.collectionView numberOfItemsInSection:path.section] > 0) {
            
            NSIndexPath *headPath = [NSIndexPath indexPathForItem:0 inSection:path.section+7-[JxCalendarBasics normalizedWeekDay:dateComponents.weekday]];
            
            UICollectionViewLayoutAttributes *headAttr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headPath];
            
            UICollectionViewLayoutAttributes *attr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            [self.collectionView scrollRectToVisible:CGRectMake(headAttr.frame.origin.x, attr.frame.origin.y, attr.frame.size.width, 50) animated:YES];
            
        }
    }
}

- (void)scrollToDate:(NSDate *)date{

    JxCalendarLayoutWeek *layout = (JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout;
    
    NSDateComponents *dateComponents = [[self calendar] components:( NSCalendarUnitHour|NSCalendarUnitWeekday) fromDate:date];
    
    if (dateComponents) {
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:[self getSectionForDate:date]];
        
        if ([self.collectionView numberOfSections] > path.section) {
            
            NSIndexPath *headPath = [NSIndexPath indexPathForItem:0 inSection:path.section+7-[JxCalendarBasics normalizedWeekDay:dateComponents.weekday]];
            
            UICollectionViewLayoutAttributes *headAttr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:headPath];
            
            
            [self.collectionView scrollRectToVisible:CGRectMake(headAttr.frame.origin.x,
                                                                layout.headerReferenceSize.height + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing)) + dateComponents.hour * (60*kCalendarLayoutDaySectionHeightMultiplier),
                                                                headAttr.frame.size.width,
                                                                50)
                                            animated:YES];
            
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
    
    if ([self.dataSource respondsToSelector:@selector(eventsAt:)]) {
        NSDate *thisDate = [self getDateForSection:section];
        if (thisDate) {
            
            NSArray *events = [self.dataSource eventsAt:thisDate];
            
            return events.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JxCalendarWeekEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JxCalendarWeekEventCell" forIndexPath:indexPath];
    
    NSDate *thisDate = [self getDateForSection:indexPath.section];
    if ([self.dataSource respondsToSelector:@selector(eventsAt:)]) {
        NSArray *events = [self.dataSource eventsAt:thisDate];
    
        JxCalendarEvent *e = [events objectAtIndex:indexPath.item];
        
        cell.textLabel.numberOfLines = 0;
        
        JxCalendarEventDay *event = (JxCalendarEventDay *)e;
        cell.textLabel.text = event.title;
        
        if ([self.dataSource respondsToSelector:@selector(isEventSelected:)] && [self.dataSource isEventSelected:e]) {
            cell.textLabel.textColor = e.fontColorSelected;
            cell.backgroundColor = e.backgroundColorSelected;
            [cell.layer setBorderColor:[UIColor redColor].CGColor];
        }else{
            cell.textLabel.textColor = e.fontColor;
            cell.backgroundColor = e.backgroundColor;
            [cell.layer setBorderColor:e.borderColor.CGColor];
        }
        
        
        [cell.layer setBorderWidth:1.0f];
        [cell.layer setCornerRadius:5];
        
        
        [cell.textLabel setTransform:CGAffineTransformIdentity];
        
        if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
            cell.textLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
            cell.textLabel.frame = CGRectMake(0, 2, cell.frame.size.width, cell.frame.size.height-4);
            
        }else{
            cell.textLabel.frame = CGRectMake(2, 0, cell.frame.size.width-4, cell.frame.size.height);
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate) {
        
        NSDate *thisDate = [self getDateForSection:indexPath.section];
        
        if ([self.dataSource respondsToSelector:@selector(eventsAt:)]) {
            NSArray *events = [self.dataSource eventsAt:thisDate];
            
            JxCalendarEvent *event = [events objectAtIndex:indexPath.item];
            if (event) {
                if ([self.delegate respondsToSelector:@selector(calendar:didSelectEvent:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didSelectEvent:event whileOnAppearance:JxCalendarAppearanceWeek];
                }
                
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
}

- (IBAction)openDayView:(UIButton *)sender{
    
    NSDate *date = [self getDateForSection:sender.tag-1000];
    
    if (date) {
        
        if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:date]) {
            if ([self.delegate respondsToSelector:@selector(calendar:didDeselectDate:whileOnAppearance:)]) {
                [self.delegate calendar:[self getCalendarOverview] didDeselectDate:date whileOnAppearance:JxCalendarAppearanceWeek];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(calendar:didSelectDate:whileOnAppearance:)]) {
                [self.delegate calendar:[self getCalendarOverview] didSelectDate:date whileOnAppearance:JxCalendarAppearanceWeek];
            }
        }
        
        [self.collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(calendar:willTransitionFrom:to:)]) {
            [self.delegate calendar:[self getCalendarOverview] willTransitionFrom:JxCalendarAppearanceWeek to:JxCalendarAppearanceDay];
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
    
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarWeekFooter" forIndexPath:indexPath];
        
        return footer;
    }else {
        JxCalendarWeekHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarWeekHeader" forIndexPath:indexPath];
        header.backgroundColor = [UIColor whiteColor];
        [header.button addTarget:self action:@selector(openDayView:) forControlEvents:UIControlEventTouchUpInside];
        header.clipsToBounds = YES;
        
        NSDate *thisDate = [self getDateForSection:indexPath.section];
        if (thisDate) {
            NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday
                                                                  fromDate:thisDate];
            
            header.button.tag = indexPath.section+1000;
            
            NSDateFormatter *weekday = [JxCalendarBasics defaultFormatter];
            [weekday setDateFormat: @"EEE"];
            
            header.titleLabel.text = [NSString stringWithFormat:@"%li.\n%@", (long)dateComponents.day, [weekday stringFromDate:thisDate]];
            
            if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                header.backgroundColor = kJxCalendarWeekendBackgroundColor;
                header.titleLabel.textColor = kJxCalendarWeekendTextColor;
            }else{
                header.backgroundColor = kJxCalendarDayBackgroundColor;
                header.titleLabel.textColor = kJxCalendarDayTextColor;
            }
            
            if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:thisDate]) {
                if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                    header.backgroundColor = kJxCalendarSelectedWeekendBackgroundColor;
                }else{
                    header.backgroundColor = kJxCalendarSelectedDayBackgroundColor;
                }
                header.titleLabel.textColor = kJxCalendarSelectedDayTextColor;
            }
            header.eventMarker.hidden = !([self.dataSource numberOfEventsAt:thisDate] > 0);
            
        }else{
            header.titleLabel.text = @"";
            header.eventMarker.hidden = YES;
            header.backgroundColor = self.collectionView.backgroundColor;
            header.layer.borderColor = self.collectionView.backgroundColor.CGColor;
        }
        
        return header;
    }
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

#pragma mark Scrolling

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSUInteger nearestIndex = (NSUInteger)(targetContentOffset->x / scrollView.bounds.size.width + 0.5f);
    
    nearestIndex = MAX( MIN( nearestIndex, scrollView.contentSize.width/scrollView.frame.size.width  ), 0 );
    
    CGFloat xOffset = nearestIndex * scrollView.bounds.size.width;
    
    xOffset = xOffset==0?1:xOffset;
    
    *targetContentOffset = CGPointMake(xOffset, targetContentOffset->y);
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if( !decelerate )
    {
        NSUInteger currentIndex = (NSUInteger)(scrollView.contentOffset.x / scrollView.bounds.size.width);
        
        [scrollView setContentOffset:CGPointMake(scrollView.bounds.size.width * currentIndex, scrollView.contentOffset.y) animated:YES];
    }
}
@end
