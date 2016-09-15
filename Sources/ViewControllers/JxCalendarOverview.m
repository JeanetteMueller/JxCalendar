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
#import "JxCalendarLayoutWeek.h"

#import "JxCalendarHeader.h"
#import "JxCalendarCell.h"

#import "JxCalendarDay.h"
#import "JxCalendarLayoutDay.h"
#import "JxCalendarBasics.h"
#import "JxCalendarWeek.h"
#import "JxCalendarRangeElement.h"
#import "JxCalendarOverview+ToolTip.h"


@interface JxCalendarOverview () <UIGestureRecognizerDelegate>

@property (assign, nonatomic, readwrite) CGSize startSize;
@property (assign, nonatomic, readwrite) JxCalendarSelectionStyle selectionStyle;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic) NSIndexPath *longHoldStartIndexPath;
@property (strong, nonatomic) NSIndexPath *longHoldEndIndexPath;

@property (strong, nonatomic) NSTimer *moveTimer;
@property (assign, nonatomic, readwrite) CGFloat direction;

@property (strong, nonatomic) NSMutableArray *visibleSections;

@property (assign, nonatomic, readwrite) JxCalendarScrollingStyle scrollingStyle;
@end

@implementation JxCalendarOverview

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource
                andStyle:(JxCalendarOverviewStyle)style
                 andSize:(CGSize)size
            andStartDate:(NSDate *)date
      andStartAppearance:(JxCalendarAppearance)appearance
       andSelectionStyle:(JxCalendarSelectionStyle)selectionStyle
       andScrollingStyle:(JxCalendarScrollingStyle)scrollingStyle{
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIScreen mainScreen].bounds.size;
    }
    
    if (appearance == JxCalendarAppearanceYear){
        style = JxCalendarOverviewStyleYearGrid;
    }else if (appearance == JxCalendarAppearanceMonth){
        style = JxCalendarOverviewStyleMonthGrid;
    }
    
    JxCalendarLayoutOverview *layout;
    switch (style) {
        case JxCalendarOverviewStyleYearGrid:
            layout = [[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size];
            break;
        case JxCalendarOverviewStyleMonthGrid:
            layout = [[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size];
            break;
    }
    
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        layout.renderWeekDayLabels = self.renderWeekDayLabels;
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        self.allowsManipulation = YES;
        self.visibleSections = [NSMutableArray array];
        self.scrollingStyle = scrollingStyle;
        self.lengthOfDayInHours = 24;
        
        self.startSize = size;
        self.style = style;
        self.startDate = date;
        self.startAppearance = appearance;
        self.dataSource = dataSource;
        self.selectionStyle = selectionStyle;
        self.scrollToCurrentTimeAndDate = YES;
        
        if (!self.startDate) {
            
            self.startDate = [NSDate new];
        }
        
        
        
    }
    return self;
}

