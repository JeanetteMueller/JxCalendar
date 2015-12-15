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
#import "JxCalendarLayoutWeekGrid.h"
#import "JxCalendarWeek.h"
#import "JxCalendarLayoutWeek.h"

@interface JxCalendarViewController ()

@end

@implementation JxCalendarViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
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
                                                [[UIBarButtonItem alloc] initWithTitle:@"Week" style:UIBarButtonItemStylePlain target:self action:@selector(switchToWeekView)]];
    
    if (self.presentingViewController) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeCalendar:)];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark <UICollectionViewDelegate>

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


#pragma mark Switch Layout
- (void)switchToYearGridView{
    
    if ([self isKindOfClass:[JxCalendarOverview class]]) {
        self.style = JxCalendarStyleYearGrid;
        
        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
            self.collectionView.pagingEnabled = NO;
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutYearGrid alloc] initWithViewController:self andSize:self.view.frame.size] animated:YES];
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        JxCalendarOverview *overview = [[JxCalendarOverview alloc] initWithDataSource:_dataSource
                                                                             andStyle:JxCalendarStyleYearGrid
                                                                              andSize:self.view.frame.size];
        [self.navigationController setViewControllers:@[overview] animated:YES];
    }
}

- (void)switchToMonthGridView{
    [self switchToMonthGridViewWithCallback:nil];
}
- (void)switchToMonthGridViewWithCallback:(void (^)(BOOL finished))callback{
    
    if ([self isKindOfClass:[JxCalendarOverview class]]) {
        self.style = JxCalendarStyleMonthGrid;
        
        [self.collectionView reloadData];
        
        [self.collectionView performBatchUpdates:^{
            
            self.collectionView.pagingEnabled = NO;
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionView setCollectionViewLayout:[[JxCalendarLayoutMonthGrid alloc] initWithViewController:self andSize:self.view.frame.size] animated:YES];
            
        } completion:callback];
    }else{
        JxCalendarOverview *overview = [[JxCalendarOverview alloc] initWithDataSource:_dataSource
                                                                             andStyle:JxCalendarStyleMonthGrid
                                                                              andSize:self.view.frame.size];
        [self.navigationController setViewControllers:@[overview] animated:YES];
    }
}

- (void)switchToWeekView{
    
    if ([self isKindOfClass:[JxCalendarWeek class]]) {
        

        
    }else{
        JxCalendarWeek *week = [[JxCalendarWeek alloc] initWithDataSource:self.dataSource andSize:self.view.frame.size];
        week.startYear = 2015;
        week.startMonth = 1;
        [self.navigationController setViewControllers:@[week] animated:YES];
        
    }
    
}
- (NSDateFormatter *)defaultFormatter{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setLocale:[NSLocale currentLocale]];//  [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formater setDateStyle:NSDateFormatterFullStyle];
    return formater;
}
@end
