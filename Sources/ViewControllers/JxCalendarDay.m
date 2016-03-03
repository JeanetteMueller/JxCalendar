//
//  JxCalendarDayCollectionViewController.m
//  JxCalendar
//
//  Created by Jeanette Müller on 04.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarDay.h"
#import "JxCalendarLayoutDay.h"
#import "JxCalendarDayHeader.h"
#import "JxCalendarDefinitions.h"
#import "JxCalendarEvent.h"
#import "JxCalendarEventCell.h"
#import "JxCalendarLayoutDay.h"
#import "JxCalendarEventDuration.h"
#import "JxCalendarEventDay.h"
#import "JxCalendarBasics.h"
#import "UIViewController+CalendarBackButtonHandler.h"

@interface JxCalendarDay ()

@property (nonatomic, readwrite) BOOL initialScrollDone;
@property (strong, nonatomic) UIView *zeiger;
@property (strong, nonatomic) NSTimer *zeigerPositionTimer;

@property (strong, nonatomic) NSDateComponents *currentComponents;
@property (strong, nonatomic) NSDate *now;
@property (strong, nonatomic) NSDateComponents *nowComponents;


@end

@implementation JxCalendarDay

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size andStartDate:(NSDate *)start{
    
    JxCalendarLayoutDay *layout = [[JxCalendarLayoutDay alloc] initWithSize:size
                                                                     andDay:start];
    
    self = [super initWithCollectionViewLayout:layout];
    
    layout.source = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self) {
        self.startDate = start;
        self.dataSource = dataSource;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView setDirectionalLockEnabled:YES];
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];
    
    [self.collectionView registerClass:[JxCalendarEventCell class] forCellWithReuseIdentifier:@"JxCalendarEventCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarEventCell" bundle:bundle] forCellWithReuseIdentifier:@"JxCalendarEventCell"];
    
    [self.collectionView registerClass:[JxCalendarDayHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarDayHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarDayHeader" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarDayHeader"];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
    
    self.currentComponents = [[self.dataSource calendar] components:( NSCalendarUnitHour |
                                                                                  NSCalendarUnitMinute |
                                                                                  NSCalendarUnitSecond |
                                                                                  NSCalendarUnitDay |
                                                                                  NSCalendarUnitMonth |
                                                                                  NSCalendarUnitYear |
                                                                                  NSCalendarUnitWeekday   )
                                                                        fromDate:_startDate];
    
    [self loadNow];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setCurrentDate:_startDate];
    
    [self.collectionView setScrollIndicatorInsets:UIEdgeInsetsMake(3*(kCalendarLayoutWholeDayHeight+[(JxCalendarLayoutDay *)self.collectionView.collectionViewLayout minimumLineSpacing]), 0, 0, 0)];
    
    [self updateZeigerPosition];

    
}
- (void)viewDidLayoutSubviews {
    // If we haven't done the initial scroll, do it once.
    if (!self.initialScrollDone) {
        self.initialScrollDone = YES;
        
        NSDate *now = [NSDate date];
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:now];
        CGFloat offset = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:[NSIndexPath indexPathForItem:0 inSection:components.hour]].frame.origin.y;
        
        [self.collectionView setContentOffset:CGPointMake(0, offset) animated:NO];
    
        [self updateZeigerPosition];

    }
    
    if (_zeiger && !_zeiger.hidden) {
        
        CGRect zeigerFrame = _zeiger.frame;
        zeigerFrame.origin.x = self.collectionView.contentOffset.x+kCalendarLayoutDayHeaderTextWidth;
        _zeiger.frame = zeigerFrame;
        
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_nowComponents.year == _currentComponents.year && _nowComponents.month == _currentComponents.month && _nowComponents.day == _currentComponents.day) {
        self.zeigerPositionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateZeigerPosition) userInfo:nil repeats:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
        [self.delegate calendarDidTransitionTo:JxCalendarAppearanceDay];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [self.zeigerPositionTimer invalidate];
    self.zeigerPositionTimer = nil;
    
    [super viewWillDisappear:animated];
}
- (BOOL)navigationShouldPopOnBackButton{
    
    if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
        [self.delegate calendarWillTransitionFrom:JxCalendarAppearanceDay to:JxCalendarAppearanceWeek];
    }
    return YES;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    self.collectionView.pagingEnabled = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    JxCalendarLayoutDay *layout = [[JxCalendarLayoutDay alloc] initWithSize:self.collectionView.bounds.size andDay:_now];
    layout.source = self;
    
    [self.collectionView setCollectionViewLayout:layout animated:NO];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)setCurrentDate:(NSDate *)currentDate{
    _startDate = currentDate;
    
    if ([self.delegate respondsToSelector:@selector(calendarTitleOnDate:whileOnAppearance:)]) {
        
        NSString *newTitle = [self.delegate calendarTitleOnDate:self.startDate whileOnAppearance:JxCalendarAppearanceDay];
        if (newTitle) {
            self.navigationItem.title = newTitle;
        }
    }else{
        self.navigationItem.title = [[JxCalendarBasics defaultFormatter] stringFromDate:self.startDate];
    }
}
- (void)loadNow{
    self.now = [NSDate date];
    
    self.nowComponents = [[self.dataSource calendar] components:(NSCalendarUnitHour |
                                                                 NSCalendarUnitMinute |
                                                                 NSCalendarUnitSecond |
                                                                 NSCalendarUnitDay |
                                                                 NSCalendarUnitMonth |
                                                                 NSCalendarUnitYear |
                                                                 NSCalendarUnitWeekday)
                                                       fromDate:_now];
}
- (void)updateZeigerPosition{
    
    [self loadNow];
    
    if (_nowComponents.year == _currentComponents.year && _nowComponents.month == _currentComponents.month && _nowComponents.day == _currentComponents.day) {
        //aktueller tag ist heute
        
        //plaziere zeitzeiger
        if (!_zeiger) {
            self.zeiger = [[UIView alloc] init];
            _zeiger.backgroundColor = [UIColor redColor];
            [self.collectionView addSubview:_zeiger];
        }
        
        CGFloat distanceFromTopBecauseOfWholeDayEvents = 3*(kCalendarLayoutWholeDayHeight+[(JxCalendarLayoutDay *)self.collectionView.collectionViewLayout minimumLineSpacing]);
        
        _zeiger.hidden = NO;
        _zeiger.frame = CGRectMake(self.collectionView.contentOffset.x+kCalendarLayoutDayHeaderTextWidth,
                                   _nowComponents.hour*(60*kCalendarLayoutDaySectionHeightMultiplier) + (_nowComponents.minute*kCalendarLayoutDaySectionHeightMultiplier) + distanceFromTopBecauseOfWholeDayEvents,
                                   MAX(self.collectionView.frame.size.width, self.collectionView.frame.size.height),
                                   1);
        
    }else{
        _zeiger.hidden = YES;
    }
    
}
- (NSIndexPath *)indexPathForEvent:(JxCalendarEvent *)searchedEvent{
    NSArray *events = [_dataSource eventsAt:self.startDate];
    
    NSDateComponents *searchedComponents = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:searchedEvent.start];
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (JxCalendarEvent *e in events) {
        
        
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:e.start];
        
        if (components.hour == searchedComponents.hour) {
            [items addObject:e];
        }

    }
    if ([items containsObject:searchedEvent]) {
        return [NSIndexPath indexPathForItem:[items indexOfObject:searchedEvent] inSection:searchedComponents.hour];
    }
    return nil;
}
- (JxCalendarEvent *)eventForIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *events = [_dataSource eventsAt:self.startDate];
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (JxCalendarEvent *e in events) {
        if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
            JxCalendarEventDuration *event = (JxCalendarEventDuration *)e;
            
            NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:event.start];
            
            if (components.hour == indexPath.section) {
                [items addObject:event];
            }
        }else if ([e isKindOfClass:[JxCalendarEventDay class]]) {
            if (indexPath.section == 0) {
                JxCalendarEventDay *event = (JxCalendarEventDay *)e;
                [items addObject:event];
            }
        }
    }
    if (items.count > indexPath.item) {
        return [items objectAtIndex:indexPath.item];
        
        
    }
    return nil;
}
#pragma mark <JxCalendarScrollTo>