- (NSMutableArray <JxCalendarRangeElement *> *)defineRangeForStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    
    NSMutableArray *dates = [NSMutableArray array];
    
    NSDateComponents *startComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:startDate];
    NSDate *start = [self.calendar dateFromComponents:startComponents];
    
    NSDateComponents *endComponents;
    if (endDate) {
        endComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:endDate];
    }else{
        endComponents = startComponents;
    }
    
    
    NSDate *end = [self.calendar dateFromComponents:endComponents];
    
    
    int days = 0;
    
    while ([start timeIntervalSince1970] + (24*60*60 *days) < [end timeIntervalSince1970]) {
        days++;
    }
    
    startComponents.hour = 23;
    startComponents.minute = 59;
    startComponents.second = 59;
    
    JxCalendarRangeElement *startRangeElement = [[JxCalendarRangeElement alloc]
                                                 initWithDate:start
                                                 andDayType:([start timeIntervalSince1970] != [end timeIntervalSince1970])?JxCalendarDayTypeFreeChoiceMax:JxCalendarDayTypeFreeChoice
                                                 withStartDate:startDate
                                                 andEndDate:[self.calendar dateFromComponents:startComponents]];
    
    [dates addObject:startRangeElement];
    
    if ([start timeIntervalSince1970] != [end timeIntervalSince1970]){
        for (int d = 1; d < days; d++) {
            
            [dates addObject:[[JxCalendarRangeElement alloc] initWithDate:[start dateByAddingTimeInterval:24*60*60*d]
                                                                             andDayType:JxCalendarDayTypeWholeDay
                                                                             inCalendar:self.calendar
                                                                    andMaximumDayLength:self.lengthOfDayInHours]];
        }
    
    
        endComponents.hour = 0;
        endComponents.minute = 59;
        endComponents.second = 59;
        endComponents.nanosecond = 0;
        
        JxCalendarRangeElement *endRangeElement = [[JxCalendarRangeElement alloc] initWithDate:end
                                                                                    andDayType:JxCalendarDayTypeFreeChoiceMin
                                                                                 withStartDate:[self.calendar dateFromComponents:endComponents]
                                                                                    andEndDate:endDate];
        
        
        
        [dates addObject:endRangeElement];
    }
    
    

    return dates;
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
    
    self.collectionView.backgroundColor = kJxCalendarBackgroundColor;
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];

    // Register cell classes
    [self.collectionView registerClass:[JxCalendarCell class] forCellWithReuseIdentifier:@"JxCalendarCell"];
    
    [self.collectionView registerClass:[JxCalendarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];

    JxCalendarOverview *layout = (JxCalendarOverview *)self.collectionViewLayout;
    layout.renderWeekDayLabels = self.renderWeekDayLabels;
    
}
- (void)calendarTapped:(id)sender{
    [self hideToolTip];
}
- (void)viewDidLayoutSubviews{
    
    if (!self.initialScrollDone) {
        
        [self scrollToInitialDate:NO];
    }
    [super viewDidLayoutSubviews];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    
    [self scrollToInitialDate:YES];
    
    return NO;
}
- (void)scrollToInitialDate:(BOOL)animated{
    NSIndexPath *indexPath = [self getIndexPathForDate:self.startDate];
    
    UICollectionViewLayoutAttributes *headerAttr = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                            atIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section]];
    
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:[self getStartYear]];
    NSIndexPath *lastIndexPath = [self getIndexPathForDate:lastDay];
    UICollectionViewLayoutAttributes *lastItemAttr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:lastIndexPath];
    
    if (lastItemAttr.frame.origin.y + lastItemAttr.frame.size.height - headerAttr.frame.origin.y > self.collectionView.frame.size.height) {
        
        /* current month height is larger then the visible container height */
        
        [self.collectionView setContentOffset:CGPointMake(0, [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.origin.y + [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.size.height/2 - self.collectionView.frame.size.height/2)
                                     animated:animated];
    }else{
        /* visible container height is larger then the month height */
        
        [self.collectionView setContentOffset:CGPointMake(0, headerAttr.frame.origin.y)
                                     animated:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateSelectionStyle];
    
    [self switchToNewYear:[self startComponents].year];
    
    switch (self.scrollingStyle) {
        case JxCalendarScrollingStyleEndlessScrolling:
            self.collectionView.showsVerticalScrollIndicator = NO;
            self.collectionView.showsHorizontalScrollIndicator = NO;
            break;
            
        default:
            break;
    }
    
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
}

- (void)updateSelectionStyle{
    
    int count = (int)self.collectionView.gestureRecognizers.count-1;
    for (int i = count; i >= 0; i--) {
        if ([self.collectionView.gestureRecognizers[i] isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self.collectionView removeGestureRecognizer:self.collectionView.gestureRecognizers[i]];
        }
    }
    if (self.style == JxCalendarOverviewStyleMonthGrid || (self.style == JxCalendarOverviewStyleYearGrid && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        switch (self.selectionStyle) {
            case JxCalendarSelectionStyleDefault:
            case JxCalendarSelectionStyleRangeOnly:
            case JxCalendarSelectionStyleMonthRangeSelect:{
                self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
                self.longPressGesture.numberOfTouchesRequired = 1;
                if (self.selectionStyle == JxCalendarSelectionStyleRangeOnly || self.selectionStyle == JxCalendarSelectionStyleMonthRangeSelect) {
                    self.longPressGesture.minimumPressDuration = 0.15f;
                }else{
                    self.longPressGesture.minimumPressDuration = 0.5f;
                }
                
                [self.collectionView addGestureRecognizer:self.longPressGesture];
            }break;
                
            case JxCalendarSelectionStyleSelectOnly:
                break;
            case JxCalendarSelectionStyleMonthDaySelect:
                break;
        }
    }
    
    [self updateNavigationButtons];
}

- (void)updateNavigationButtons{
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    if (![self.dataSource respondsToSelector:@selector(shouldDisplayNavbarButtonsWhileOnAppearance:)] ||
        [self.dataSource shouldDisplayNavbarButtonsWhileOnAppearance:[self getOverviewAppearance]]) {
        
        switch (self.style) {
            case JxCalendarOverviewStyleMonthGrid:{
                [buttons addObject:[[UIBarButtonItem alloc] initWithTitle:@"Year" style:UIBarButtonItemStylePlain target:self action:@selector(switchToYear:)]];
            }break;
            case JxCalendarOverviewStyleYearGrid:
                [buttons addObject:[[UIBarButtonItem alloc] initWithTitle:@"Month" style:UIBarButtonItemStylePlain target:self action:@selector(switchToMonth:)]];
                break;
            default:
                break;
        }
        
        if (self.style == JxCalendarOverviewStyleMonthGrid || (self.style == JxCalendarOverviewStyleYearGrid && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
            if ([self.delegate respondsToSelector:@selector(calendarSelectionStyleSwitchable:)] && [self.delegate calendarSelectionStyleSwitchable:[self getCalendarOverview]]) {
                
                UIBarButtonItem *extraButton;
                
                switch (self.selectionStyle) {
                    case JxCalendarSelectionStyleDefault:
                        extraButton = [[UIBarButtonItem alloc] initWithTitle:@"Default" style:UIBarButtonItemStylePlain target:self action:@selector(switchToSelectOnly:)];
                        break;
                    case JxCalendarSelectionStyleSelectOnly:
                        extraButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(switchToRangeOnly:)];
                        break;
                    case JxCalendarSelectionStyleRangeOnly:
                        extraButton = [[UIBarButtonItem alloc] initWithTitle:@"Range" style:UIBarButtonItemStylePlain target:self action:@selector(switchToDefault:)];
                        break;
                    default:
                        break;
                }
                if (extraButton) {
                    [buttons addObject:extraButton];
                }
                
            }
        }
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (IBAction)switchToSelectOnly:(id)sender{
    self.selectionStyle = JxCalendarSelectionStyleSelectOnly;
    
    [self updateSelectionStyle];
}

- (IBAction)switchToRangeOnly:(id)sender{
    self.selectionStyle = JxCalendarSelectionStyleRangeOnly;
    
    [self updateSelectionStyle];
}

- (IBAction)switchToDefault:(id)sender{
    self.selectionStyle = JxCalendarSelectionStyleDefault;
    
    [self updateSelectionStyle];
}

- (IBAction)switchToYear:(id)sender{
    [self switchToAppearance:JxCalendarAppearanceYear withDate:nil];
}

- (IBAction)switchToMonth:(id)sender{
    [self switchToAppearance:JxCalendarAppearanceMonth withDate:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    if ([self.delegate respondsToSelector:@selector(calendar:didTransitionTo:)]) {
        [self.delegate calendar:self didTransitionTo:[self getOverviewAppearance]];
    }
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.collectionView.pagingEnabled = NO;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        switch (self.style) {
            case JxCalendarOverviewStyleYearGrid:{
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size] animated:NO];
                
            }break;
            case JxCalendarOverviewStyleMonthGrid:{
                [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:size] animated:NO];
                
            }break;
                
        }
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            [self updateRangeForCell:cell atIndexPath:[self.collectionView indexPathForCell:cell] animated:NO];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    
    
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
        
        [self updateTitle];
    }
}

- (void)scrollToMonth:(NSInteger)month inYear:(NSInteger)year animated:(BOOL)animated{
    
    if ([self startComponents].year != year && self.scrollingStyle != JxCalendarScrollingStyleEndlessScrolling) {
        
        [self switchToNewYear:year];

        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            
        } completion:^(BOOL finished) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
            
            UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
            
            if (y < 0) {
                y = 0;
            }
            [self.collectionView setContentOffset:CGPointMake(0, y) animated:animated];
            
            [self updateRefreshViews];
        }];
        
    }else{
        NSInteger addExtraForYears = 0;
        if (self.scrollingStyle == JxCalendarScrollingStyleEndlessScrolling) {
            addExtraForYears = (year-1970) * 12;
        }
        
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1+addExtraForYears];
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
        
        CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
        
        if (y < 0) {
            y = 0;
        }
        [self.collectionView setContentOffset:CGPointMake(0, y) animated:animated];
    }
    
}

- (void)scrollToEvent:(JxCalendarEvent *)event{
    if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        [self scrollToDate:event.start];
    }else{
        
        id<JxCalendarScrollTo> vc = self.navigationController.viewControllers.lastObject;
        
        [vc scrollToEvent:event];
    }
}

- (void)scrollToDate:(NSDate *)date{
    if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        NSIndexPath *path = [self getIndexPathForDate:date];
        
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }else{
        
        id<JxCalendarScrollTo> vc = self.navigationController.viewControllers.lastObject;
        
        [vc scrollToDate:date];
    }
    
    
}

- (void)switchToAppearance:(JxCalendarAppearance)newAppearance{
    [self switchToAppearance:newAppearance withDate:nil];
}

