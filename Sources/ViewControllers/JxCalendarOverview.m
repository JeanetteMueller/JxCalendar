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

@interface JxCalendarOverview () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) CGSize startSize;

@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic, readwrite) NSIndexPath *longHoldStartIndexPath;
@property (strong, nonatomic, readwrite) NSIndexPath *longHoldEndIndexPath;

@end

@implementation JxCalendarOverview

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andStyle:(JxCalendarOverviewStyle)style andSize:(CGSize)size andStartDate:(NSDate *)date andStartAppearance:(JxCalendarAppearance)appearance{
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIScreen mainScreen].bounds.size;
    }
    
    if (appearance == JxCalendarAppearanceYear){
        style = JxCalendarOverviewStyleYearGrid;
    }else if (appearance == JxCalendarAppearanceMonth){
        style = JxCalendarOverviewStyleMonthGrid;
    }
    
    UICollectionViewLayout *layout;
    switch (style) {
        case JxCalendarOverviewStyleYearGrid:
            layout = [[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size];
            break;
        case JxCalendarOverviewStyleMonthGrid:
            layout = [[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size];
            break;
    }
    
    self = [super initWithCollectionViewLayout:layout];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self) {
        self.startSize = size;
        self.style = style;
        self.startDate = date;
        self.startAppearance = appearance;
        self.dataSource = dataSource;
        
        if (!self.startDate) {
            
            self.startDate = [NSDate date];
        }
    }
    return self;
}
- (NSCalendar *)calendar{
    return [self.dataSource calendar];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    [self updateNavigationButtons];
    
    [self switchToNewYear:[self startComponents].year];
    
    
    if (self.startAppearance > JxCalendarAppearanceMonth) {
        
        JxCalendarWeek *vc = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
        vc.delegate = self.delegate;
        
        [self.navigationController pushViewController:vc animated:NO];
        
        if (self.startAppearance == JxCalendarAppearanceDay) {

            
            
            JxCalendarDay *day = [[JxCalendarDay alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
            
            day.delegate = self.delegate;
            
            [self.navigationController pushViewController:day animated:NO];
        }
        
        
        self.startAppearance = JxCalendarAppearanceNone;
        
    }
    
    if (self.view.frame.size.height > self.startSize.height) {
        self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top,
                                                            self.collectionView.contentInset.left,
                                                            self.view.frame.size.height-self.startSize.height,
                                                            self.collectionView.contentInset.right);
        
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    self.longPressGesture.numberOfTouchesRequired = 1;
    self.longPressGesture.minimumPressDuration = 0.5;
    [self.collectionView addGestureRecognizer:self.longPressGesture];
    
    NSLog(@"gesture %@", self.collectionView.gestureRecognizers);
}
- (void)updateNavigationButtons{
    
    if (![self.dataSource respondsToSelector:@selector(shouldDisplayNavbarButtonsWhileOnAppearance:)] ||
        [self.dataSource shouldDisplayNavbarButtonsWhileOnAppearance:[self getOverviewAppearance]]) {
        
        switch (self.style) {
            case JxCalendarOverviewStyleMonthGrid:
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Year" style:UIBarButtonItemStylePlain target:self action:@selector(switchToYear:)];
                break;
            case JxCalendarOverviewStyleYearGrid:
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Month" style:UIBarButtonItemStylePlain target:self action:@selector(switchToMonth:)];
                break;
            default:
                break;
        }
    }
}
- (IBAction)switchToYear:(id)sender{
    [self switchToAppearance:JxCalendarAppearanceYear withDate:nil];
}
- (IBAction)switchToMonth:(id)sender{
    [self switchToAppearance:JxCalendarAppearanceMonth withDate:nil];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
        [self.delegate calendarDidTransitionTo:[self getOverviewAppearance]];
    }
    
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    NSLog(@"viewWillTransitionToSize %f x %f", size.width, size.height);
    
    switch (self.style) {
        case JxCalendarOverviewStyleYearGrid:{
            self.collectionView.pagingEnabled = NO;
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size] animated:YES];
            
        }break;
        case JxCalendarOverviewStyleMonthGrid:{
            self.collectionView.pagingEnabled = NO;
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size] animated:YES];
            
        }break;
            
    }
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (JxCalendarAppearance)getAppearance{
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarDay class]]) {
        return JxCalendarAppearanceDay;
    }else if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarWeek class]]) {
        return JxCalendarAppearanceWeek;
    }else if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        return [self getOverviewAppearance];
    }
    return JxCalendarAppearanceNone;
}
- (JxCalendarAppearance)getOverviewAppearance{
    return [self getOverviewAppearanceFromStyle:self.style];
}
- (JxCalendarAppearance)getOverviewAppearanceFromStyle:(JxCalendarOverviewStyle)style{
    JxCalendarAppearance appearance;
    switch (style) {
        case JxCalendarOverviewStyleMonthGrid:
            appearance = JxCalendarAppearanceMonth;
            break;
            
        case JxCalendarOverviewStyleYearGrid:
            appearance = JxCalendarAppearanceYear;
            break;
    }
    return appearance;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)switchToNewYear:(NSInteger)year{
    
    NSDateComponents *startComponents = [self startComponents];
    
    [startComponents setYear:year];
    
    self.startDate = [[self calendar] dateFromComponents:startComponents];
    
    if (self.navigationController) {
        
        if ([self.delegate respondsToSelector:@selector(calendarTitleOnDate:whileOnAppearance:)]) {
            
            NSString *newTitle = [self.delegate calendarTitleOnDate:self.startDate whileOnAppearance:[self getOverviewAppearance]];
            
            if (newTitle) {
                self.navigationItem.title = newTitle;
            }
            
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"%ld", (long)startComponents.year];
        }
    }
}
- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year animated:(BOOL)animated{
    
    if ([self startComponents].year != year) {
        
        [self switchToNewYear:year];

        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            
        } completion:^(BOOL finished) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
            
            NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
            
            UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
            
            if (y < 0) {
                y = 0;
            }
            [self.collectionView setContentOffset:CGPointMake(0, y) animated:animated];
        }];
        
    }else{
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
        
        NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
        
        CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
        
        if (y < 0) {
            y = 0;
        }
        [self.collectionView setContentOffset:CGPointMake(0, y) animated:animated];
    }
    
}
- (void)scrollToDate:(NSDate *)date{
    
    NSIndexPath *path = [self getIndexPathForDate:date];
    
    NSLog(@"path %ld section %ld", (long)path.item, (long)path.section);
    
    [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}


- (void)switchToAppearance:(JxCalendarAppearance)newAppearance{
    [self switchToAppearance:newAppearance withDate:nil];
}
- (void)switchToAppearance:(JxCalendarAppearance)newAppearance withDate:(NSDate *)newDate{
    
//    NSDate *oldDate = self.startDate;
    
    if (!newDate) {
        newDate = self.startDate;
    }else{
        self.startDate = newDate;
    }
    
//    NSDateComponents *oldComponents =  [self componentsFromDate:oldDate];
//    NSDateComponents *newComponents =  [self componentsFromDate:newDate];
    
    JxCalendarAppearance oldAppearance = JxCalendarAppearanceYear;
    
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarDay class]]) {
        oldAppearance = JxCalendarAppearanceDay;
    }else if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarWeek class]]) {
        oldAppearance = JxCalendarAppearanceWeek;
    }else if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        oldAppearance = [self getOverviewAppearance];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
        [self.delegate calendarWillTransitionFrom:oldAppearance to:newAppearance];
    }
    
    
    if (oldAppearance < newAppearance && newAppearance > JxCalendarAppearanceMonth) {
        //was drauf setzen
        
        if (oldAppearance < JxCalendarAppearanceWeek) {
            JxCalendarWeek *vc = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
            vc.delegate = self.delegate;
            
            [self.navigationController pushViewController:vc animated:NO];
        }
        
        
        if (newAppearance == JxCalendarAppearanceDay) {
            
            JxCalendarDay *day = [[JxCalendarDay alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
            
            day.delegate = self.delegate;
            
            [self.navigationController pushViewController:day animated:NO];
        }
    }else{
        //zurück wandern
        if (newAppearance <= JxCalendarAppearanceMonth) {
            [self.navigationController popToViewController:self animated:NO];
            
            
            switch (newAppearance) {
                case JxCalendarAppearanceMonth:{
                    [self switchToMonthGridViewWithCallback:^(BOOL finished) {
                        NSDateComponents *startComponents = [self startComponents];
                        
                        [self scrollToMonth:startComponents.month inYear:startComponents.year animated:NO];
                    } animated:NO];
            }break;
                case JxCalendarAppearanceYear:{
                    self.style = JxCalendarOverviewStyleYearGrid;
                    
                    [self.collectionView reloadData];
                    [self.collectionView performBatchUpdates:^{
                        
                        self.collectionView.pagingEnabled = NO;
                        [self.collectionView.collectionViewLayout invalidateLayout];
                        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:self.view.frame.size] animated:NO];
                        
                        [self updateNavigationButtons];
                        
                    } completion:^(BOOL finished) {
                        
                        if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
                            [self.delegate calendarDidTransitionTo:JxCalendarAppearanceYear];
                        }
                    }];
                }break;
                default:
                    break;
            }
            
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
        
    }
    
    
    /*
        
    if (newAppearance > JxCalendarAppearanceMonth) {
        if (newDate) {
            self.startDate = newDate;
        }
        
        JxCalendarWeek *vc = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
        vc.delegate = self.delegate;
        
        [self.navigationController pushViewController:vc animated:NO];
        
        if (newAppearance == JxCalendarAppearanceDay) {
            
            
            
            JxCalendarDay *day = [[JxCalendarDay alloc] initWithDataSource:self.dataSource andSize:self.startSize andStartDate:self.startDate];
            
            day.delegate = self.delegate;
            
            [self.navigationController pushViewController:day animated:NO];
        }

        
    }else if(newAppearance == JxCalendarAppearanceMonth && self.style != JxCalendarOverviewStyleMonthGrid){
        [self.navigationController popToViewController:self animated:YES];
        
        [self switchToMonthGridViewWithCallback:^(BOOL finished) {
            [self scrollToMonth:newComponents.month inYear:newComponents.year];
            
            if (newDate) {
                self.startDate = newDate;
            }
        }];
        
        
        
    }else if(newAppearance == JxCalendarAppearanceYear && self.style != JxCalendarOverviewStyleYearGrid){
        [self.navigationController popToViewController:self animated:YES];
        
        [self switchToNewYear:newComponents.year];
        if (newDate) {
            self.startDate = newDate;
        }
        [self switchToYearGridView];
    }
    */
    
}
#pragma mark Gesture
- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    if (sender.state != UIGestureRecognizerStateChanged) {

    }
    
    
        
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:{
                NSLog(@"UIGestureRecognizerStateBegan");
                
                NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:point];
                
                if (path) {
                    
                    
                    if ([path isEqual:_longHoldStartIndexPath]) {
                        _longHoldStartIndexPath = _longHoldEndIndexPath;
                        _longHoldEndIndexPath = path;
                        
                    }else if ([path isEqual:_longHoldEndIndexPath]){
                        
                    }else{
                        _longHoldStartIndexPath = nil;
                        _longHoldEndIndexPath = nil;
                        
                        if ([self.dataSource respondsToSelector:@selector(isDaySelectable:)]) {
                            NSDate *date = [self getDateForIndexPath:path];
                            if (date) {
                                
                                if ([self.dataSource isDaySelectable:date]) {
                                    
                                    
                                    _longHoldStartIndexPath = path;
                                    
                                    
                                }
                            }
                        }
                    }
                    
                    
                    [self updateLongHoldSelectedCells];
                }
                
            }break;
            case UIGestureRecognizerStateChanged:{
                NSLog(@"UIGestureRecognizerStateChanged");
                if (_longHoldStartIndexPath) {
                    
                    
                    NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:point];
                    
                    if (path) {
                        
                        if ([self.dataSource respondsToSelector:@selector(isDaySelectable:)]) {
                            NSDate *date = [self getDateForIndexPath:path];
                            if (date) {
                                if ([self.dataSource isDaySelectable:date]) {
                                
                                
                                    _longHoldEndIndexPath = path;
                                    
                                    [self updateLongHoldSelectedCells];
                                }
                            }
                        }
                        
                        
                    }
                }
                
                }break;
            case UIGestureRecognizerStatePossible:
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:{
                NSLog(@"UIGestureRecognizerState ended / failed / cancelled");
                
                [self updateLongHoldSelectedCells];
                
                
                
//                _holdIndexPath = nil;
//                
//                if (_editing) {
//                    [page.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//                    
//                    [self.dataSource collectionViewDidEndDragging:self];
//                }
//                
//                self.pageViewController.view.userInteractionEnabled = YES;
                
            }break;
        }

}
- (void)updateLongHoldSelectedCells{
    
    NSMutableArray *updatePathes = [NSMutableArray array];
    
    if ([self.delegate respondsToSelector:@selector(calendarShouldClearSelections)]) {
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            
            NSIndexPath *thisPath = [self.collectionView indexPathForCell:cell];
            
            NSDate *thisDate = [self getDateForIndexPath:thisPath];
            
            if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:thisDate]) {
                [updatePathes addObject:thisPath];
            }
        }
        
        [self.delegate calendarShouldClearSelections];
    }
    
    
    if (_longHoldStartIndexPath) {
        if (_longHoldEndIndexPath) {
            
            NSIndexPath *start = _longHoldStartIndexPath;
            NSIndexPath *end = _longHoldEndIndexPath;
            
            if (_longHoldStartIndexPath.section > _longHoldEndIndexPath.section ||
                (_longHoldStartIndexPath.section == _longHoldEndIndexPath.section && _longHoldEndIndexPath.row < _longHoldStartIndexPath.row)) {
                
                start = _longHoldEndIndexPath;
                
                end = _longHoldStartIndexPath;
                
            }
            
            
            
            for (NSInteger section = start.section; section <= end.section; section++) {
                
                NSInteger startRow = start.row;
                NSInteger endRow = end.row;
                
                if (start.section != section) {
                    startRow = 0;
                }
                if (end.section != section) {
                    endRow = [self.collectionView numberOfItemsInSection:section];
                }
                
                for (NSInteger row = startRow; row <= endRow; row++) {
                    NSIndexPath *path = [NSIndexPath indexPathForItem:row inSection:section];
                    
                    NSDate *date = [self getDateForIndexPath:path];
                    if (date && [self.dataSource isDaySelectable:date]) {
                        [self.delegate calendarDidSelectDate:date whileOnAppearance:[self getAppearance]];
                        
                        if (![updatePathes containsObject:path]) {
                            [updatePathes addObject:path];
                        }
                        
                        NSLog(@"path %@", path);
                    }
                    
                }
            }
            
        }else{
            
            NSDate *date = [self getDateForIndexPath:_longHoldStartIndexPath];
            
            [self.delegate calendarDidSelectDate:date whileOnAppearance:[self getAppearance]];
        }
    }

    
    if (updatePathes.count > 0) {
        [self.collectionView reloadItemsAtIndexPaths:updatePathes];
    }
}