- (void)scrollToEvent:(JxCalendarEvent *)event{
    
    NSIndexPath *path = [self indexPathForEvent:event];
    
    if (path) {
        
        UICollectionViewLayoutAttributes *attr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
        
        JxCalendarLayoutDay *layout = (JxCalendarLayoutDay *)self.collectionView.collectionViewLayout;
        
        [self.collectionView scrollRectToVisible:CGRectMake(attr.frame.origin.x, attr.frame.origin.y - [layout wholeDayAreaHeight]-kCalendarLayoutDayHeaderHalfHeight, attr.frame.size.width, attr.frame.size.height) animated:YES];
    }
    
    
}
- (void)scrollToDate:(NSDate *)date{
    NSDateComponents *dateComponents = [[self.dataSource calendar] components:( NSCalendarUnitHour | NSCalendarUnitDay |NSCalendarUnitWeekday) fromDate:date];
    
    if (dateComponents) {
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:dateComponents.hour];
        
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

    return 25;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *events = [_dataSource eventsAt:self.startDate];
    
    NSInteger count = 0;
    
    for (JxCalendarEvent *e in events) {
        if ([e isKindOfClass:[JxCalendarEventDuration class]]) {
            JxCalendarEventDuration *event = (JxCalendarEventDuration *)e;
            
            NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:event.start];
            
            if (components.hour == section) {
                count++;
            }
        }else if ([e isKindOfClass:[JxCalendarEventDay class]]) {
            if (section == 0) {
                count++;
            }
            
            
        }
    }

    return count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JxCalendarEventCell" forIndexPath:indexPath];
    

    JxCalendarEvent *event = [self eventForIndexPath:indexPath];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:333];

    textLabel.text = event.title;
    
    if ([self.dataSource respondsToSelector:@selector(isEventSelected:)] && [self.dataSource isEventSelected:event]) {
        textLabel.textColor = event.fontColorSelected;
        cell.backgroundColor = event.backgroundColorSelected;
        [cell.layer setBorderColor:event.borderColorSelected.CGColor];
    }else{
        textLabel.textColor = event.fontColor;
        cell.backgroundColor = event.backgroundColor;
        [cell.layer setBorderColor:event.borderColor.CGColor];
    }
    
    [cell.layer setBorderWidth:1.5f];
    
    
    [cell.layer setCornerRadius:5];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarDayHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarDayHeader" forIndexPath:indexPath];
        
        UILabel *textLabel = [header viewWithTag:333];

        textLabel.text = [NSString stringWithFormat:@"%ld Uhr", (long)indexPath.section % 24];
        header.backgroundColor = [UIColor clearColor];
        return header;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"indexpath %ld section %ld", (long)indexPath.item, (long)indexPath.section);
    
    if (self.delegate) {
        
        JxCalendarEvent *event = [self eventForIndexPath:indexPath];
        if (event) {
            [self.delegate calendarDidSelectEvent:event whileOnAppearance:JxCalendarAppearanceDay];
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        
    }
}


@end
