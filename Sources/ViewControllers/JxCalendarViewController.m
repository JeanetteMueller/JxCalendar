//
//  JxCalendarViewController.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import "JxCalendarViewController.h"
#import "JxCalendarLayoutYearGrid.h"
#import "JxCalendarLayoutMonthGrid.h"
#import "JxCalendarDay.h"
#import "JxCalendarWeek.h"
#import "JxCalendarOverview.h"
#import "JxCalendarLayoutWeek.h"


@interface JxCalendarViewController ()

@property (nonatomic, strong) UIView *pullToRefreshHeader;
@property (nonatomic, strong) UIView *pullToRefreshFooter;
@property (nonatomic) UIEdgeInsets originalInsets;
@property (nonatomic, readwrite) BOOL isInRangeForRefreshHeader;
@property (nonatomic, readwrite) BOOL isInRangeForRefreshFooter;

@end

@implementation JxCalendarViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.renderWeekDayLabels = YES;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.renderWeekDayLabels = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    if ([self.dataSource respondsToSelector:@selector(viewForPullToRefreshHeaderWhileOnAppearance:)]) {
        _pullToRefreshHeader = [self.dataSource viewForPullToRefreshHeaderWhileOnAppearance:[self getAppearance]];
        if (_pullToRefreshHeader) {
            _pullToRefreshHeader.clipsToBounds = YES;
            [self.collectionView addSubview:_pullToRefreshHeader];
        }
        
    }
    if ([self.dataSource respondsToSelector:@selector(viewForPullToRefreshFooterWhileOnAppearance:)]) {
        _pullToRefreshFooter = [self.dataSource viewForPullToRefreshFooterWhileOnAppearance:[self getAppearance]];
        if (_pullToRefreshFooter) {
            _pullToRefreshFooter.clipsToBounds = YES;
            [self.collectionView addSubview:_pullToRefreshFooter];
        }
    }
    
    [self updateRefreshViews];
}

- (void)viewDidLayoutSubviews{
    if (!self.initialScrollDone) {
        self.initialScrollDone = YES;
    }
    [super viewDidLayoutSubviews];
}

- (IBAction)closeCalendar:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.originalInsets = self.collectionView.contentInset;
    if (self.presentingViewController) {
        
        if (self.navigationController.viewControllers.count == 1) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeCalendar:)];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self startUpdateRefreshViews];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        [self updateRefreshViews];
    }];
}

- (void)startUpdateRefreshViews{
    _pullToRefreshHeader.hidden = YES;
    _pullToRefreshFooter.hidden = YES;
}

- (void)updateRefreshViews{
    if (_pullToRefreshHeader) {
        _pullToRefreshHeader.frame = CGRectMake(self.collectionView.contentOffset.x, -kPullToSwitchContextOffset, self.collectionView.contentSize.width, _pullToRefreshHeader.frame.size.height);
        _pullToRefreshHeader.hidden = NO;
    }
    if (_pullToRefreshFooter) {
        _pullToRefreshFooter.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y+self.collectionView.frame.size.height-_pullToRefreshHeader.frame.size.height, self.collectionView.contentSize.width, _pullToRefreshHeader.frame.size.height);
        _pullToRefreshFooter.hidden = NO;
    }
}

- (void)startRefreshForHeader{
    _pullToRefreshHeader.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.contentSize.width, _pullToRefreshHeader.frame.size.height);

    [UIView animateWithDuration:kPullToSwitchContextAnimationDuration animations:^{
        _pullToRefreshHeader.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, kPullToSwitchContextOffset);
        
        self.collectionView.contentInset = UIEdgeInsetsMake(kPullToSwitchContextOffset, self.collectionView.contentInset.left, self.collectionView.contentInset.bottom, self.collectionView.contentInset.right);
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }];
    
}

- (void)startRefreshForFooter{
    _pullToRefreshFooter.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y+self.collectionView.frame.size.height-_pullToRefreshFooter.frame.size.height, self.collectionView.contentSize.width, _pullToRefreshFooter.frame.size.height);
    
    [UIView animateWithDuration:kPullToSwitchContextAnimationDuration animations:^{
        _pullToRefreshFooter.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y+self.collectionView.frame.size.height-kPullToSwitchContextOffset, self.collectionView.frame.size.width, kPullToSwitchContextOffset);
        
        self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top, self.collectionView.contentInset.left, kPullToSwitchContextOffset, self.collectionView.contentInset.right);
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }];
}

- (void)finishRefreshForHeader{
    [UIView animateWithDuration:kPullToSwitchContextAnimationDuration animations:^{
        
        _pullToRefreshHeader.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, 0);
        self.collectionView.contentInset = UIEdgeInsetsMake(_originalInsets.top, _originalInsets.left, self.collectionView.contentInset.bottom, _originalInsets.right);
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }];
}

- (void)finishRefreshForFooter{
    [UIView animateWithDuration:kPullToSwitchContextAnimationDuration animations:^{
        _pullToRefreshFooter.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y+self.collectionView.frame.size.height, self.collectionView.frame.size.width, 0);
        self.collectionView.contentInset = UIEdgeInsetsMake(self.collectionView.contentInset.top, _originalInsets.left, _originalInsets.bottom, _originalInsets.right);
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    }];
    
}

#pragma mark -