#pragma mark Layout
- (void)switchToYearGridView{
    

    JxCalendarOverviewStyle oldStyle = self.style;
    
    self.style = JxCalendarOverviewStyleYearGrid;
    
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
        [self.delegate calendarWillTransitionFrom:[self getOverviewAppearanceFromStyle:oldStyle] to:JxCalendarAppearanceYear];
    }
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:self.view.frame.size] animated:YES];
        
        [self updateNavigationButtons];
        
    } completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
            [self.delegate calendarDidTransitionTo:JxCalendarAppearanceYear];
        }
    }];

}

- (void)switchToMonthGridView{
    [self switchToMonthGridViewWithCallback:nil animated:YES];
}
- (void)switchToMonthGridViewWithCallback:(void (^)(BOOL finished))callback animated:(BOOL)animated{
    
    self.style = JxCalendarOverviewStyleMonthGrid;
    
    [self.collectionView reloadData];

    __block __typeof(callback)blockCallback = callback;
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:self.view.frame.size]
                                            animated:animated];
        
        [self updateNavigationButtons];
        
    } completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
            [self.delegate calendarDidTransitionTo:JxCalendarAppearanceMonth];
        }
        
        if (blockCallback) {
            
            blockCallback(finished);
        }
        
    }];
    
}
- (void)switchToWeekView{
    
    if ([self isKindOfClass:[JxCalendarWeek class]]) {
        
        
        
    }else{
        JxCalendarWeek *week = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.view.frame.size andStartDate:self.startDate];

        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        
        [viewControllers removeLastObject];
        
        if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
            [self.delegate calendarWillTransitionFrom:[self getOverviewAppearance] to:JxCalendarAppearanceWeek];
        }
        
        [viewControllers addObject:week];
        
        [self.navigationController setViewControllers:viewControllers animated:YES];
        
    }
    
}
#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 12;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSDate *current = [self getDateForIndexPath:indexPath];
    
    switch (self.style) {
        case JxCalendarOverviewStyleYearGrid:{
            JxCalendarLayoutYearGrid *layout = (JxCalendarLayoutYearGrid *)collectionViewLayout;
            
            return [layout sizeForItemAtIndexPath:indexPath];
        }break;
        case JxCalendarOverviewStyleMonthGrid:{
            JxCalendarLayoutMonthGrid *layout = (JxCalendarLayoutMonthGrid *)collectionViewLayout;
            
            return [layout sizeForItemAtIndexPath:indexPath];
        }break;

    }

    return CGSizeMake(0,1);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:section+1 inCalendar:[self calendar] andYear:[self startComponents].year];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:section+1 inCalendar:[self calendar] andYear:[self startComponents].year];
    
    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];
    NSDateComponents *lastComponents = [self componentsFromDate:lastDay];
    
    return lastComponents.day + [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + (7-[JxCalendarBasics normalizedWeekDay:lastComponents.weekday]);
}

- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:[self startComponents].year];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:[self startComponents].year];
    
    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];
    NSDateComponents *lastComponents = [self componentsFromDate:lastDay];
    
    NSInteger weekDay = [JxCalendarBasics normalizedWeekDay:firstComponents.weekday];
    
    if (indexPath.item+1 >= weekDay && lastComponents.day > (indexPath.item+1 - weekDay)) {
        NSDateComponents *comp = [JxCalendarBasics baseComponentsWithCalendar:[self calendar] andYear:[self startComponents].year];
        
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

    
    
    NSDateComponents *components = [self componentsFromDate:date];
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:components.month inCalendar:[self calendar] andYear:[self startComponents].year];
    
    NSLog(@"firstDay %@", firstDay);
    
    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];
    
    
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
            case JxCalendarOverviewStyleYearGrid:
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    titleLabel.font = [titleLabel.font fontWithSize:18];
                }else{
                    titleLabel.font = [titleLabel.font fontWithSize:14];
                }
                
                
                break;
            case JxCalendarOverviewStyleMonthGrid:
                titleLabel.font = [titleLabel.font fontWithSize:16];
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
    
    [[cell viewWithTag:999] removeFromSuperview];
    cell.vc = nil;
    
    if (thisDate) {
        
        NSDateComponents *dateComponents = [self componentsFromDate:thisDate];
        
        switch (self.style) {
            case JxCalendarOverviewStyleYearGrid:{
                cell.label.text = [NSString stringWithFormat:@"%li", (long)dateComponents.day];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    cell.label.font = [cell.label.font fontWithSize:14];
                }else{
                    cell.label.font = [cell.label.font fontWithSize:10];
                }
                cell.label.textAlignment = NSTextAlignmentCenter;
            }break;
            case JxCalendarOverviewStyleMonthGrid:{
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
        
        if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:thisDate]) {
            cell.layer.borderColor = [UIColor redColor].CGColor;
            //cell.backgroundColor = [UIColor redColor];
            cell.layer.borderWidth = 1.0f;
            cell.label.textColor = [UIColor redColor];
        }else{
            cell.layer.borderColor = self.collectionView.backgroundColor.CGColor;
            cell.layer.borderWidth = .0f;
            cell.label.textColor = [UIColor blackColor];
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
        cell.layer.borderColor = self.collectionView.backgroundColor.CGColor;
        cell.layer.borderWidth = .0f;
    }
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (self.style == JxCalendarStyleWeekGrid) {
//        return;
//    }
    __block NSDate *date = [self getDateForIndexPath:indexPath];
    
    if (date) {
        
        NSLog(@"date %@", date);
        
        if (self.style == JxCalendarOverviewStyleYearGrid) {
            
            __weak __typeof(self)weakSelf = self;
            [self switchToMonthGridViewWithCallback:^(BOOL finished) {
                //scroll to date
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                NSDateComponents *components = [self componentsFromDate:date];
                
                [strongSelf scrollToMonth:components.month inYear:components.year animated:YES];
                if ([strongSelf.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
                    [strongSelf.delegate calendarDidTransitionTo:JxCalendarAppearanceMonth];
                }
                
            } animated:YES];
        }else{
    
        //tagesansicht öffnen
//        [self.delegate calendarDidSelectDate:date whileOnAppearance:[self getAppearance]];
//        
//        JxCalendarLayoutDay *layout = [[JxCalendarLayoutDay alloc] initWithSize:self.collectionView.bounds.size
//                                                                         andDay:date];
//        
//        JxCalendarDay *vc = [[JxCalendarDay alloc] initWithCollectionViewLayout:layout];
//        layout.source = vc;
//        
//        vc.dataSource = self.dataSource;
//        nv.delegate = self.delegate;
//        
//        [nv setCurrentDate:date];
            
            if ([self.dataSource isDaySelected:date]) {
                if ([self.delegate respondsToSelector:@selector(calendarDidDeselectDate:whileOnAppearance:)]) {
                    [self.delegate calendarDidDeselectDate:date whileOnAppearance:[self getOverviewAppearance]];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(calendarDidSelectDate:whileOnAppearance:)]) {
                    [self.delegate calendarDidSelectDate:date whileOnAppearance:[self getOverviewAppearance]];
                }
            }
            
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
            if ([self.delegate respondsToSelector:@selector(calendarWillTransitionFrom:to:)]) {
                [self.delegate calendarWillTransitionFrom:[self getOverviewAppearance] to:JxCalendarAppearanceWeek];
            }
            JxCalendarWeek *vc = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.view.frame.size andStartDate:date];
            vc.delegate = self.delegate;
            
            if (self.navigationController) {
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }else{
        
        //[self.collectionView setContentOffset:CGPointMake(18000, 0)];
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
        
        BOOL startFromTop = YES;
        
        if (scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
            NSLog(@"gehe ein jahr zurück");
            
            [self switchToNewYear:[self startComponents].year-1];
            switchToDifferentYear = YES;
            startFromTop = NO;
        }else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
            NSLog(@"gehe ein jahr vor ");
            
            [self switchToNewYear:[self startComponents].year+1];
            switchToDifferentYear = YES;
        }
        
        if (switchToDifferentYear) {
            [self.collectionView reloadData];
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView.collectionViewLayout invalidateLayout];
                
            } completion:^(BOOL finished) {
                if (startFromTop) {
                    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
                }else{
                    [self.collectionView scrollRectToVisible:CGRectMake(0, self.collectionView.contentSize.height-10, 10, 10) animated:NO];
                }
                
            }];
        }
        
    }
}
@end
