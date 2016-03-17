//
//  JxCalendarOverview+ToolTip.m
//  JxCalendar
//
//  Created by Jeanette Müller on 14.03.16.
//  Copyright © 2016 Jeanette Müller. All rights reserved.
//

#import <objc/runtime.h>
#import "JxCalendarOverview+ToolTip.h"
#import "JxCalendarCell.h"
#import "JxCalendarProtocols.h"

@implementation JxCalendarOverview (ToolTip)

#pragma mark tooltip

#define kJxCalendarToolTipTagView                   8890
#define kJxCalendarToolTipTagContainer              8891
#define kJxCalendarToolTipTagLabel                  8892
#define kJxCalendarToolTipTagDayTypeButton          8893
#define kJxCalendarToolTipTagFreeChoiceButton       8894
#define kJxCalendarToolTipTagFreeChoiceContainer    8895
#define kJxCalendarToolTipTagFreeChoiceHourSlider   8896
#define kJxCalendarToolTipTagFreeChoiceHourMarker   889600
#define kJxCalendarToolTipTagFreeChoiceHourLabel    889700
#define kJxCalendarToolTipTagFreeChoiceMinuteSlider 8898
#define kJxCalendarToolTipTagFreeChoiceMinuteMarker 889800
#define kJxCalendarToolTipTagFreeChoiceMinuteLabel  889900
#define kJxCalendarToolTipTagFreeChoiceDoneButton   8900
#define kJxCalendarToolTipTagArrow                  8901

#define kJxCalendarToolTipTagEveryNstepHourLabel 2

#define kJxCalendarToolTipMinDistanceToBorder 5
#define kJxCalendarToolTipBasicWidth 130
#define kJxCalendarToolTipFreeChoiceExtraHeight 40

static void * toolTipDatePropertyKey = &toolTipDatePropertyKey;

typedef enum {
    JxCalendarToolTipAreaDetail,
    JxCalendarToolTipAreaDetailExtended,
    JxCalendarToolTipAreaFreeChoice
}JxCalendarToolTipArea;

- (NSDate *)toolTipDate {
    return objc_getAssociatedObject(self, toolTipDatePropertyKey);
}

