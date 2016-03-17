//
//  JxCalendarOverview+ToolTip.h
//  JxCalendar
//
//  Created by Jeanette Müller on 14.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import <JxCalendar/JxCalendar.h>



@interface JxCalendarOverview (ToolTip) <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSDate *toolTipDate;

- (void)openToolTipWithDate:(NSDate *)date;

- (void)hideToolTip;

@end
