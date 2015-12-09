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

@interface JxCalendarDay ()

@property (nonatomic, readwrite) BOOL initialScrollDone;
@property (strong, nonatomic) UIView *zeiger;
@property (strong, nonatomic) NSTimer *zeigerPositionTimer;

@property (strong, nonatomic) NSDateComponents *currentComponents;
@property (strong, nonatomic) NSDate *now;
@property (strong, nonatomic) NSDateComponents *nowComponents;


@end

@implementation JxCalendarDay



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
                                                                        fromDate:_currentDate];
    
    [self loadNow];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setCurrentDate:_currentDate];
    
    
    
    
    
}
- (void)viewDidLayoutSubviews {
    
    // If we haven't done the initial scroll, do it once.
    if (!self.initialScrollDone) {
        self.initialScrollDone = YES;
        
        NSDate *now = [NSDate date];
        NSDateComponents *components = [[self.dataSource calendar] components:NSCalendarUnitHour fromDate:now];
        
        CGFloat offset = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:[NSIndexPath indexPathForItem:0 inSection:components.hour]].frame.origin.y - 64;
        
        [self.collectionView setContentOffset:CGPointMake(0, offset) animated:NO];
    
    
        if (_nowComponents.year == _currentComponents.year && _nowComponents.month == _currentComponents.month && _nowComponents.day == _currentComponents.day) {
            //aktueller tag ist heute
            
            //plaziere zeitzeiger
            
            if (!_zeiger) {
                self.zeiger = [[UIView alloc] init];
                _zeiger.backgroundColor = [UIColor redColor];
            }
            
            
            
            
            [self updateZeigerPosition];
            
            [self.collectionView addSubview:_zeiger];
            
        }
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.zeigerPositionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateZeigerPosition) userInfo:nil repeats:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [self.zeigerPositionTimer invalidate];
    self.zeigerPositionTimer = nil;
    
    [super viewWillDisappear:animated];
}
- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    
    self.navigationItem.title = [_defaultFormatter stringFromDate:self.currentDate];
}
- (void)loadNow{
    self.now = [NSDate date];
    
    self.nowComponents = [[self.dataSource calendar] components:( NSCalendarUnitHour |
                                                                 NSCalendarUnitMinute |
                                                                 NSCalendarUnitSecond |
                                                                 NSCalendarUnitDay |
                                                                 NSCalendarUnitMonth |
                                                                 NSCalendarUnitYear |
                                                                 NSCalendarUnitWeekday   )
                                                       fromDate:_now];
}
- (void)updateZeigerPosition{
    
    [self loadNow];
    
    _zeiger.frame = CGRectMake(60,
                               _nowComponents.hour*kCalendarLayoutDaySectionHeight + kCalendarLayoutDayHeaderHalfHeight + (kCalendarLayoutDaySectionHeight / 60*_nowComponents.minute),
                               self.collectionView.contentSize.width-70,
                               1);
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (JxCalendarEvent *)eventForIndexPath:(NSIndexPath *)indexPath{
    NSArray *eventHours = [_dataSource eventsAt:_currentDate];
    
    if (eventHours.count > indexPath.section) {
        NSArray *events = [eventHours objectAtIndex:indexPath.section];
        
        if (events.count > indexPath.item) {
            return [events objectAtIndex:indexPath.item];
        }
        
    }
    return nil;
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 25;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *eventHours = [_dataSource eventsAt:_currentDate];
    
    if (eventHours.count > section) {
        NSArray *events = [eventHours objectAtIndex:section];
        
        return events.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JxCalendarEventCell" forIndexPath:indexPath];
    

    JxCalendarEvent *event = [self eventForIndexPath:indexPath];
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag:333];
    
    textLabel.textColor = event.fontColor;
    
    textLabel.text = event.title;
    
    
    cell.backgroundColor = event.backgroundColor;
    [cell.layer setBorderColor:event.borderColor.CGColor];
    [cell.layer setBorderWidth:1.5f];
    
    
    [cell.layer setCornerRadius:5];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JxCalendarDayHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JxCalendarDayHeader" forIndexPath:indexPath];
        
        UILabel *titleLabel = [header viewWithTag:333];
        
        
        
        titleLabel.text = [NSString stringWithFormat:@"%ld Uhr", (long)indexPath.section % 24];
        header.backgroundColor = [UIColor clearColor];
        return header;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"indexpath %ld section %ld", (long)indexPath.item, (long)indexPath.section);
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
        
        BOOL switchToDifferentDay = NO;
        
        
        
        if (scrollView.contentOffset.y + scrollView.contentInset.top < -kPullToSwitchContextOffset) {
            NSLog(@"gehe einen Tag zurück");
            
            NSDate *newDate = [_currentDate dateByAddingTimeInterval:-(24 * 60 * 60)];
            
            [self setCurrentDate:newDate];
            switchToDifferentDay = YES;
        }else if (scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentInset.bottom > scrollView.contentSize.height+kPullToSwitchContextOffset){
            NSLog(@"gehe einen Tag vor ");
            
            NSDate *newDate = [_currentDate dateByAddingTimeInterval:(24 * 60 * 60)];
            
            [self setCurrentDate:newDate];
            switchToDifferentDay = YES;
        }
        
        if (switchToDifferentDay) {
            
            [self.collectionView reloadData];
            
            [self.collectionView.collectionViewLayout invalidateLayout];
            
            __weak __typeof(self)weakSelf = self;
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutDay alloc] initWithWidth:CGRectGetWidth(self.collectionView.bounds) andEvents:[self.dataSource eventsAt:_currentDate] andCalendar:[self.dataSource calendar]] animated:YES completion:^(BOOL finished) {
                
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                [strongSelf.collectionView setDirectionalLockEnabled:YES];
                [strongSelf.collectionView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
            }];
            
        }
        
    }
}
@end