- (void)switchToAppearance:(JxCalendarAppearance)newAppearance withDate:(NSDate *)newDate{

    if (newDate) {
        self.startDate = newDate;
    }

    JxCalendarAppearance oldAppearance = JxCalendarAppearanceYear;
    
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarDay class]]) {
        oldAppearance = JxCalendarAppearanceDay;
    }else if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarWeek class]]) {
        oldAppearance = JxCalendarAppearanceWeek;
    }else if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        oldAppearance = [self getOverviewAppearance];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendar:willTransitionFrom:to:)]) {
        [self.delegate calendar:self willTransitionFrom:oldAppearance to:newAppearance];
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
                    [self switchStyle:JxCalendarOverviewStyleMonthGrid
                         toAppearance:JxCalendarAppearanceMonth
                            andLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:self.view.frame.size]
                         withCallback:^(BOOL finished) {
                             NSDateComponents *startComponents = [self startComponents];
                             [self scrollToMonth:startComponents.month inYear:startComponents.year animated:NO];
                         }
                             animated:YES];
                    
                
            }break;
                case JxCalendarAppearanceYear:{
                    
                    [self switchStyle:JxCalendarOverviewStyleYearGrid
                         toAppearance:JxCalendarAppearanceYear
                            andLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:self.view.frame.size]
                         withCallback:nil
                             animated:YES];
                    
                }break;
                default:
                    break;
            }
            
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}
- (void)startRefreshForHeader{
    [super startRefreshForHeader];
}
- (void)startRefreshForFooter{
    [super startRefreshForFooter];
}
- (void)finishRefreshForHeader{
    [super finishRefreshForHeader];
}
- (void)finishRefreshForFooter{
    [super finishRefreshForFooter];
}

#pragma mark Gesture

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
    
    if (!_allowsManipulation) {
        return;
    }
    if ((![self.delegate respondsToSelector:@selector(calendarShouldStartRanging:)]) ||
        ([self.delegate respondsToSelector:@selector(calendarShouldStartRanging:)] && ![self.delegate calendarShouldStartRanging:[self getCalendarOverview]])
        ) {
        return;
    }
    
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    self.direction = point.y;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            [self hideToolTip];
            
            if ([self.delegate respondsToSelector:@selector(calendarDidStartRanging:)]) {
                [self.delegate calendarDidStartRanging:[self getCalendarOverview]];
            }
            
            NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:point];
            
            if (path) {
                NSDate *date = [self getDateForIndexPath:path];
                if (date) {
                    
                    
                    if ([path isEqual:_longHoldStartIndexPath]) {
                        _longHoldStartIndexPath = _longHoldEndIndexPath;
                        _longHoldEndIndexPath = path;
                    }else if ([self.dataSource isPartOfRange:date]) {
                        _longHoldEndIndexPath = path;
                    }else if ([path isEqual:_longHoldEndIndexPath]){
                        
                    }else{
                        _longHoldStartIndexPath = nil;
                        _longHoldEndIndexPath = nil;
                        
                        if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)]) {
                            
                            if ([self.dataSource isDayRangeable:date]) {
                                
                                _longHoldStartIndexPath = path;
                            }
                        }
                    }
                    
                }
                
                [self updateLongHoldSelectedCells];
            }
            
            self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(moveContent) userInfo:nil repeats:YES];
            
        }break;
        case UIGestureRecognizerStateChanged:{
            if (_longHoldStartIndexPath) {
                
                NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:point];
                
                if (path) {
                    
                    if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)]) {
                        NSDate *date = [self getDateForIndexPath:path];
                        if (date) {
                            if ([self.dataSource isDayRangeable:date]) {
                                
                                
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
            [self updateLongHoldSelectedCells];
            
            self.direction = .0f;
            [self.moveTimer invalidate];
            self.moveTimer = nil;
            
            if ([self.delegate respondsToSelector:@selector(calendarDidEndRanging:)]) {
                [self.delegate calendarDidEndRanging:[self getCalendarOverview]];
            }
            
            if (_longHoldStartIndexPath && _longHoldEndIndexPath && (_longHoldStartIndexPath.section > _longHoldEndIndexPath.section ||
                (_longHoldStartIndexPath.section == _longHoldEndIndexPath.section && _longHoldEndIndexPath.row < _longHoldStartIndexPath.row))) {
                NSIndexPath *tempStart = _longHoldStartIndexPath;
                _longHoldStartIndexPath = _longHoldEndIndexPath;
                _longHoldEndIndexPath = tempStart;
            }
            
        }break;
    }

}
- (void)moveContent{
    
    CGFloat triggerOffset = 100;
    
    CGFloat move = 0;
    
    if (self.direction - self.collectionView.contentOffset.y < triggerOffset) {
        move = (self.direction - self.collectionView.contentOffset.y) - triggerOffset;
    }
    
    if (self.direction - self.collectionView.contentOffset.y > self.collectionView.frame.size.height-triggerOffset) {
        move = (self.direction - self.collectionView.contentOffset.y)- (self.collectionView.frame.size.height-triggerOffset);
    }
    
    if (move != 0.0f) {
        [UIView animateWithDuration:self.moveTimer.timeInterval
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             if (self.direction - self.collectionView.contentOffset.y < triggerOffset) {
                                 self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + move);
                             }else if (self.direction - self.collectionView.contentOffset.y > self.collectionView.frame.size.height-triggerOffset) {
                                 self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + move);
                             }
                         } completion:^(BOOL finished) {
                             self.direction = self.direction + move;
                         }];
    }
}
- (void)updateLongHoldSelectedCells{
    
    NSMutableArray *oldPathes = [NSMutableArray array];
    NSMutableArray *newPathes = [NSMutableArray array];
    
  
    for (JxCalendarRangeElement *rangeElement in  [self.dataSource rangedDates]) {
        
        if ([self.dataSource respondsToSelector:@selector(isPartOfRange:)] && [self.dataSource isPartOfRange:rangeElement.date]) {
            NSIndexPath *thisPath = [self getIndexPathForDate:rangeElement.date];
            
            [oldPathes addObject:thisPath];
        }
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
                    if (date && [self.dataSource isDayRangeable:date]) {
                        
                        if (![newPathes containsObject:path]) {
                            [newPathes addObject:path];
                        }
                    }
                }
            }
            
        }else{
            
            NSDate *date = [self getDateForIndexPath:_longHoldStartIndexPath];
            
            if (date && [self.dataSource isDayRangeable:date]) {
                
                if (![newPathes containsObject:_longHoldStartIndexPath]) {
                    [newPathes addObject:_longHoldStartIndexPath];
                }
            }
        }
    }
    
    NSMutableArray *updatePathes = [NSMutableArray array];
    
    for (NSIndexPath *path in oldPathes) {
        if (![newPathes containsObject:path]) {
            [updatePathes addObject:path];
        }
    }
    for (NSIndexPath *path in newPathes) {
        if (![updatePathes containsObject:path]) {
            [updatePathes addObject:path];
        }
    }
    
    if (updatePathes.count > 0) {
        
        for (NSIndexPath *path in updatePathes) {
            NSDate *date = [self getDateForIndexPath:path];
            
            if ([self.dataSource respondsToSelector:@selector(isPartOfRange:)]){
                if ([self.dataSource isPartOfRange:date] && ![newPathes containsObject:path]) {
                    if ([self.delegate respondsToSelector:@selector(calendar:didDeRangeDate:whileOnAppearance:)]) {
                        [self.delegate calendar:[self getCalendarOverview] didDeRangeDate:date whileOnAppearance:self.appearance];
                    }
                    
                }else{
                    if (![self.dataSource isPartOfRange:date]){
                        
                        JxCalendarDayType newDayType = JxCalendarDayTypeWholeDay;
                        if ([self.dataSource respondsToSelector:@selector(defaultDayTypeForDate:)]) {
                            newDayType = [self.dataSource defaultDayTypeForDate:date];
                        }
                        
                        
                        JxCalendarRangeElement *element;
                        
                        if ([self.dataSource respondsToSelector:@selector(preparedRangeElementForDate:andDayType:andMaximumDayLength:)]) {
                            element = [self.dataSource preparedRangeElementForDate:date
                                                                        andDayType:newDayType
                                                               andMaximumDayLength:self.lengthOfDayInHours];
                        }
                        if(!element){
                            element = [[JxCalendarRangeElement alloc] initWithDate:date
                                                                        andDayType:newDayType
                                                                        inCalendar:self.dataSource.calendar
                                                               andMaximumDayLength:self.lengthOfDayInHours];
                        }
                        
                        if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
                            [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:self.appearance];
                        }
                    }
                }
            }
        }
        
        NSMutableArray *availableOptions = [NSMutableArray array];
        
        for (JxCalendarRangeElement *rangeElement in self.dataSource.rangedDates) {
            
            JxCalendarDayTypeMask mask = [self.dataSource availableDayTypesForDate:rangeElement.date];
            
            [availableOptions removeAllObjects];
            
            if ((mask & JxCalendarDayTypeMaskWholeDay) == JxCalendarDayTypeMaskWholeDay) {
                [availableOptions addObject:@(JxCalendarDayTypeWholeDay)];
            }
            if ((mask & JxCalendarDayTypeMaskWorkDay) == JxCalendarDayTypeMaskWorkDay) {
                [availableOptions addObject:@(JxCalendarDayTypeWorkDay)];
            }
            if ((mask & JxCalendarDayTypeMaskHalfDay) == JxCalendarDayTypeMaskHalfDay) {
                [availableOptions addObject:@(JxCalendarDayTypeHalfDay)];
            }
            if ((mask & JxCalendarDayTypeMaskHalfDayMorning) == JxCalendarDayTypeMaskHalfDayMorning) {
                [availableOptions addObject:@(JxCalendarDayTypeHalfDayMorning)];
            }
            if ((mask & JxCalendarDayTypeMaskHalfDayAfternoon) == JxCalendarDayTypeMaskHalfDayAfternoon) {
                [availableOptions addObject:@(JxCalendarDayTypeHalfDayAfternoon)];
            }
            if ((mask & JxCalendarDayTypeMaskFreeChoice) == JxCalendarDayTypeMaskFreeChoice) {
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoice)];
            }
            if ((mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin) {
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMin)];
            }
            if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax) {
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMax)];
            }
            
            
            JxCalendarDayType newDayType = JxCalendarDayTypeWholeDay;
            if ([self.dataSource respondsToSelector:@selector(defaultDayTypeForDate:)]) {
                newDayType = [self.dataSource defaultDayTypeForDate:rangeElement.date];
            }
            
            if (![availableOptions containsObject:@(rangeElement.dayType)]) {
                NSIndexPath *path = [self getIndexPathForDate:rangeElement.date];
                
                JxCalendarRangeElement *element;
                
                if ([self.dataSource respondsToSelector:@selector(preparedRangeElementForDate:andDayType:andMaximumDayLength:)]) {
                    element = [self.dataSource preparedRangeElementForDate:rangeElement.date
                                                                andDayType:newDayType
                                                       andMaximumDayLength:self.lengthOfDayInHours];
                }
                if(!element){
                    element = [[JxCalendarRangeElement alloc] initWithDate:rangeElement.date
                                                                andDayType:newDayType
                                                             withStartDate:rangeElement.start
                                                                andEndDate:rangeElement.end];
                }
                
                if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:self.appearance];
                }
                
                
                
                if (![updatePathes containsObject:path]) {
                    [updatePathes addObject:path];
                }
            }
            
            
        }
        
        [self updateRangedCellsWithIndexPaths:updatePathes];
    }
}

