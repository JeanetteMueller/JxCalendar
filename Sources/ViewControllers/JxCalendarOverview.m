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

@interface JxCalendarOverview () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) CGSize startSize;
@property (nonatomic, readwrite) JxCalendarSelectionStyle selectionStyle;
@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *longPressGesture;
@property (strong, nonatomic, readwrite) NSIndexPath *longHoldStartIndexPath;
@property (strong, nonatomic, readwrite) NSIndexPath *longHoldEndIndexPath;

@property (strong, nonatomic) NSTimer *moveTimer;
@property (nonatomic, readwrite) CGFloat direction;

@property (strong, nonatomic) NSDate *toolTipDate;

@end

@implementation JxCalendarOverview

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource
                andStyle:(JxCalendarOverviewStyle)style
                 andSize:(CGSize)size
            andStartDate:(NSDate *)date
      andStartAppearance:(JxCalendarAppearance)appearance
       andSelectionStyle:(JxCalendarSelectionStyle)selectionStyle{
    
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
    
        self.pullToSwitchYears = YES;
        
        self.startSize = size;
        self.style = style;
        self.startDate = date;
        self.startAppearance = appearance;
        self.dataSource = dataSource;
        self.selectionStyle = selectionStyle;
        
        if (!self.startDate) {
            
            self.startDate = [NSDate date];
        }
        
        NSLog(@"renderWeekDayLabels %d", self.renderWeekDayLabels);
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
    
    self.collectionView.backgroundColor = kJxCalendarBackgroundColor;
    
    NSString* const frameworkBundleID = @"de.themaverick.JxCalendar";
    NSBundle* bundle = [NSBundle bundleWithIdentifier:frameworkBundleID];

    // Register cell classes
    [self.collectionView registerClass:[JxCalendarCell class] forCellWithReuseIdentifier:@"JxCalendarCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarCell" bundle:bundle] forCellWithReuseIdentifier:@"JxCalendarCell"];
    
    [self.collectionView registerClass:[JxCalendarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarHeader" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    
    JxCalendarOverview *layout = (JxCalendarOverview *)self.collectionViewLayout;
    layout.renderWeekDayLabels = self.renderWeekDayLabels;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateSelectionStyle];
    
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
            case JxCalendarSelectionStyleRangeOnly:{
                self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
                self.longPressGesture.numberOfTouchesRequired = 1;
                if (self.selectionStyle == JxCalendarSelectionStyleRangeOnly) {
                    self.longPressGesture.minimumPressDuration = 0.1f;
                }else{
                    self.longPressGesture.minimumPressDuration = 0.5f;
                }
                
                [self.collectionView addGestureRecognizer:self.longPressGesture];
            }break;
                
            case JxCalendarSelectionStyleSelectOnly:
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
            if ([self.delegate respondsToSelector:@selector(calendarSelectionStyleSwitchable)] && [self.delegate calendarSelectionStyleSwitchable]) {
                
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
                }
                [buttons addObject:extraButton];
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
    
    
    if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
        [self.delegate calendarDidTransitionTo:[self getOverviewAppearance]];
    }
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    self.collectionView.pagingEnabled = NO;
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    switch (self.style) {
        case JxCalendarOverviewStyleYearGrid:{
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:size] animated:YES];
            
        }break;
        case JxCalendarOverviewStyleMonthGrid:{
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
            
            UICollectionViewLayoutAttributes *attributes = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            
            CGFloat y = attributes.frame.origin.y - 64 - [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:path].frame.size.height;
            
            if (y < 0) {
                y = 0;
            }
            [self.collectionView setContentOffset:CGPointMake(0, y) animated:animated];
        }];
        
    }else{
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:month-1];
        
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

