//
//  UIViewController+CalendarBackButtonHandler.h
//  JxCalendar
//
//  Created by Jeanette Müller on 20.01.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarBackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (CalendarBackButtonHandler) <CalendarBackButtonHandlerProtocol>

@end