- (void)updateRangedCellsWithIndexPaths:(NSArray *)pathes{
    
    for (JxCalendarCell *cell in self.collectionView.visibleCells) {
        
        NSIndexPath *thisPath = [self.collectionView indexPathForCell:cell];
        
        if ([pathes containsObject:thisPath]) {
            [self updateRangeForCell:cell atIndexPath:thisPath animated:YES];
        }
    }
}

#pragma mark Layout

- (void)switchStyle:(JxCalendarOverviewStyle)newStyle
       toAppearance:(JxCalendarAppearance)newAppearance
          andLayout:(JxCalendarLayoutOverview *)layout
       withCallback:(void (^)(BOOL finished))callback
           animated:(BOOL)animated{
    
    self.style = newStyle;
    
    [self startUpdateRefreshViews];
    
    [self.collectionView reloadData];
    
    __block __typeof(callback)blockCallback = callback;
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:layout animated:animated];
        
        [self updateTitle];
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            NSIndexPath *path = [self.collectionView indexPathForCell:cell];
            [self updateCell:cell atIndexPath:path];
            [self updateRangeForCell:cell atIndexPath:path animated:NO];
        }
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self updateSelectionStyle];
            
            [self updateTitle];
            
            if ([self.delegate respondsToSelector:@selector(calendar:didTransitionTo:)]) {
                [self.delegate calendar:self didTransitionTo:newAppearance];
            }
        }
        
        [self updateRefreshViews];
        
        if (blockCallback) {
            
            blockCallback(finished);
        }
    }];
}