#pragma mark Gesture

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
    
    CGPoint point = [sender locationInView:self.collectionView];
    
    self.direction = point.y;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
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
            
        }break;
    }

}
- (void)moveContent{
    CGFloat triggerOffset = 100;
    
    CGFloat move = 0;
    CGPoint point;
    
    if (self.direction - self.collectionView.contentOffset.y < triggerOffset) {
        move = (self.direction - self.collectionView.contentOffset.y) - triggerOffset;
        point = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + move);
    }
    
    if (self.direction - self.collectionView.contentOffset.y > self.collectionView.frame.size.height-triggerOffset) {
        move = (self.direction - self.collectionView.contentOffset.y)- (self.collectionView.frame.size.height-triggerOffset);
        point = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + move);
    }
    
    if (move != 0.0f) {
        [UIView animateWithDuration:self.moveTimer.timeInterval
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.collectionView.contentOffset = point;
                         } completion:^(BOOL finished) {
                             self.direction = self.direction + move;
                         }];
    }
}
- (void)updateLongHoldSelectedCells{
    
    NSMutableArray *oldPathes = [NSMutableArray array];
    NSMutableArray *newPathes = [NSMutableArray array];
    
    if ([self.delegate respondsToSelector:@selector(calendarShouldClearRange)]) {
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            
            NSIndexPath *thisPath = [self.collectionView indexPathForCell:cell];
            
            NSDate *thisDate = [self getDateForIndexPath:thisPath];
            
            if ([self.dataSource respondsToSelector:@selector(isPartOfRange:)] && [self.dataSource isPartOfRange:thisDate]) {
                [oldPathes addObject:thisPath];
            }
        }
        
        [self.delegate calendarShouldClearRange];
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
                        [self.delegate calendarDidRangeDate:date whileOnAppearance:[self getAppearance]];
                        
                        if (![newPathes containsObject:path]) {
                            [newPathes addObject:path];
                        }
                    }
                }
            }
            
        }else{
            
            NSDate *date = [self getDateForIndexPath:_longHoldStartIndexPath];
            
            if (date && [self.dataSource isDayRangeable:date]) {
                [self.delegate calendarDidRangeDate:date whileOnAppearance:[self getAppearance]];
                
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
        [self updateRangedCellsWithIndexPaths:updatePathes];
    }
}

- (void)updateRangedCellsWithIndexPaths:(NSArray *)pathes{
    
    for (JxCalendarCell *cell in self.collectionView.visibleCells) {
        
        NSIndexPath *thisPath = [self.collectionView indexPathForCell:cell];
        
        if ([pathes containsObject:thisPath]) {
            [self updateRangeForCell:cell atIndexPath:thisPath];
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
    
    [self.collectionView reloadData];
    
    __block __typeof(callback)blockCallback = callback;
    
    [self.collectionView performBatchUpdates:^{
        
        self.collectionView.pagingEnabled = NO;
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:layout animated:animated];
        
        for (JxCalendarCell *cell in self.collectionView.visibleCells) {
            [self updateRangeForCell:cell atIndexPath:[self.collectionView indexPathForCell:cell]];
        }
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            [self updateSelectionStyle];
            
            if ([self.delegate respondsToSelector:@selector(calendarDidTransitionTo:)]) {
                [self.delegate calendarDidTransitionTo:newAppearance];
            }
        }
        
        if (blockCallback) {
            
            blockCallback(finished);
        }
    }];
}

