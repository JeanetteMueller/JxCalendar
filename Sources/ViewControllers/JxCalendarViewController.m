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
#import "JxCalendarWeek.h"
#import "JxCalendarLayoutWeek.h"

@interface JxCalendarViewController ()

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
}
- (IBAction)closeCalendar:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.presentingViewController) {
        
        if (self.navigationController.viewControllers.count == 1) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeCalendar:)];
        }
        
    }
    
}
- (NSDateComponents *)startComponents{
    return [self componentsFromDate:self.startDate];
}
- (NSDateComponents *)componentsFromDate:(NSDate *)date{
    return [[self.dataSource calendar] components:( NSCalendarUnitHour |
                                                   NSCalendarUnitMinute |
                                                   NSCalendarUnitSecond |
                                                   NSCalendarUnitDay |
                                                   NSCalendarUnitMonth |
                                                   NSCalendarUnitYear |
                                                   NSCalendarUnitWeekday   )
                                         fromDate:date];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




@end
