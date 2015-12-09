//
//  JxCalendarCell.h
//  JxCalendar
//
//  Created by Jeanette Müller on 03.11.15.
//  Copyright © 2015 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JxCalendarCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIView *eventMarker;

@end
