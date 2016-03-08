//
//  JxCalendarCell.h
//  JxCalendar
//
//  Created by Jeanette Müller on 03.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JxCalendarDay;

@interface JxCalendarCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIView *eventMarker;

@property (strong, nonatomic) IBOutlet UIView *rangeTo;
@property (strong, nonatomic) IBOutlet UIView *rangeFrom;
@property (strong, nonatomic) IBOutlet UIView *rangeDot;
@property (strong, nonatomic) IBOutlet UIView *rangeDotBackground;

@property (strong, nonatomic) JxCalendarDay *vc;

@end
