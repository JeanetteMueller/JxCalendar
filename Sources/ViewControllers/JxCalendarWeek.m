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
#import "JxCalendarHeader.h"
#import "JxCalendarWeekEventCell.h"
#import "JxCalendarEvent.h"
#import "JxCalendarEventDay.h"
#import "JxCalendarDayHeader.h"

@interface JxCalendarWeek ()

@property (nonatomic, readwrite) BOOL initialScrollDone;

@end

@implementation JxCalendarWeek

- (id)initWithDataSource:(id<JxCalendarDataSource>)dataSource andSize:(CGSize)size{
    
    JxCalendarLayoutWeek *layout = [[JxCalendarLayoutWeek alloc] initWithSize:size];
    
    self = [super initWithCollectionViewLayout:layout];
    
    layout.source = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    if (self) {
        self.dataSource = dataSource;
    }
    return self;
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
    
    
    [self.collectionView registerClass:[JxCalendarHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JxCalendarHeader" bundle:bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JxCalendarHeader"];
    

    // Do any additional setup after loading the view.
    
    
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %ld", [[[JxCalendarBasics defaultFormatter] monthSymbols] objectAtIndex:_startMonth-1], (long)_startYear];
    }
    
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake([(JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout headerReferenceSize].height, 0, 0, 0);
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    NSLog(@"viewWillTransitionToSize %f x %f", size.width, size.height);
    
    
    
    //    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    

            self.collectionView.pagingEnabled = NO;
            
            [self.collectionView.collectionViewLayout invalidateLayout];
    
    JxCalendarLayoutWeek *layout = [[JxCalendarLayoutWeek alloc] initWithSize:size];
    layout.source = self;
    
            [self.collectionView setCollectionViewLayout:layout animated:NO];
            
   
    
    
    //    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    //
    //    }];
    
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    JxCalendarLayoutWeek *layout = (JxCalendarLayoutWeek *)self.collectionView.collectionViewLayout;
    
    if (!self.initialScrollDone) {
        self.initialScrollDone = YES;
        NSDate *now = [NSDate date];
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:now];
        

        
        [self.collectionView setContentOffset:CGPointMake(0, components.hour*(60*kCalendarLayoutDaySectionHeightMultiplier) + (3*(kCalendarLayoutWholeDayHeight+layout.minimumLineSpacing))-kCalendarLayoutDayHeaderHalfHeight) animated:NO];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:_startMonth inCalendar:[self calendar] andYear:_startYear];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:_startMonth inCalendar:[self calendar] andYear:_startYear];
    
    
    NSDateComponents *firstComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
                                                           fromDate:firstDay];
    
    NSDateComponents *lastComponents = [[self calendar] components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitWeekday   )
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
    textLabel.textColor = e.fontColor;
    
    if ([e isKindOfClass:[JxCalendarEventDay class]]) {
        JxCalendarEventDay *event = (JxCalendarEventDay *)e;
        textLabel.text = event.title;
    }else{
        textLabel.text = @"";
    }
    
    cell.backgroundColor = e.backgroundColor;
    [cell.layer setBorderColor:e.borderColor.CGColor];
    [cell.layer setBorderWidth:1.5f];
    
    
    [cell.layer setCornerRadius:5];
    
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarHeader" forIndexPath:indexPath];
        header.clipsToBounds = YES;
        UILabel *titleLabel = [header viewWithTag:333];
        
        NSDate *thisDate = [self getDateForSection:indexPath.section];
        if (thisDate) {
            NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekday
                                                                  fromDate:thisDate];
            
            
            NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
            [weekday setDateFormat: @"EEEE"];
            
            
            titleLabel.text = [NSString stringWithFormat:@"%li.\n%@", (long)dateComponents.day, [weekday stringFromDate:thisDate]];
            
            
            if ([JxCalendarBasics normalizedWeekDay:dateComponents.weekday] > 5) {
                header.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
            }else{
                header.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1];
            }
            
        }else{
            titleLabel.text = @"";
            header.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1];
        }
        
        
        
        
        return header;
    }
    return nil;
}
- (NSDate *)getDateForSection:(NSInteger)section{
    
    NSDate *firstDay = [JxCalendarBasics firstDayOfMonth:_startMonth inCalendar:[self calendar] andYear:_startYear];
    NSDate *lastDay = [JxCalendarBasics lastDayOfMonth:_startMonth inCalendar:[self calendar] andYear:_startYear];
    
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
        NSDateComponents *comp = [JxCalendarBasics baseComponentsWithCalendar:[self calendar] andYear:_startYear];
        
        NSInteger month = _startMonth;
        
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