- (void)switchToWeekView{
    
    if (![self.navigationController.visibleViewController isKindOfClass:[JxCalendarWeek class]]) {
        
        JxCalendarWeek *week = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource
                                                                  andSize:self.view.frame.size
                                                             andStartDate:self.startDate];

        NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
        
        [viewControllers removeLastObject];
        
        if ([self.delegate respondsToSelector:@selector(calendar:willTransitionFrom:to:)]) {
            [self.delegate calendar:self willTransitionFrom:[self getOverviewAppearance] to:JxCalendarAppearanceWeek];
        }
        
        [viewControllers addObject:week];
        
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
}
- (void)updateContent{
    [self.collectionView reloadData];
}
- (void)updateContentForStartDate:(NSDate *)start till:(NSDate *)end{
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = 1;
    
    if (!end) {
        end = [self.dataSource.calendar dateByAddingComponents:comps toDate:start options:0];
    }
    
    NSDate *thisdate = start;
    while ( thisdate.timeIntervalSince1970 <= end.timeIntervalSince1970) {
        
        NSIndexPath *path = [self getIndexPathForDate:thisdate];
        
        JxCalendarCell *cell = (JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path];
        
        if (cell) {
            [self updateCell:cell atIndexPath:path];
            [self updateRangeForCell:cell atIndexPath:path animated:YES];
        }
        
        thisdate = [self.dataSource.calendar dateByAddingComponents:comps toDate:thisdate options:0];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.scrollingStyle == JxCalendarScrollingStyleEndlessScrolling){
        return 1200;
    }
    return 12;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
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
    
    NSInteger startYear = [self getStartYear];
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:section+1 inCalendar:[self calendar] andYear:startYear];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:section+1 inCalendar:[self calendar] andYear:startYear];
    
    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];
    NSDateComponents *lastComponents = [self componentsFromDate:lastDay];
    
    return lastComponents.day + [JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1 + (7-[JxCalendarBasics normalizedWeekDay:lastComponents.weekday]);
}

- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:[self getStartYear]];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:indexPath.section+1 inCalendar:[self calendar] andYear:[self getStartYear]];
    
    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];
    NSDateComponents *lastComponents = [self componentsFromDate:lastDay];
    
    NSInteger weekDay = [JxCalendarBasics normalizedWeekDay:firstComponents.weekday];
    
    if (indexPath.item+1 >= weekDay && lastComponents.day > (indexPath.item+1 - weekDay)) {
        NSDateComponents *comp = [JxCalendarBasics baseComponentsWithCalendar:[self calendar] andYear:[self getStartYear]];
        
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
- (NSInteger)getStartYear{
    if (self.scrollingStyle == JxCalendarScrollingStyleEndlessScrolling) {
        return 1970;
    }
    return [self startComponents].year;
}
- (NSIndexPath *)getIndexPathForDate:(NSDate *)date{
    
    NSDateComponents *components = [self componentsFromDate:date];
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:components.month inCalendar:[self calendar] andYear:components.year];

    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];

    NSInteger weekday = components.weekday-1;
    if (weekday < 1) {
        weekday = 7;
    }

    NSInteger extraCells = ([JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1);

    NSInteger row = ceil(((extraCells + components.day)-1) / 7);
    
    NSInteger addExtraYears = 0;
    
    if (self.scrollingStyle == JxCalendarScrollingStyleEndlessScrolling){
        addExtraYears = ((components.year-1970)*12);
    }
    
    return [NSIndexPath indexPathForItem:(row * 7 + (weekday-1)) inSection:components.month-1 + addExtraYears];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarFooter" forIndexPath:indexPath];
        
        return footer;
    }else {
        JxCalendarHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarHeader" forIndexPath:indexPath];
        [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calendarTapped:)]];
        header.clipsToBounds = YES;
        
        NSInteger month = indexPath.section+1;
        
        UIFont *titleFont, *subFont;
        
        switch (self.style) {
            case JxCalendarOverviewStyleYearGrid:
                header.titleLabel.textAlignment = NSTextAlignmentCenter;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
                    subFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
                }else{
                    titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
                    subFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
                }
                break;
            case JxCalendarOverviewStyleMonthGrid:
                header.titleLabel.textAlignment = NSTextAlignmentLeft;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:34];
                    subFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
                }else{
                    titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
                    subFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
                }
                break;
        }
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[[[JxCalendarBasics defaultFormatter] monthSymbols] objectAtIndex:(month-1)%12]
                                                                                  attributes:@{NSFontAttributeName: titleFont,
                                                                                               NSForegroundColorAttributeName: [UIColor redColor]}];
        
        if (self.style == JxCalendarOverviewStyleMonthGrid || YES) {
            
            [title appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %.0f", ([self getStartYear] + floor((month-1)/12.0f))]
                                                                          attributes:@{NSFontAttributeName: subFont,
                                                                                       NSForegroundColorAttributeName: [UIColor lightGrayColor]}]];
        }
        
        header.titleLabel.attributedText = title;
        //header.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
        return header;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"JxCalendarCell";
    
    JxCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self updateCell:cell atIndexPath:indexPath];
    [self updateRangeForCell:cell atIndexPath:indexPath animated:NO];

    return cell;
}