- (void)switchToWeekView{
    
    if ([self.navigationController.visibleViewController isKindOfClass:[JxCalendarWeek class]]) {
        
        //ist schon in der wochenansicht
        
    }else{
        JxCalendarWeek *week = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource
                                                                  andSize:self.view.frame.size
                                                             andStartDate:self.startDate];

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

    NSDateComponents *firstComponents = [self componentsFromDate:firstDay];

    NSInteger weekday = components.weekday-1;
    if (weekday < 1) {
        weekday = 7;
    }

    NSInteger extraCells = ([JxCalendarBasics normalizedWeekDay:firstComponents.weekday]-1);

    NSInteger row = ceil(((extraCells + components.day)-1) / 7);

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
    [self updateRangeForCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)updateRangeForCell:(JxCalendarCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    NSDate *thisDate = [self getDateForIndexPath:indexPath];
    
    cell.rangeDot.hidden = YES;
    cell.rangeFrom.hidden = YES;
    cell.rangeTo.hidden = YES;
    
    if (thisDate) {
        
        if ([self.dataSource respondsToSelector:@selector(isDayRangeable:)] &&
            [self.dataSource respondsToSelector:@selector(isPartOfRange:)] &&
            [self.dataSource respondsToSelector:@selector(isStartOfRange:)] &&
            [self.dataSource respondsToSelector:@selector(isEndOfRange:)]
            ) {
        
            if([self.dataSource isPartOfRange:thisDate]) {
                
                if ([self nextCellIsInRangeWithIndexPath:indexPath]) {
                    cell.rangeFrom.hidden = NO;
                }
                
                if ([self lastCellIsInRangeWithIndexPath:indexPath]) {
                    cell.rangeTo.hidden = NO;
                }
                
                if ([self lastCellIsInRangeWithIndexPath:indexPath] && [self nextCellIsInRangeWithIndexPath:indexPath]) {
                    cell.rangeDot.hidden = YES;
                }else{
                    cell.rangeDot.hidden = NO;
                    
                    if ([self.dataSource isStartOfRange:thisDate] || [self.dataSource isEndOfRange:thisDate]) {
                        cell.rangeDot.layer.borderColor = kJxCalendarRangeDotBorderColor.CGColor;
                        [cell.rangeDot.layer setBorderWidth:kJxCalendarRangeDotBorderWidth];
                    }else{
                        [cell.rangeDot.layer setBorderWidth:.0];
                    }
                }
                
                UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
                UICollectionViewLayoutAttributes *attr = [layout layoutAttributesForItemAtIndexPath:indexPath];
                
                CGSize cellSize = attr.frame.size;
                CGFloat borderHeightPercent = 80.0f;
                CGFloat dotHeightPercent = 80.0f;
                CGFloat spacing = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout minimumInteritemSpacing] / 2;
                
                cell.rangeDot.backgroundColor = kJxCalendarRangeDotBackgroundColor;
                cell.rangeFrom.backgroundColor = kJxCalendarRangeBackgroundColor;
                cell.rangeTo.backgroundColor = kJxCalendarRangeBackgroundColor;
                
                cell.rangeFrom.frame = CGRectMake((cellSize.width/2),
                                                  (cellSize.height-(cellSize.height/100*borderHeightPercent))/2,
                                                  cellSize.width/2 + spacing,
                                                  cellSize.height/100*borderHeightPercent);
                cell.rangeTo.frame = CGRectMake(-spacing,
                                                (cellSize.height-(cellSize.height/100*borderHeightPercent))/2,
                                                cellSize.width/2+spacing,
                                                cellSize.height/100*borderHeightPercent);
                
                cell.rangeDot.frame = CGRectMake((cellSize.width - (cellSize.height/100*dotHeightPercent))/2,
                                                 (cellSize.height/100*((100-dotHeightPercent)/2)),
                                                 (cellSize.height/100*dotHeightPercent),
                                                 (cellSize.height/100*dotHeightPercent));
                
                [cell.rangeDot.layer setCornerRadius:cell.rangeDot.frame.size.height/2];
                
            }
        }
    }
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
            if ([self.dataSource isPartOfRange:nextDate]) {
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
            if ([self.dataSource isPartOfRange:lastDate]) {
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
            cell.layer.borderColor = kJxCalendarSelectedDayBorderColor.CGColor;
            if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                cell.backgroundColor = kJxCalendarSelectedWeekendBackgroundColor;
            }else{
                cell.backgroundColor = kJxCalendarSelectedDayBackgroundColor;
            }
            cell.label.textColor = kJxCalendarSelectedDayTextColor;
        }
        if ([[UIColor colorWithCGColor:cell.layer.borderColor] isEqual:cell.backgroundColor]) {
            cell.layer.borderWidth = .0f;
        }else{
            cell.layer.borderWidth = 1.0f;
        }
        
        
        if ([self.dataSource numberOfEventsAt:thisDate] > 0) {
            cell.eventMarker.hidden = NO;
        }else{
            cell.eventMarker.hidden = YES;
        }
        
    }else{
        cell.label.text = @" ";
        cell.backgroundColor = kJxCalendarBackgroundColor;
        cell.eventMarker.hidden = YES;
        cell.layer.borderColor = self.collectionView.backgroundColor.CGColor;
        cell.layer.borderWidth = .0f;
    }
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((self.style == JxCalendarOverviewStyleMonthGrid || (self.style == JxCalendarOverviewStyleYearGrid && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ) && self.selectionStyle == JxCalendarSelectionStyleRangeOnly) {
        return;
    }
    
    __block NSDate *date = [self getDateForIndexPath:indexPath];
    
    if (date) {
        
        if (self.style == JxCalendarOverviewStyleYearGrid) {
            
            __weak __typeof(self)weakSelf = self;
            
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
            if ([self.dataSource isPartOfRange:date]) {
                
                NSLog(@"open range tooltip");
                
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                
                
                [self openToolTipAtRect:CGRectMake(cell.frame.origin.x-collectionView.contentOffset.x,
                                                   cell.frame.origin.y-collectionView.contentOffset.y,
                                                   cell.frame.size.width,
                                                   cell.frame.size.height)
                               withDate:date];
                
                return;
            }
            
            
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
    }
    
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideToolTip];
    
    NSLog(@"offset Y: %f", scrollView.contentOffset.y);
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
        if (self.pullToSwitchYears) {
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
}

#pragma mark tooltip
- (void)openToolTipAtRect:(CGRect)rect withDate:(NSDate *)date{
    
    [self hideToolTip];
    
    self.toolTipDate = date;
    
    CGSize toolTipSize = CGSizeMake(130, 80);
    
    CGRect toolTipRect = CGRectMake(rect.origin.x + (rect.size.width/2) - (toolTipSize.width/2), rect.origin.y-toolTipSize.height, toolTipSize.width, toolTipSize.height);
    
    if (toolTipRect.origin.x < 5) {
        toolTipRect.origin.x = 5;
    }
    if (toolTipRect.origin.x + toolTipRect.size.width > self.collectionView.frame.size.width) {
        toolTipRect.origin.x = self.collectionView.frame.size.width - toolTipRect.size.width - 5;
    }
    NSLog(@"abstand von oben %f", self.collectionView.contentOffset.y - toolTipRect.origin.y);
    
    if (toolTipRect.origin.y  < 5) {
        toolTipRect.origin.y = rect.origin.y+rect.size.height;
    }
    
    UIView *toolTipView = [[UIView alloc] initWithFrame:toolTipRect];
    

    toolTipView.tag = 8890;
    toolTipView.backgroundColor = [UIColor whiteColor];
    toolTipView.layer.shadowOffset = CGSizeMake(0, 0);
    toolTipView.layer.shadowOpacity = 0.75;
    toolTipView.layer.shadowRadius = 8;
    toolTipView.layer.cornerRadius = 8.f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, toolTipSize.width, 40)];
    label.tag = 8891;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:@"Helvetica-Neue" size:18];
    NSDateFormatter *formatter = [JxCalendarBasics defaultFormatter];
    formatter.dateFormat = @"dd.MM.YYYY";
    label.text = [formatter stringFromDate:date];
    [toolTipView addSubview:label];
    
    UIButton *dayTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, toolTipSize.width, 40)];
    dayTypeButton.tag = 8892;
    [dayTypeButton setTitle:@"Ganzer Tag >" forState:UIControlStateNormal];
    [dayTypeButton addTarget:self action:@selector(dayTypeChange:) forControlEvents:UIControlEventTouchUpInside];
    [dayTypeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    dayTypeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:12];
    [toolTipView addSubview:dayTypeButton];
    
    
