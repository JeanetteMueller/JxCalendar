//
//  JxCalendarWeekHeader.h
//  JxCalendar
//
//  Created by Jeanette Müller on 23.12.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxCalendarWeekHeader : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIView *eventMarker;

@end