- (void)updateRangeForCell:(JxCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    
    NSDate *thisDate = [self getDateForIndexPath:indexPath];
    
    if (thisDate) {
        
        
        if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)] &&
            [self.dataSource respondsToSelector:@selector(isPartOfRange:)] &&
            [self.dataSource respondsToSelector:@selector(isStartOfRange:)] &&
            [self.dataSource respondsToSelector:@selector(isEndOfRange:)] &&
            [self.dataSource respondsToSelector:@selector(rangeElementForDate:)]
            ) {
            
            cell.rangeDotBackground.backgroundColor = kJxCalendarRangeDotBackgroundColor;
            cell.rangeDot.backgroundColor           = cell.backgroundColor;
            cell.rangeFrom.backgroundColor          = kJxCalendarRangeBackgroundColor;
            cell.rangeTo.backgroundColor            = kJxCalendarRangeBackgroundColor;
            
            if ([self.dataSource isStartOfRange:thisDate] && !_longHoldStartIndexPath) {
                _longHoldStartIndexPath = indexPath;
            }
            if ([self.dataSource isEndOfRange:thisDate] && !_longHoldEndIndexPath) {
                _longHoldEndIndexPath = indexPath;
            }
            
            JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:thisDate];
            
            void (^animation)(void) = ^{
                
                CGFloat partOfDay = 1.0;
                CGFloat startPosition = 0.0f;
                
                if([self.dataSource isDayRangeable:thisDate] &&  [self.dataSource isPartOfRange:thisDate]) {
                    if ([self nextCellIsInRangeWithIndexPath:indexPath]) {
                        cell.rangeFrom.alpha = 1.f;
                    }else{
                        cell.rangeFrom.alpha = 0.f;
                    }
                    
                    if ([self lastCellIsInRangeWithIndexPath:indexPath]) {
                        cell.rangeTo.alpha = 1.f;
                    }else{
                        cell.rangeTo.alpha = 0.f;
                    }
                    
                    if ([self lastCellIsInRangeWithIndexPath:indexPath] && [self nextCellIsInRangeWithIndexPath:indexPath]) {
                        cell.rangeDot.alpha = 0.0f;
                    }else{
                        cell.rangeDot.alpha = 1.f;
                        
                        if ([self.dataSource isStartOfRange:thisDate] || [self.dataSource isEndOfRange:thisDate]) {
                            cell.rangeDot.layer.borderColor = kJxCalendarRangeDotBorderColor.CGColor;
                            [cell.rangeDot.layer setBorderWidth:kJxCalendarRangeDotBorderWidth];
                        }else{
                            [cell.rangeDot.layer setBorderWidth:.0];
                        }
                    }
                    
                    partOfDay = rangeElement.duration / (float)(self.lengthOfDayInHours*60*60);
                    
                    if (rangeElement.dayType == JxCalendarDayTypeWholeDay || (rangeElement.dayType == JxCalendarDayTypeFreeChoice && rangeElement.duration +1 == self.lengthOfDayInHours*60*60)){
                        startPosition = .0f;
                        partOfDay = 1.f;
                    }else if (rangeElement.dayType == JxCalendarDayTypeHalfDayMorning) {
                        startPosition = 0.f;
                        partOfDay = .5f;
                    }else if (rangeElement.dayType == JxCalendarDayTypeHalfDayAfternoon) {
                        startPosition = .5f;
                        partOfDay = .5f;
                    }else if(rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin){
                        startPosition = .0f;
                        partOfDay = .5f;
                    }else if(rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax){
                        startPosition = .5f;
                        partOfDay = .5f;
                    }else if(partOfDay < 1.f){
                        startPosition = ((1-partOfDay)/2);
                        
                        if (!self.proportionalRangeTime && partOfDay != 1.0f) {
                            
                            partOfDay = .5;
                            NSDateComponents *components = [self.dataSource.calendar components:NSCalendarUnitHour fromDate:rangeElement.start];
                            if (components.hour < self.lengthOfDayInHours/2) {
                                startPosition = .0f;
                            }else{
                                startPosition = .5f;
                            }
                        }
                    }

                }else{
                    [self resetRangeForCell:cell];
                }
                
                JxCalendarRangeStyleInCell rangeStyle = JxCalendarRangeStyleInCellHorizontal;
                if ([self.dataSource respondsToSelector:@selector(rangeStyleForDate:)]) {
                    rangeStyle = [self.dataSource rangeStyleForDate:thisDate];
                }
                    
                UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
                UICollectionViewLayoutAttributes *attr = [layout layoutAttributesForItemAtIndexPath:indexPath];
                
                CGSize cellSize = attr.frame.size;
                CGFloat borderHeightPercent = 80.f;
                CGFloat dotHeightPercent = 80.f;
                CGFloat spacing = ceil([(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout minimumInteritemSpacing] / 2);
                
                cell.rangeDotBackground.backgroundColor = kJxCalendarRangeDotBackgroundColor;
                cell.rangeDot.backgroundColor           = cell.backgroundColor;
                cell.rangeFrom.backgroundColor          = kJxCalendarRangeBackgroundColor;
                cell.rangeTo.backgroundColor            = kJxCalendarRangeBackgroundColor;
                
                CGFloat cellSizeWidth = cellSize.width;
                CGFloat cellSizeWidthHalf = ceil(cellSize.width/2);
                
                CGFloat height = (cellSize.height/100*borderHeightPercent);
                
                switch (rangeStyle) {
                    case JxCalendarRangeStyleInCellVertical:{
                        cell.rangeFrom.frame = CGRectMake(cellSizeWidthHalf,
                                                          ((cellSize.height-height)/2) + (height * startPosition),
                                                          cellSizeWidthHalf + spacing,
                                                          height * partOfDay);
                        cell.rangeTo.hidden = NO;
                        cell.rangeTo.frame = CGRectMake(-spacing,
                                                        ((cellSize.height-height)/2) + height * startPosition,
                                                        cellSizeWidthHalf+spacing,
                                                        height * partOfDay);
                        
                        
                        cell.rangeDotBackground.frame = CGRectMake(0,
                                                                   0 + (cellSize.height/100*borderHeightPercent) * startPosition,
                                                                   (cellSize.height/100*dotHeightPercent),
                                                                   (cellSize.height/100*dotHeightPercent) *partOfDay);
                    }break;
                        
                    case JxCalendarRangeStyleInCellHorizontal:{
                        if ([self lastCellIsInRangeWithIndexPath:indexPath] && [self nextCellIsInRangeWithIndexPath:indexPath]) {
                            //im bereich
                            
                            cell.rangeTo.hidden = NO;
                            cell.rangeTo.frame = CGRectMake(cellSizeWidth * startPosition - ((startPosition == 0.0)?spacing:0),
                                                            ((cellSize.height-height)/2),
                                                            cellSizeWidth * partOfDay + ((startPosition == 0.0)?spacing:0),
                                                            height);
                            cell.rangeFrom.hidden = NO;
                            cell.rangeFrom.frame = CGRectMake(cellSizeWidth * startPosition - ((startPosition == 0.0)?spacing:0),
                                                              ((cellSize.height-height)/2),
                                                              cellSizeWidth * partOfDay + ((startPosition == 0.0)?spacing:0),
                                                              height);
                            
                        }else{
                            //endstück
                            if ([self lastCellIsInRangeWithIndexPath:indexPath]) {
                                //ende
                                cell.rangeTo.hidden = NO;
                                cell.rangeTo.frame = CGRectMake(-spacing,
                                                                ((cellSize.height-height)/2),
                                                                cellSizeWidthHalf+spacing,
                                                                height);
                                
                                cell.rangeFrom.hidden = YES;
                                cell.rangeFrom.frame = CGRectMake(cellSizeWidthHalf,
                                                                  ((cellSize.height-height)/2),
                                                                  cellSizeWidthHalf,
                                                                  height);
                            }else if([self nextCellIsInRangeWithIndexPath:indexPath]){
                                //anfang
                                cell.rangeTo.hidden = YES;
                                cell.rangeTo.frame = CGRectMake(-spacing,
                                                                ((cellSize.height-height)/2),
                                                                cellSizeWidthHalf+spacing,
                                                                height);
                                cell.rangeFrom.hidden = NO;
                                cell.rangeFrom.frame = CGRectMake(cellSizeWidthHalf,
                                                                  ((cellSize.height-height)/2),
                                                                  cellSizeWidthHalf+spacing,
                                                                  height);
                            }
                            
                        }
                        
                        cell.rangeDotBackground.frame = CGRectMake((cellSizeWidth/100*dotHeightPercent) * startPosition,
                                                                   0,
                                                                   (cellSizeWidth/100*dotHeightPercent)*partOfDay,
                                                                   (cellSize.height/100*dotHeightPercent) );
                    }break;
                }
                
                cell.rangeDot.frame = CGRectMake((cellSize.width - (cellSize.height/100*dotHeightPercent))/2,
                                                 (cellSize.height/100*((100-dotHeightPercent)/2)),
                                                 (cellSize.height/100*dotHeightPercent),
                                                 (cellSize.height/100*dotHeightPercent));
                
                [cell.rangeDot.layer setCornerRadius:cell.rangeDot.frame.size.height/2];
            
            };
            
            if (animated) {
                [UIView animateWithDuration:.2 animations:animation];
            }else{
                animation();
            }
        }else{
            [self resetRangeForCell:cell];
        }
    }else{
        [self resetRangeForCell:cell];
    }
}