//    toolTipView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
//    label.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
//    dayTypeButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
    
    [self.view addSubview:toolTipView];
    
}
- (void)hideToolTip{
    self.toolTipDate = nil;
    [[self.view viewWithTag:8890] removeFromSuperview];
}
- (void)updateToolTip{
    UIView *toolTipView = [self.view viewWithTag:8890];
    
    toolTipView.backgroundColor = [UIColor yellowColor];
}
- (IBAction)dayTypeChange:(id)sender{
    
    UIButton *dayTypeButton = sender;
    
    if ([dayTypeButton.titleLabel.text isEqualToString:@"Halber Tag >"]) {
        [dayTypeButton setTitle:@"Ganzer Tag >" forState:UIControlStateNormal];
    }else{
        [dayTypeButton setTitle:@"Halber Tag >" forState:UIControlStateNormal];
    }
    
    
//    UIViewController *vc = [[UIViewController alloc] init];
//    
//    vc.view.backgroundColor = [UIColor yellowColor];
//    
//    NSDateFormatter *formatter = [JxCalendarBasics defaultFormatter];
//    formatter.dateFormat = @"dd.MM.YYYY";
//    
//    vc.navigationItem.title = [formatter stringFromDate:_toolTipDate];
//    
////    [self.navigationController pushViewController:vc animated:YES];
//    
//    
//    
//    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeToolTipVC:)];
//    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    
//    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)closeToolTipVC:(id)sender{
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self updateToolTip];
        }];
    }
}
@end