- (void)setToolTipDate:(NSDate *)toolTipDate {
    objc_setAssociatedObject(self, toolTipDatePropertyKey, toolTipDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)openToolTipWithDate:(NSDate *)date{
    
    BOOL openNewTooltip = ![date isEqualToDate:self.toolTipDate];
    
    [self hideToolTip];
    
    if (openNewTooltip && [self.dataSource respondsToSelector:@selector(isRangeToolTipAvailableForDate:)] && [self.dataSource isRangeToolTipAvailableForDate:date]) {
        self.toolTipDate = date;
        
        UIView *toolTipView = [[UIView alloc] init];
        toolTipView.tag = kJxCalendarToolTipTagView;
        toolTipView.backgroundColor = [UIColor whiteColor];
        toolTipView.layer.shadowOffset = CGSizeMake(0, 0);
        toolTipView.layer.shadowOpacity = 0.6;
        toolTipView.layer.shadowRadius = 12;
        toolTipView.layer.cornerRadius = 8.f;
        
        UIView *container = [[UIView alloc] init];
        container.tag = kJxCalendarToolTipTagContainer;
        container.clipsToBounds = YES;
        container.backgroundColor = [UIColor clearColor];
        [toolTipView addSubview:container];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = kJxCalendarToolTipTagLabel;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        NSDateFormatter *formatter = [JxCalendarBasics defaultFormatter];
        formatter.dateFormat = @"dd.MM.YYYY";
        label.text = [formatter stringFromDate:date];
        [container addSubview:label];
        
        UIButton *dayTypeButton = [[UIButton alloc] init];
        dayTypeButton.tag = kJxCalendarToolTipTagDayTypeButton;
        [dayTypeButton addTarget:self action:@selector(dayTypeChange:) forControlEvents:UIControlEventTouchUpInside];
        [dayTypeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        dayTypeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [container addSubview:dayTypeButton];
        
        
        UIButton *freeChoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        freeChoiceButton.tag = kJxCalendarToolTipTagFreeChoiceButton;
        [freeChoiceButton addTarget:self action:@selector(freeChoiceChange:) forControlEvents:UIControlEventTouchUpInside];
        [freeChoiceButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        freeChoiceButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        freeChoiceButton.alpha = 0.f;
        [container addSubview:freeChoiceButton];
        
        
        UIView *freeContainer = [[UIView alloc] init];
        freeContainer.tag = kJxCalendarToolTipTagFreeChoiceContainer;
        freeContainer.clipsToBounds = YES;
        freeContainer.alpha = 0.0f;
        freeContainer.backgroundColor = [UIColor clearColor];
        [toolTipView addSubview:freeContainer];
        
        UISlider *freeChoiceHourSlider = [[UISlider alloc] init];
        freeChoiceHourSlider.tag = kJxCalendarToolTipTagFreeChoiceHourSlider;
        [freeChoiceHourSlider addTarget:self action:@selector(freeChoiceValueChanged:) forControlEvents:UIControlEventValueChanged];
        freeChoiceHourSlider.maximumValue = self.lengthOfDayInHours-1;
        freeChoiceHourSlider.minimumValue = 0;
        [freeContainer addSubview:freeChoiceHourSlider];
        
        UISlider *freeChoiceMinuteSlider = [[UISlider alloc] init];
        freeChoiceMinuteSlider.tag = kJxCalendarToolTipTagFreeChoiceMinuteSlider;
        [freeChoiceMinuteSlider addTarget:self action:@selector(freeChoiceValueChanged:) forControlEvents:UIControlEventValueChanged];
        freeChoiceMinuteSlider.minimumValue = 0;
        freeChoiceMinuteSlider.maximumValue = 60;
        [freeContainer addSubview:freeChoiceMinuteSlider];
        
        UIButton *freeChoiceDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        freeChoiceDoneButton.tag = kJxCalendarToolTipTagFreeChoiceDoneButton;
        [freeChoiceDoneButton addTarget:self action:@selector(freeChoiceDone:) forControlEvents:UIControlEventTouchUpInside];
        [freeChoiceDoneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        freeChoiceDoneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        freeChoiceDoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        freeChoiceDoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [freeChoiceDoneButton setTitle:@"Done" forState:UIControlStateNormal];
        [freeContainer addSubview:freeChoiceDoneButton];
        
        UIColor *markerColor = [UIColor lightGrayColor];
        for (int i = 0; i < self.lengthOfDayInHours/kJxCalendarToolTipTagEveryNstepHourLabel; i++) {
            UILabel *lab = [[UILabel alloc] init];
            lab.text = [NSString stringWithFormat:@"%d", i*kJxCalendarToolTipTagEveryNstepHourLabel];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            lab.textColor = markerColor;
            lab.tag = kJxCalendarToolTipTagFreeChoiceHourLabel+i;
            [freeContainer addSubview:lab];
        }
        for (int i = 0; i < self.lengthOfDayInHours; i++) {
            UIView *marker = [[UIView alloc] init];
            marker.tag = kJxCalendarToolTipTagFreeChoiceHourMarker + i;
            marker.backgroundColor = markerColor;
            [freeContainer addSubview:marker];
        }
        for (int i = 0; i < 5; i++) {
            UIView *marker = [[UIView alloc] init];
            marker.tag = kJxCalendarToolTipTagFreeChoiceMinuteMarker + i;
            marker.backgroundColor = markerColor;
            [freeContainer addSubview:marker];
            
            UILabel *lab = [[UILabel alloc] init];
            lab.text = [NSString stringWithFormat:@"%d", i*15];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            lab.textColor = markerColor;
            lab.tag = kJxCalendarToolTipTagFreeChoiceMinuteLabel+i;
            [freeContainer addSubview:lab];
        }
        
        
//        toolTipView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
//        label.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
//        dayTypeButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
        
        [self.view addSubview:toolTipView];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 20, 14, 10)];
        
        arrowView.tag = kJxCalendarToolTipTagArrow;
        arrowView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:arrowView];
        
        [self updateToolTipAnimated:NO];
    }
}
- (IBAction)freeChoiceValueChanged:(UISlider *)sender{
    UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];
    UIView *freeContainer = [toolTipView viewWithTag:kJxCalendarToolTipTagFreeChoiceContainer];
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    
    float hourStepValue = 1;
    float newHourStep = roundf((freeChoiceHourSlider.value) / hourStepValue);
    freeChoiceHourSlider.value = newHourStep * hourStepValue;
    NSLog(@"value hour changed %f", freeChoiceHourSlider.value);
    
    float minuteStepValue = 15;
    float newMinuteStep = roundf((freeChoiceMinuteSlider.value) / minuteStepValue);
    freeChoiceMinuteSlider.value = newMinuteStep * minuteStepValue;
    NSLog(@"value minute changed %f", freeChoiceMinuteSlider.value);
    
    
    NSDateComponents *components = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.toolTipDate];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *start = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
    
    int hour = freeChoiceHourSlider.value;
    int min = freeChoiceMinuteSlider.value;
    
    if (min == 60) {
        hour++;
        min = 0;
    }
    
    
    components.hour = hour;
    components.minute = min;
    components.second = 0;
    NSDate *end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
    
    
    JxCalendarRangeElement *element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                                     withStartDate:start andEndDate:end];
    
    if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
        [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:[self getAppearance]];
    }else if ([self.delegate respondsToSelector:@selector(calendarDidRange:whileOnAppearance:)]) {
        [self.delegate calendarDidRange:element whileOnAppearance:[self getAppearance]];
    }
    
    
    NSIndexPath *path = [self getIndexPathForDate:self.toolTipDate];
    
    [self updateRangeForCell:(JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path] atIndexPath:path animated:YES];
    
}
- (IBAction)freeChoiceDone:(id)sender{
    
    
    [self updateToolTipAnimated:YES];
    /*
     UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];
    [self updateToolTipSizeWithRect:CGRectMake(kJxCalendarToolTipMinDistanceToBorder,
                                               toolTipView.frame.origin.y,
                                               kJxCalendarToolTipBasicWidth,
                                               toolTipView.frame.size.height)
                           animated:YES withVisibleArea:JxCalendarToolTipAreaDetailExtended];
     */
}
- (void)hideToolTip{
    self.toolTipDate = nil;
    [[self.view viewWithTag:kJxCalendarToolTipTagView] removeFromSuperview];
    [[self.view viewWithTag:kJxCalendarToolTipTagArrow] removeFromSuperview];
}
- (void)updateToolTipAnimated:(BOOL)animated{
    
    JxCalendarToolTipArea area = JxCalendarToolTipAreaDetail;

    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    NSIndexPath *indexPath = [self getIndexPathForDate:self.toolTipDate];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = CGRectMake(cell.frame.origin.x-self.collectionView.contentOffset.x,
                             cell.frame.origin.y-self.collectionView.contentOffset.y,
                             cell.frame.size.width,
                             cell.frame.size.height);
    
    
    
    UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];
    UIView *container = [toolTipView viewWithTag:kJxCalendarToolTipTagContainer];
    UIView *freeContainer = [toolTipView viewWithTag:kJxCalendarToolTipTagFreeChoiceContainer];
    UIImageView *arrowView = [self.view viewWithTag:kJxCalendarToolTipTagArrow];
    
    CGFloat freeChoiceExtraHeight = 0;
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoice) {
        
        freeChoiceExtraHeight = kJxCalendarToolTipFreeChoiceExtraHeight;
        
        area = JxCalendarToolTipAreaDetailExtended;
        
    }
    
    CGSize toolTipSize = CGSizeMake(kJxCalendarToolTipBasicWidth, 80 + freeChoiceExtraHeight);
    
    CGRect toolTipRect = CGRectMake(rect.origin.x + (rect.size.width/2) - (toolTipSize.width/2), rect.origin.y-toolTipSize.height, toolTipSize.width, toolTipSize.height);
    
    if (toolTipRect.origin.x < kJxCalendarToolTipMinDistanceToBorder) {
        toolTipRect.origin.x = kJxCalendarToolTipMinDistanceToBorder;
    }
    if (toolTipRect.origin.x + toolTipRect.size.width > self.collectionView.frame.size.width) {
        toolTipRect.origin.x = self.collectionView.frame.size.width - toolTipRect.size.width - kJxCalendarToolTipMinDistanceToBorder;
    }

    if (toolTipRect.origin.y  < kJxCalendarToolTipMinDistanceToBorder) {
        NSLog(@"tooltip unter rect");
        toolTipRect.origin.y = rect.origin.y+rect.size.height;
        arrowView.frame = CGRectMake(rect.origin.x + (rect.size.width-arrowView.frame.size.width)/2, rect.origin.y+rect.size.height-arrowView.frame.size.height,
                                     arrowView.frame.size.width, arrowView.frame.size.height);
        
        UIGraphicsBeginImageContext(arrowView.frame.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        /* do something with pathRef. For example:*/
        CGPathMoveToPoint(pathRef, NULL, 0, 10);
        CGPathAddLineToPoint(pathRef, NULL, 7, 0);
        CGPathAddLineToPoint(pathRef, NULL, 14, 10);
        CGPathCloseSubpath(pathRef);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGPathRelease(pathRef);
        
        arrowView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }else{
        NSLog(@"tooltip over rect");
        arrowView.frame = CGRectMake(rect.origin.x + (rect.size.width-arrowView.frame.size.width)/2, rect.origin.y,
                                     arrowView.frame.size.width, arrowView.frame.size.height);

        
        UIGraphicsBeginImageContext(arrowView.frame.size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        /* do something with pathRef. For example:*/
        CGPathMoveToPoint(pathRef, NULL, 0, 0);
        CGPathAddLineToPoint(pathRef, NULL, 7, 10);
        CGPathAddLineToPoint(pathRef, NULL, 14, 0);
        CGPathCloseSubpath(pathRef);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGPathRelease(pathRef);
        
        arrowView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    UIButton *dayTypeButton = [container viewWithTag:kJxCalendarToolTipTagDayTypeButton];

    switch ([self.dataSource dayTypeOfDateInRange:self.toolTipDate]) {
        case JxCalendarDayTypeUnknown:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionUnknown forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeWholeDay:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionWholeDay forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeWorkDay:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionWorkDay forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDay:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionHalfDay forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDayMorning:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionHalfDayMorning forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDayAfternoon:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionHalfDayAfternoon forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeFreeChoice:
            [dayTypeButton setTitle:kJxCalendarDayTypeOptionFreeChoice forState:UIControlStateNormal];
    }
    
    
    UIButton *freeChoiceButton = [container viewWithTag:kJxCalendarToolTipTagFreeChoiceButton];
    
    
    if ([self.dataSource dayTypeOfDateInRange:self.toolTipDate] == JxCalendarDayTypeFreeChoice) {
        
        NSTimeInterval duration = [rangeElement.end timeIntervalSinceDate:rangeElement.start];
        
        NSUInteger seconds = ABS((int)duration);
        NSUInteger minutes = seconds/60;
        NSUInteger hours = minutes/60;
        
        NSString *hour = [NSString stringWithFormat:@"%lu", (unsigned long)hours];
        NSString *min = [NSString stringWithFormat:@"%2lu", (unsigned long)minutes % 60];
        
        hour = [hour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        min = [min stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        
        [freeChoiceButton setTitle:[NSString stringWithFormat:@"%@:%@", hour, min] forState:UIControlStateNormal];
    }
    
    if ((
            [self.delegate respondsToSelector:@selector(calendarShouldStartRanging:)] && [self.delegate calendarShouldStartRanging:[self getCalendarOverview]]
        ) || (
            [self.delegate respondsToSelector:@selector(calendarShouldStartRanging)] && [self.delegate calendarShouldStartRanging]
        )
        ) {
        dayTypeButton.enabled = YES;
        freeChoiceButton.enabled = YES;
    }else{
        dayTypeButton.enabled = NO;
        freeChoiceButton.enabled = NO;
    }
    
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    
    
    [self placeMarkersInRect:toolTipRect];
    
    NSTimeInterval duration = [rangeElement.end timeIntervalSinceDate:rangeElement.start];
    
    NSUInteger seconds = ABS((int)duration);
    NSUInteger minutes = seconds/60;
    NSUInteger hours = minutes/60;
    
    NSLog(@"hours %lu minutes %lu", (unsigned long)hours, (unsigned long)minutes % 60);
    
    minutes = minutes%60;
    
    if (hours == self.lengthOfDayInHours && minutes == 0) {
        hours = self.lengthOfDayInHours-1;
        minutes = 60;
    }
    
    freeChoiceHourSlider.value = hours;
    freeChoiceMinuteSlider.value = minutes;
    
    [self updateToolTipSizeWithRect:toolTipRect animated:animated withVisibleArea:area];
}
- (void)updateToolTipSizeWithRect:(CGRect)rect animated:(BOOL)animated withVisibleArea:(JxCalendarToolTipArea)area{
    
    UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];
    UIView *container = [toolTipView viewWithTag:kJxCalendarToolTipTagContainer];
    
    UIView *freeContainer = [toolTipView viewWithTag:kJxCalendarToolTipTagFreeChoiceContainer];
    UILabel *label = [container viewWithTag:kJxCalendarToolTipTagLabel];
    UIButton *dayTypeButton = [container viewWithTag:kJxCalendarToolTipTagDayTypeButton];
    UIButton *freeChoiceButton = [container viewWithTag:kJxCalendarToolTipTagFreeChoiceButton];
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteSlider];
    UIButton *freeChoiceDoneButton = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceDoneButton];
    
    void (^animation)(void) = ^{
        
        toolTipView.frame = rect;
        container.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        freeContainer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        
        label.frame =                   CGRectMake((container.frame.size.width - 100)/2,  0, 100, 40);
        dayTypeButton.frame =           CGRectMake(0, 40, container.frame.size.width, 40);
        freeChoiceButton.frame =        CGRectMake(0, 80, container.frame.size.width, 40);
        freeChoiceHourSlider.frame =    CGRectMake(0, 20, freeContainer.frame.size.width, 30);
        freeChoiceMinuteSlider.frame =  CGRectMake(0, 60, freeContainer.frame.size.width, 30);
        freeChoiceDoneButton.frame =    CGRectMake(0, 90, freeContainer.frame.size.width, 30);
        
        
        if (area == JxCalendarToolTipAreaDetailExtended) {
            freeChoiceButton.alpha = 1.0f;
        }else if (area == JxCalendarToolTipAreaDetail) {
            freeChoiceButton.alpha = .0f;
        }
        if (area == JxCalendarToolTipAreaFreeChoice) {
            freeContainer.alpha = 1.0;
            freeContainer.userInteractionEnabled = YES;
            container.alpha = 0.f;
            container.userInteractionEnabled = NO;
            
        }else{
            freeContainer.alpha = 0.f;
            freeContainer.userInteractionEnabled = NO;
            container.alpha = 1.0f;
            container.userInteractionEnabled = YES;
        }
        [self placeMarkersInRect:freeContainer.frame];
        
    };
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:animation];
    }else{
        animation();
    }
}
- (void)placeMarkersInRect:(CGRect)rect{
    
    UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];
    UIView *freeContainer = [toolTipView viewWithTag:kJxCalendarToolTipTagFreeChoiceContainer];
    
    CGFloat buttonWidth = 30;
    
    CGFloat labelWidth = 14;
    
    
    
    for (int i = 0; i < self.lengthOfDayInHours/kJxCalendarToolTipTagEveryNstepHourLabel; i++) {
        UILabel *label = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourLabel+i];
        label.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (self.lengthOfDayInHours-1) * (i*kJxCalendarToolTipTagEveryNstepHourLabel))+(buttonWidth/2) -(labelWidth/2), 10, labelWidth, 10);
    }
    for (int i = 0; i < self.lengthOfDayInHours; i++) {
        UIView *marker = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourMarker+i];
        marker.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (self.lengthOfDayInHours-1) * i)+(buttonWidth/2) - 0.5f, 23, 1, 7);
    }
    
    for (int i = 0; i < 5; i++) {
        UILabel *lab = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteLabel+i];
        lab.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (5-1) * i)+(buttonWidth/2) - (labelWidth/2), 50, labelWidth, 10);
        
        
        UIView *marker = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteMarker+i];
        marker.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (5-1) * i)+(buttonWidth/2) - 0.5f, 63, 1, 7);
    }
    
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:kJxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    [freeContainer bringSubviewToFront:freeChoiceHourSlider];
    [freeContainer bringSubviewToFront:freeChoiceMinuteSlider];
}
- (IBAction)dayTypeChange:(id)sender{
    
    UIButton *dayTypeButton = sender;
    
    JxCalendarDayTypeMask mask = [self.dataSource availableDayTypesForDate:self.toolTipDate];
    
    NSMutableArray *availableOptions = [NSMutableArray array];
    
    
    if ((mask & JxCalendarDayTypeMaskWholeDay) == JxCalendarDayTypeMaskWholeDay) {
        [availableOptions addObject:@(JxCalendarDayTypeWholeDay)];
    }
    if ((mask & JxCalendarDayTypeMaskWorkDay) == JxCalendarDayTypeMaskWorkDay) {
        [availableOptions addObject:@(JxCalendarDayTypeWorkDay)];
    }
    if ((mask & JxCalendarDayTypeMaskHalfDay) == JxCalendarDayTypeMaskHalfDay) {
        [availableOptions addObject:@(JxCalendarDayTypeHalfDay)];
    }
    if ((mask & JxCalendarDayTypeMaskHalfDayMorning) == JxCalendarDayTypeMaskHalfDayMorning) {
        [availableOptions addObject:@(JxCalendarDayTypeHalfDayMorning)];
    }
    if ((mask & JxCalendarDayTypeMaskHalfDayAfternoon) == JxCalendarDayTypeMaskHalfDayAfternoon) {
        [availableOptions addObject:@(JxCalendarDayTypeHalfDayAfternoon)];
    }
    if ((mask & JxCalendarDayTypeMaskFreeChoice) == JxCalendarDayTypeMaskFreeChoice) {
        [availableOptions addObject:@(JxCalendarDayTypeFreeChoice)];
    }
    
    [availableOptions addObject:availableOptions[0]];
    
    JxCalendarDayType doType = JxCalendarDayTypeUnknown;
    
    for (int i = 0; i < availableOptions.count; i++) {
        NSNumber *type = availableOptions[i];
        if ([self.dataSource dayTypeOfDateInRange:self.toolTipDate] == type.intValue ) {
            
            doType = [availableOptions[i+1] intValue];
            break;
        }
    }
    
    [dayTypeButton setTitle:[self getTitleForDayType:doType] forState:UIControlStateNormal];
    
    JxCalendarRangeElement *element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate andDayType:doType inCalendar:self.dataSource.calendar andMaximumDayLength:self.lengthOfDayInHours];
    
    if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
        [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:[self getAppearance]];
    }else if ([self.delegate respondsToSelector:@selector(calendarDidRange:whileOnAppearance:)]) {
        [self.delegate calendarDidRange:element whileOnAppearance:[self getAppearance]];
    }
    
    
    NSIndexPath *path = [self getIndexPathForDate:self.toolTipDate];
    
    [self updateRangeForCell:(JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path] atIndexPath:path animated:YES];
    
    [self updateToolTipAnimated:YES];
}
- (NSString *)getTitleForDayType:(JxCalendarDayType)type{
    switch (type) {
        case JxCalendarDayTypeWholeDay:
            return kJxCalendarDayTypeOptionWholeDay;
        case JxCalendarDayTypeHalfDay:
            return kJxCalendarDayTypeOptionHalfDay;
        case JxCalendarDayTypeHalfDayMorning:
            return kJxCalendarDayTypeOptionHalfDayMorning;
        case JxCalendarDayTypeHalfDayAfternoon:
            return kJxCalendarDayTypeOptionHalfDayAfternoon;
        case JxCalendarDayTypeWorkDay:
            return kJxCalendarDayTypeOptionWorkDay;
        case JxCalendarDayTypeFreeChoice:
            return kJxCalendarDayTypeOptionFreeChoice;
        case JxCalendarDayTypeUnknown:
            return kJxCalendarDayTypeOptionUnknown;
    }
}
- (IBAction)freeChoiceChange:(id)sender{
    NSLog(@"timepicker oder ähnliches öffnen");
    
    UIView *toolTipView = [self.view viewWithTag:kJxCalendarToolTipTagView];


    [self updateToolTipSizeWithRect:CGRectMake(kJxCalendarToolTipMinDistanceToBorder,
                                               toolTipView.frame.origin.y,
                                               self.view.frame.size.width-(kJxCalendarToolTipMinDistanceToBorder*2),
                                               toolTipView.frame.size.height)
                           animated:YES withVisibleArea:JxCalendarToolTipAreaFreeChoice];
    
}


@end