- (void)resetRangeForCell:(JxCalendarCell *)cell{

    cell.rangeDot.alpha = 0.0f;
    cell.rangeFrom.alpha = 0.0f;
    cell.rangeTo.alpha = 0.0f;
}

- (BOOL)nextCellIsInRangeWithIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *nextPath;
    
    if ([self.collectionView numberOfItemsInSection:indexPath.section] > indexPath.item+1) {
        nextPath = [NSIndexPath indexPathForItem:indexPath.item+1 inSection:indexPath.section];
    }else if (self.collectionView.numberOfSections > indexPath.section){
        nextPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section+1];
    }
    if (nextPath) {
        NSDate *nextDate = [self getDateForIndexPath:nextPath];
        
        if (nextDate) {
            if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)] && [self.dataSource isDayRangeable:nextDate] && [self.dataSource respondsToSelector:@selector(isPartOfRange:)] && [self.dataSource isPartOfRange:nextDate]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)lastCellIsInRangeWithIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *lastPath;
    
    if (indexPath.item > 0) {
        lastPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    }else if(indexPath.section > 0){
        lastPath = [NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:indexPath.section-1]-1 inSection:indexPath.section-1];
    }
    
    if (lastPath) {
        NSDate *lastDate = [self getDateForIndexPath:lastPath];
        
        if (lastDate) {
            if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)] && [self.dataSource isDayRangeable:lastDate] &&
                [self.dataSource respondsToSelector:@selector(isPartOfRange:)] && [self.dataSource isPartOfRange:lastDate]) {
                return YES;
            }
        }
    }
    return NO;
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
            cell.backgroundColor = kJxCalendarWeekendBackgroundColor;
            cell.layer.borderColor = kJxCalendarWeekendBorderColor.CGColor;
            cell.label.textColor = kJxCalendarWeekendTextColor;
        }else{
            cell.backgroundColor = kJxCalendarDayBackgroundColor;
            cell.layer.borderColor = kJxCalendarDayBorderColor.CGColor;
            cell.label.textColor = kJxCalendarDayTextColor;
        }
        
        if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:thisDate]) {
            if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                cell.backgroundColor = kJxCalendarSelectedWeekendBackgroundColor;
            }else{
                cell.backgroundColor = kJxCalendarSelectedDayBackgroundColor;
            }
            cell.label.textColor = kJxCalendarSelectedDayTextColor;
        }
        
        if ([self.dataSource numberOfEventsAt:thisDate] > 0) {
            
            CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize];
            
            switch (self.style) {
                case JxCalendarOverviewStyleYearGrid:
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                        cell.eventMarker.frame = CGRectMake(itemSize.width/100*80,
                                                            itemSize.height/100*80,
                                                            itemSize.width/100*15,
                                                            itemSize.height/100*15);
                    }else{
                        cell.eventMarker.frame = CGRectMake(0,
                                                            itemSize.height/100*90,
                                                            itemSize.width,
                                                            itemSize.height/100*10);
                    }
                    break;
                case JxCalendarOverviewStyleMonthGrid:
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                        cell.eventMarker.frame = CGRectMake(itemSize.width/100*90,
                                                            itemSize.height/100*90,
                                                            itemSize.width/100*8,
                                                            itemSize.height/100*8);
                    }else{
                        cell.eventMarker.frame = CGRectMake(itemSize.width/100*80,
                                                            itemSize.height/100*80,
                                                            itemSize.width/100*15,
                                                            itemSize.height/100*15);
                    }
                    break;
            }
            
            cell.eventMarker.hidden = NO;
        }else{
            cell.eventMarker.hidden = YES;
        }
        
        NSDateComponents *now = [self componentsFromDate:[NSDate new]];
        if (dateComponents.day == now.day && dateComponents.month == now.month && dateComponents.year == now.year) {
            cell.contentView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.05];
            cell.contentView.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.2].CGColor;
            cell.contentView.layer.borderWidth = 1.0f;
            cell.contentView.layer.cornerRadius = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout itemSize].height/2;
        }else{
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.contentView.layer.borderWidth = 0.0f;
            cell.contentView.layer.cornerRadius = 0;
        }
        
    }else{
        cell.label.text = @" ";
        cell.backgroundColor = kJxCalendarBackgroundColor;
        cell.eventMarker.hidden = YES;
        cell.layer.borderColor = self.collectionView.backgroundColor.CGColor;
        cell.layer.borderWidth = .0f;
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.contentView.layer.borderWidth = 0.0f;
        cell.contentView.layer.cornerRadius = 0;
    }
    
    //cell.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.3];
}
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    [self updateStartVisibilitysForCollectionView:collectionView atIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self updateStartVisibilitysForCollectionView:collectionView atIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath{
    [self updateEndVisibilitysForCollectionView:collectionView atIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self updateEndVisibilitysForCollectionView:collectionView atIndexPath:indexPath];
}
- (void)updateStartVisibilitysForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath{
    if (![_visibleSections containsObject:@(indexPath.section)]) {
        [_visibleSections addObject:@(indexPath.section)];
        
        if ([self.dataSource respondsToSelector:@selector(calendar:willDisplayMonth:inYear:)]) {
            NSInteger month = [self getMonthFromIndexPath:indexPath];
            NSInteger year = [self getYearFromIndexPath:indexPath];
            [self.dataSource calendar:self willDisplayMonth:month inYear:year];
        }
    }
}
- (void)updateEndVisibilitysForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath{
    BOOL stillVisible = NO;
    
    for (NSIndexPath *cellPath in [collectionView indexPathsForVisibleItems]) {
        if (cellPath.section == indexPath.section) {
            stillVisible = YES;
        }
    }
    for (NSIndexPath *supplementaryPath in [collectionView indexPathsForVisibleSupplementaryElementsOfKind:UICollectionElementKindSectionHeader]) {
        if (supplementaryPath.section == indexPath.section) {
            stillVisible = YES;
        }
    }
    if (!stillVisible) {
        NSUInteger index = [_visibleSections indexOfObject:@(indexPath.section)];
        if (_visibleSections.count > index) {
            [_visibleSections removeObjectAtIndex:index];
            
            if ([self.dataSource respondsToSelector:@selector(calendar:didHideMonth:inYear:)]) {
                NSInteger month = [self getMonthFromIndexPath:indexPath];
                NSInteger year = [self getYearFromIndexPath:indexPath];
                [self.dataSource calendar:self didHideMonth:month inYear:year];
            }
        }
    }
}
- (NSInteger)getMonthFromIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.section % 12)+1;
}
- (NSInteger)getYearFromIndexPath:(NSIndexPath *)indexPath{
//    NSDateComponents *startComponents = [self getStartYear];
    return [self getStartYear] + floor(indexPath.section/12.0f) ;
}
#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    __block NSDate *date = [self getDateForIndexPath:indexPath];
    

    if (date) {
        
        if ((self.style == JxCalendarOverviewStyleMonthGrid || (self.style == JxCalendarOverviewStyleYearGrid && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ) &&
            (self.selectionStyle == JxCalendarSelectionStyleRangeOnly || self.selectionStyle == JxCalendarSelectionStyleMonthRangeSelect)) {
            
            if ([self.dataSource respondsToSelector:@selector(isPartOfRange:)] &&
                [self.dataSource respondsToSelector:@selector(isDayRangeable:)] && [self.dataSource isDayRangeable:date]) {
                
            
                if ([self.dataSource isPartOfRange:date] && [self.dataSource isRangeToolTipAvailableForDate:date]) {
                    [self openToolTipWithDate:date];
                    
                    
                }else{
                    [self hideToolTip];
                    
                    if ([self.dataSource isDayRangeable:date] && _allowsManipulation) {
                        if ([self.delegate respondsToSelector:@selector(calendarDidStartRanging:)]) {
                            [self.delegate calendarDidStartRanging:[self getCalendarOverview]];
                        }
                        
                        if (_longHoldStartIndexPath && _longHoldEndIndexPath && _longHoldStartIndexPath != _longHoldEndIndexPath) {
                            _longHoldStartIndexPath = nil;
                            _longHoldEndIndexPath = nil;
                        }
                        
                        if (!_longHoldStartIndexPath) {
                            _longHoldStartIndexPath = indexPath;
                            _longHoldEndIndexPath = nil;
                        }else if (_longHoldStartIndexPath && (!_longHoldEndIndexPath || _longHoldStartIndexPath == _longHoldEndIndexPath) ) {
                            _longHoldEndIndexPath = indexPath;
                        }else{
                            _longHoldStartIndexPath = indexPath;
                            _longHoldEndIndexPath = nil;
                        }
                        
                        [self updateLongHoldSelectedCells];
                        
                        if ([self.delegate respondsToSelector:@selector(calendarDidEndRanging:)]) {
                            [self.delegate calendarDidEndRanging:[self getCalendarOverview]];
                        }
                    }
                }
            }
            return;
        }
    
        if (self.style == JxCalendarOverviewStyleYearGrid) {
            
            __weak __typeof(self)weakSelf = self;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self.dataSource respondsToSelector:@selector(isPartOfRange:)] &&
                [self.dataSource respondsToSelector:@selector(isDayRangeable:)] && [self.dataSource isDayRangeable:date] && [self.dataSource isPartOfRange:date]) {
                
                [self openToolTipWithDate:date];
                
                return;
            }
            
            [self switchStyle:JxCalendarOverviewStyleMonthGrid
                 toAppearance:JxCalendarAppearanceMonth
                    andLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:self.view.frame.size]
                 withCallback:^(BOOL finished) {
                     //scroll to date
                     __strong __typeof(weakSelf)strongSelf = weakSelf;
                     
                     NSDateComponents *components = [self componentsFromDate:date];
                     
                     [strongSelf scrollToMonth:components.month inYear:components.year animated:YES];
                     
                     
                 }
                     animated:YES];
            
        }else{
            if ([self.dataSource respondsToSelector:@selector(isPartOfRange:)] &&
                [self.dataSource respondsToSelector:@selector(isDayRangeable:)] && [self.dataSource isDayRangeable:date] && [self.dataSource isPartOfRange:date]) {
                
                [self openToolTipWithDate:date];
                
                return;
            }else{
                [self hideToolTip];
            }
            
            if ([self.dataSource respondsToSelector:@selector(isDaySelected:)] && [self.dataSource isDaySelected:date]) {
                if ([self.delegate respondsToSelector:@selector(calendar:didDeselectDate:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didDeselectDate:date whileOnAppearance:[self getOverviewAppearance]];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(calendar:didSelectDate:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didSelectDate:date whileOnAppearance:[self getOverviewAppearance]];
                }
            }
            
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            
            if (self.selectionStyle != JxCalendarSelectionStyleMonthDaySelect) {
                if ([self.delegate respondsToSelector:@selector(calendar:willTransitionFrom:to:)]) {
                    [self.delegate calendar:self willTransitionFrom:[self getOverviewAppearance] to:JxCalendarAppearanceWeek];
                }
                JxCalendarWeek *vc = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.view.frame.size andStartDate:date];
                vc.delegate = self.delegate;
                
                if (self.navigationController) {
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [self presentViewController:vc animated:YES completion:nil];
                }
            }
            
            
        }
    }else{
        [self hideToolTip];
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideToolTip];
    
    [super scrollViewDidScroll:scrollView];
    
    
    if (self.scrollingStyle == JxCalendarScrollingStyleEndlessScrolling) {
        
        [self updateTitle];
    }
}
- (void)updateTitle{
    JxCalendarLayoutOverview *layout = (JxCalendarLayoutOverview *)self.collectionView.collectionViewLayout;
    
    CGSize sizeOfMonth = [layout sizeOfOneMonth];
    
    CGFloat origin = self.collectionView.contentOffset.y + self.collectionView.frame.size.height/2;
    
    NSInteger section = floor(origin / (sizeOfMonth.height + layout.sectionInset.top + layout.sectionInset.bottom));
    
    if ([self getOverviewAppearance] == JxCalendarAppearanceYear) {
        section = section * 3;
    }
    
    NSDate *date = [self getDateForIndexPath:[NSIndexPath indexPathForItem:7 inSection:section]];
    
    NSString *newTitle;
    
    if ([self.delegate respondsToSelector:@selector(calendar:titleOnDate:whileOnAppearance:)]) {
        
        newTitle = [self.delegate calendar:self titleOnDate:date whileOnAppearance:[self getOverviewAppearance]];
    }else{
        newTitle = [NSString stringWithFormat:@"%ld", (long)[self componentsFromDate:date].year];
    }
    
    if (newTitle) {
        self.navigationItem.title = newTitle;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
        if (self.scrollingStyle == JxCalendarScrollingStyleSwitchYearOnEdge) {
            
            BOOL switchToDifferentYear = NO;
            BOOL startFromTop = YES;
            
            if (scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
                [self switchToNewYear:[self startComponents].year-1];
                switchToDifferentYear = YES;
                startFromTop = NO;
            }else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
                [self switchToNewYear:[self startComponents].year+1];
                switchToDifferentYear = YES;
            }
            
            if (switchToDifferentYear) {
                [self startUpdateRefreshViews];
                [self.collectionView reloadData];
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView.collectionViewLayout invalidateLayout];
                } completion:^(BOOL finished) {
                    if (startFromTop) {
                        [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
                    }else{
                        [self.collectionView scrollRectToVisible:CGRectMake(0, self.collectionView.contentSize.height-10, 10, 10) animated:NO];
                    }
                    [self updateRefreshViews];
                }];
            }
        }
    }
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

@end