- (JxCalendarAppearance)getAppearance{
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarDay class]]) {
        return JxCalendarAppearanceDay;
    }else if ([self.navigationController.viewControllers.lastObject isKindOfClass:[JxCalendarWeek class]]) {
        return JxCalendarAppearanceWeek;
    }else if ([self.navigationController.viewControllers.lastObject isEqual:self]) {
        return [[self getCalendarOverview] getOverviewAppearance];
    }
    return JxCalendarAppearanceNone;
}

- (NSDateComponents *)startComponents{
    return [self componentsFromDate:self.startDate];
}

- (NSDateComponents *)componentsFromDate:(NSDate *)date{
    return [[self.dataSource calendar] components:(NSCalendarUnitHour |
                                                   NSCalendarUnitMinute |
                                                   NSCalendarUnitSecond |
                                                   NSCalendarUnitDay |
                                                   NSCalendarUnitMonth |
                                                   NSCalendarUnitYear |
                                                   NSCalendarUnitWeekday   )
                                         fromDate:date];
}

- (JxCalendarOverview *)getCalendarOverview{
    JxCalendarOverview *calendar;
    
    for (int i = (int)self.navigationController.viewControllers.count-1; i >= 0; i--) {
        UIViewController *vc = self.navigationController.viewControllers[i];
        if ([vc isKindOfClass:[JxCalendarOverview class]]) {
            calendar = (JxCalendarOverview *)vc;
        }
    }
    return calendar;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(calendarDidScroll:whileOnAppearance:)]) {
        [self.delegate calendar:self didScroll:scrollView.contentOffset whileOnAppearance:[self getAppearance]];
    }
    
    
    
    if (_pullToRefreshHeader) {
        CGRect headerRect = _pullToRefreshHeader.frame;
        if (scrollView.contentOffset.y+scrollView.contentInset.top < 0) {
            if ((scrollView.contentOffset.y*-1) < kPullToSwitchContextOffset) {
                headerRect.size = CGSizeMake(scrollView.frame.size.width, (scrollView.contentOffset.y*-1));
            }else{
                headerRect.size = CGSizeMake(scrollView.frame.size.width, kPullToSwitchContextOffset);
            }
        }else{
            headerRect.size = CGSizeMake(scrollView.frame.size.width, scrollView.contentInset.top);
        }
        headerRect.origin = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y);
        _pullToRefreshHeader.frame = headerRect;
        
        if (scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
            if (!_isInRangeForRefreshHeader) {
                _isInRangeForRefreshHeader = YES;
                if ([self.delegate respondsToSelector:@selector(calendar:didReachRefreshOffsetForHeader:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didReachRefreshOffsetForHeader:_pullToRefreshHeader whileOnAppearance:[self getAppearance]];
                }
            }
        }else{
            if (_isInRangeForRefreshHeader) {
                _isInRangeForRefreshHeader = NO;
                
                if ([self.delegate respondsToSelector:@selector(calendar:didLeftRefreshOffsetForHeader:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didLeftRefreshOffsetForHeader:_pullToRefreshHeader whileOnAppearance:[self getAppearance]];
                }
            }
        }
    }
    
    
    if (_pullToRefreshFooter) {
        CGRect footerRect = _pullToRefreshFooter.frame;
        if (scrollView.contentOffset.y+scrollView.frame.size.height-scrollView.contentInset.bottom > scrollView.contentSize.height) {
            if ((scrollView.contentOffset.y+scrollView.frame.size.height)-scrollView.contentSize.height < kPullToSwitchContextOffset) {
                footerRect.size = CGSizeMake(scrollView.frame.size.width, (scrollView.contentOffset.y+scrollView.frame.size.height)-scrollView.contentSize.height);
            }else{
                footerRect.size = CGSizeMake(scrollView.frame.size.width, kPullToSwitchContextOffset);
            }
        }else{
            footerRect.size = CGSizeMake(scrollView.frame.size.width, scrollView.contentInset.bottom);
        }
        footerRect.origin = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y+scrollView.frame.size.height-footerRect.size.height);
        _pullToRefreshFooter.frame = footerRect;
        if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
            if (!_isInRangeForRefreshFooter) {
                _isInRangeForRefreshFooter = YES;
                if ([self.delegate respondsToSelector:@selector(calendar:didReachRefreshOffsetForFooter:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didReachRefreshOffsetForFooter:_pullToRefreshFooter whileOnAppearance:[self getAppearance]];
                }
            }
        }else{
            if (_isInRangeForRefreshFooter) {
                _isInRangeForRefreshFooter = NO;
                if ([self.delegate respondsToSelector:@selector(calendar:didLeftRefreshOffsetForFooter:whileOnAppearance:)]) {
                    [self.delegate calendar:[self getCalendarOverview] didLeftRefreshOffsetForFooter:_pullToRefreshFooter whileOnAppearance:[self getAppearance]];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate) {
        
        if (_pullToRefreshHeader && scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
            if ([self.delegate respondsToSelector:@selector(calendar:didRefreshByHeader:whileOnAppearance:)]) {
                [self.delegate calendar:[self getCalendarOverview] didRefreshByHeader:_pullToRefreshHeader whileOnAppearance:[self getAppearance]];
            }
        }
        
        if (_pullToRefreshFooter && scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
            if ([self.delegate respondsToSelector:@selector(calendar:didRefreshByFooter:whileOnAppearance:)]) {
                [self.delegate calendar:[self getCalendarOverview] didRefreshByFooter:_pullToRefreshFooter whileOnAppearance:[self getAppearance]];
            }
        }
    }
}

@end
