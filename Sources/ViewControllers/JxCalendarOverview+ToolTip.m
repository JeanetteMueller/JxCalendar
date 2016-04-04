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

typedef enum{

    JxCalendarToolTipTagView = 8890,
    JxCalendarToolTipTagContainer,
    JxCalendarToolTipTagLabel,
    JxCalendarToolTipTagDayTypeButton,
    JxCalendarToolTipTagFreeChoiceButton,
    JxCalendarToolTipTagFreeChoiceContainer,
    JxCalendarToolTipTagFreeChoiceHourSlider,
    JxCalendarToolTipTagFreeChoiceMinuteSlider,
    JxCalendarToolTipTagFreeChoiceDoneButton,
    JxCalendarToolTipTagArrow,
    
    JxCalendarToolTipTagFreeChoiceTimePicker,
    
    JxCalendarToolTipTagFreeChoiceHourMarker   = 889600,
    JxCalendarToolTipTagFreeChoiceHourLabel    = 889700,

    JxCalendarToolTipTagFreeChoiceMinuteMarker = 889800,
    JxCalendarToolTipTagFreeChoiceMinuteLabel  = 889900,
    
    
}JxCalendarToolTipViewTag;

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
        toolTipView.tag = JxCalendarToolTipTagView;
        toolTipView.backgroundColor = [UIColor whiteColor];
        toolTipView.layer.shadowOffset = CGSizeMake(0, 0);
        toolTipView.layer.shadowOpacity = 0.6;
        toolTipView.layer.shadowRadius = 12;
        toolTipView.layer.cornerRadius = 8.f;
        
        UIView *container = [[UIView alloc] init];
        container.tag = JxCalendarToolTipTagContainer;
        container.clipsToBounds = YES;
        container.backgroundColor = [UIColor clearColor];
        [toolTipView addSubview:container];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = JxCalendarToolTipTagLabel;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        NSDateFormatter *formatter = [JxCalendarBasics defaultFormatter];
        formatter.dateFormat = @"dd.MM.YYYY";
        label.text = [formatter stringFromDate:date];
        [container addSubview:label];
        
        UIButton *dayTypeButton = [[UIButton alloc] init];
        dayTypeButton.tag = JxCalendarToolTipTagDayTypeButton;
        [dayTypeButton addTarget:self action:@selector(dayTypeChange:) forControlEvents:UIControlEventTouchUpInside];
        [dayTypeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        dayTypeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        [container addSubview:dayTypeButton];
        
        
        UIButton *freeChoiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        freeChoiceButton.tag = JxCalendarToolTipTagFreeChoiceButton;
        [freeChoiceButton addTarget:self action:@selector(freeChoiceChange:) forControlEvents:UIControlEventTouchUpInside];
        [freeChoiceButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        freeChoiceButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        freeChoiceButton.alpha = 0.f;
        [container addSubview:freeChoiceButton];
        
        
        UIView *freeContainer = [[UIView alloc] init];
        freeContainer.tag = JxCalendarToolTipTagFreeChoiceContainer;
        freeContainer.clipsToBounds = YES;
        freeContainer.alpha = 0.0f;
        freeContainer.backgroundColor = [UIColor clearColor];
        [toolTipView addSubview:freeContainer];
        
        UIPickerView *freeChoicePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, kJxCalendarToolTipBasicWidth, 216)];
        freeChoicePicker.tag = JxCalendarToolTipTagFreeChoiceTimePicker;
        freeChoicePicker.dataSource = self;
        freeChoicePicker.delegate = self;
        [freeContainer addSubview:freeChoicePicker];
        
        /*
        UISlider *freeChoiceHourSlider = [[UISlider alloc] init];
        freeChoiceHourSlider.tag = JxCalendarToolTipTagFreeChoiceHourSlider;
        [freeChoiceHourSlider addTarget:self action:@selector(freeChoiceValueChanged:) forControlEvents:UIControlEventValueChanged];
        freeChoiceHourSlider.maximumValue = self.lengthOfDayInHours-1;
        freeChoiceHourSlider.minimumValue = 0;
        [freeContainer addSubview:freeChoiceHourSlider];
        
        UISlider *freeChoiceMinuteSlider = [[UISlider alloc] init];
        freeChoiceMinuteSlider.tag = JxCalendarToolTipTagFreeChoiceMinuteSlider;
        [freeChoiceMinuteSlider addTarget:self action:@selector(freeChoiceValueChanged:) forControlEvents:UIControlEventValueChanged];
        freeChoiceMinuteSlider.minimumValue = 0;
        freeChoiceMinuteSlider.maximumValue = 60;
        [freeContainer addSubview:freeChoiceMinuteSlider];
        
        UIButton *freeChoiceDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        freeChoiceDoneButton.tag = JxCalendarToolTipTagFreeChoiceDoneButton;
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
            lab.tag = JxCalendarToolTipTagFreeChoiceHourLabel+i;
            [freeContainer addSubview:lab];
        }
        for (int i = 0; i < self.lengthOfDayInHours; i++) {
            UIView *marker = [[UIView alloc] init];
            marker.tag = JxCalendarToolTipTagFreeChoiceHourMarker + i;
            marker.backgroundColor = markerColor;
            [freeContainer addSubview:marker];
        }
        for (int i = 0; i < 5; i++) {
            UIView *marker = [[UIView alloc] init];
            marker.tag = JxCalendarToolTipTagFreeChoiceMinuteMarker + i;
            marker.backgroundColor = markerColor;
            [freeContainer addSubview:marker];
            
            UILabel *lab = [[UILabel alloc] init];
            lab.text = [NSString stringWithFormat:@"%d", i*15];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            lab.textColor = markerColor;
            lab.tag = JxCalendarToolTipTagFreeChoiceMinuteLabel+i;
            [freeContainer addSubview:lab];
        }
        */
        
//        toolTipView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
//        label.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
//        dayTypeButton.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.5];
//        freeContainer.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:toolTipView];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 20, 14, 10)];
        
        arrowView.tag = JxCalendarToolTipTagArrow;
        arrowView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:arrowView];
        
        [self updateToolTipAnimated:NO];
    }
}
- (IBAction)freeChoiceValueChanged:(UISlider *)sender{
    UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];
    UIView *freeContainer = [toolTipView viewWithTag:JxCalendarToolTipTagFreeChoiceContainer];
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    
    float hourStepValue = 1;
    float newHourStep = roundf((freeChoiceHourSlider.value) / hourStepValue);
    freeChoiceHourSlider.value = newHourStep * hourStepValue;

    float minuteStepValue = 15;
    float newMinuteStep = roundf((freeChoiceMinuteSlider.value) / minuteStepValue);
    freeChoiceMinuteSlider.value = newMinuteStep * minuteStepValue;
    
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
    
    if (hour >= self.lengthOfDayInHours) {
        components.hour = self.lengthOfDayInHours-1;
        components.minute = 59;
        components.second = 59;
    }else{
        components.hour = hour;
        components.minute = min;
        components.second = 0;
    }
    
    
    
    NSDate *end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
    
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    
    JxCalendarRangeElement *element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                                        andDayType:rangeElement.dayType
                                                                     withStartDate:start
                                                                        andEndDate:end];
    
    if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
        [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:[self getAppearance]];
    }
    
    
    NSIndexPath *path = [self getIndexPathForDate:self.toolTipDate];
    
    [self updateRangeForCell:(JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path] atIndexPath:path animated:YES];
    
}
- (IBAction)freeChoiceDone:(id)sender{
    
    [self updateToolTipAnimated:YES];
}
- (void)hideToolTip{
    self.toolTipDate = nil;
    [[self.view viewWithTag:JxCalendarToolTipTagView] removeFromSuperview];
    [[self.view viewWithTag:JxCalendarToolTipTagArrow] removeFromSuperview];
}
- (void)updateToolTipAnimated:(BOOL)animated{
    
    JxCalendarToolTipArea area = JxCalendarToolTipAreaDetail;

    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    NSDateComponents *startComponents = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:rangeElement.start];
    NSDateComponents *endComponents = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:rangeElement.end];
    
    
    NSIndexPath *indexPath = [self getIndexPathForDate:self.toolTipDate];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = CGRectMake(cell.frame.origin.x-self.collectionView.contentOffset.x,
                             cell.frame.origin.y-self.collectionView.contentOffset.y,
                             cell.frame.size.width,
                             cell.frame.size.height);
    
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoice || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        
        area = JxCalendarToolTipAreaDetailExtended;
        
    }
    
    UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];
    UIView *container = [toolTipView viewWithTag:JxCalendarToolTipTagContainer];
    UIView *freeContainer = [toolTipView viewWithTag:JxCalendarToolTipTagFreeChoiceContainer];
    
    UIButton *dayTypeButton = [container viewWithTag:JxCalendarToolTipTagDayTypeButton];

    switch (rangeElement.dayType) {
        case JxCalendarDayTypeUnknown:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionUnknown, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeWholeDay:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionWholeDay, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeWorkDay:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionWorkDay, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDay:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionHalfDay, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDayMorning:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionHalfDayMorning, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeHalfDayAfternoon:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionHalfDayAfternoon, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeFreeChoice:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionFreeChoice, nil) forState:UIControlStateNormal];
            break;
        case JxCalendarDayTypeFreeChoiceMin:
        case JxCalendarDayTypeFreeChoiceMax:
            [dayTypeButton setTitle:NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMinMax, nil) forState:UIControlStateNormal];
            break;
    }
    
    UIButton *freeChoiceButton = [container viewWithTag:JxCalendarToolTipTagFreeChoiceButton];
    
    NSString *hour, *min;
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoice) {
        
        if (self.displayRangeTimeAdDuration) {
            NSTimeInterval duration = [rangeElement.end timeIntervalSinceDate:rangeElement.start];
            NSUInteger seconds = ABS((int)duration);
            NSUInteger minutes = seconds/60;
            NSUInteger hours = minutes/60;
            
            hour = [NSString stringWithFormat:@"%lu", (unsigned long)hours];
            min = [NSString stringWithFormat:@"%2lu", (unsigned long)minutes % 60];
            
            hour = [hour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            min = [min stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            
            [freeChoiceButton setTitle:[NSString stringWithFormat:@"%@:%@ h", hour, min] forState:UIControlStateNormal];

        }else{
            NSString *startHour = [NSString stringWithFormat:@"%2ld", (long)startComponents.hour];
            NSString *startMin = [NSString stringWithFormat:@"%2ld", (long)startComponents.minute];
            
            NSString *endHour = [NSString stringWithFormat:@"%2ld", (long)endComponents.hour];
            NSString *endMin = [NSString stringWithFormat:@"%2ld", (long)endComponents.minute];
            
            startHour = [startHour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            startMin = [startMin stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            
            endHour = [endHour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            endMin = [endMin stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            
            [freeChoiceButton setTitle:[NSString stringWithFormat:@"%@:%@ - %@:%@", startHour, startMin, endHour, endMin] forState:UIControlStateNormal];
        }
        
    }else if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin) {
        
        hour = [NSString stringWithFormat:@"%2ld", (long)endComponents.hour];
        min = [NSString stringWithFormat:@"%2ld", (long)endComponents.minute];
        
        hour = [hour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        min = [min stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        [freeChoiceButton setTitle:[NSString stringWithFormat:@"%@ %@:%@", NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMin, nil), hour, min] forState:UIControlStateNormal];
    }else if(rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax){
        hour = [NSString stringWithFormat:@"%2ld", (long)startComponents.hour];
        min = [NSString stringWithFormat:@"%2ld", (long)startComponents.minute];
        hour = [hour stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        min = [min stringByReplacingOccurrencesOfString:@" " withString:@"0"];
        [freeChoiceButton setTitle:[NSString stringWithFormat:@"%@ %@:%@", NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMax, nil), hour, min] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarShouldStartRanging:)] && [self.delegate calendarShouldStartRanging:[self getCalendarOverview]]) {
        dayTypeButton.enabled = YES;
        freeChoiceButton.enabled = YES;
    }else{
        dayTypeButton.enabled = NO;
        freeChoiceButton.enabled = NO;
    }
    
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    
    
    NSTimeInterval duration = [rangeElement.end timeIntervalSinceDate:rangeElement.start];
    
    NSUInteger seconds = ABS((int)duration);
    NSUInteger minutes = seconds/60;
    NSUInteger hours = minutes/60;
    
    minutes = minutes%60;
    
    if (hours == self.lengthOfDayInHours && minutes == 0) {
        hours = self.lengthOfDayInHours-1;
        minutes = 60;
    }
    
    freeChoiceHourSlider.value = hours;
    freeChoiceMinuteSlider.value = minutes;
    
    UIPickerView *freeChoiceTimePicker = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceTimePicker];
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin) {
        [freeChoiceTimePicker selectRow:1 inComponent:0 animated:YES];
        [freeChoiceTimePicker selectRow:endComponents.hour inComponent:1 animated:YES];
        [freeChoiceTimePicker selectRow:endComponents.minute inComponent:2 animated:YES];
    }else if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        [freeChoiceTimePicker selectRow:0 inComponent:0 animated:YES];
        [freeChoiceTimePicker selectRow:startComponents.hour inComponent:1 animated:YES];
        [freeChoiceTimePicker selectRow:startComponents.minute inComponent:2 animated:YES];
    }else{
        [freeChoiceTimePicker selectRow:startComponents.hour inComponent:0 animated:YES];
        [freeChoiceTimePicker selectRow:startComponents.minute inComponent:1 animated:YES];
        
        [freeChoiceTimePicker selectRow:endComponents.hour inComponent:3 animated:YES];
        [freeChoiceTimePicker selectRow:endComponents.minute inComponent:4 animated:YES];
    }
    
    CGSize newSize = CGSizeMake(kJxCalendarToolTipBasicWidth, 80);
    
    [self updateToolTipSizeFromSourceRect:rect withSize:newSize animated:animated withVisibleArea:area];
}

- (void)updateToolTipSizeFromSourceRect:(CGRect)source withSize:(CGSize)newSize animated:(BOOL)animated withVisibleArea:(JxCalendarToolTipArea)area{
    
    UIImageView *arrowView = [self.view viewWithTag:JxCalendarToolTipTagArrow];
    
    CGFloat freeChoiceExtraHeight = 0;
    if (area == JxCalendarToolTipAreaDetailExtended) {
        
        freeChoiceExtraHeight = kJxCalendarToolTipFreeChoiceExtraHeight;
    }
    
    CGSize toolTipSize = CGSizeMake(newSize.width, newSize.height + freeChoiceExtraHeight);
    
    CGRect toolTipRect = CGRectMake(source.origin.x + (source.size.width/2) - (toolTipSize.width/2), source.origin.y-toolTipSize.height, toolTipSize.width, toolTipSize.height);
    
    if (toolTipRect.origin.x < kJxCalendarToolTipMinDistanceToBorder) {
        toolTipRect.origin.x = kJxCalendarToolTipMinDistanceToBorder;
    }
    if (toolTipRect.origin.x + toolTipRect.size.width > self.collectionView.frame.size.width) {
        toolTipRect.origin.x = self.collectionView.frame.size.width - toolTipRect.size.width - kJxCalendarToolTipMinDistanceToBorder;
    }
    
    BOOL arrowUnderRect = NO;
    
    if (toolTipRect.origin.y  < kJxCalendarToolTipMinDistanceToBorder) {
        // tooltip unter rect
        toolTipRect.origin.y = source.origin.y+source.size.height;
        arrowView.frame = CGRectMake(source.origin.x + (source.size.width-arrowView.frame.size.width)/2, source.origin.y+source.size.height-arrowView.frame.size.height,
                                     arrowView.frame.size.width, arrowView.frame.size.height);
        arrowUnderRect = YES;
    }else{
        // tooltip over rect
        arrowView.frame = CGRectMake(source.origin.x + (source.size.width-arrowView.frame.size.width)/2, source.origin.y,
                                     arrowView.frame.size.width, arrowView.frame.size.height);
    }
    
    UIGraphicsBeginImageContext(arrowView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    if (arrowUnderRect) {
        // tooltip unter rect
        CGPathMoveToPoint(pathRef, NULL, 0, 10);
        CGPathAddLineToPoint(pathRef, NULL, 7, 0);
        CGPathAddLineToPoint(pathRef, NULL, 14, 10);
    }else{
        // tooltip over rect
        CGPathMoveToPoint(pathRef, NULL, 0, 0);
        CGPathAddLineToPoint(pathRef, NULL, 7, 10);
        CGPathAddLineToPoint(pathRef, NULL, 14, 0);
    }
    
    CGPathCloseSubpath(pathRef);
    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(pathRef);
    arrowView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];
    UIView *container = [toolTipView viewWithTag:JxCalendarToolTipTagContainer];
    
    UIView *freeContainer               = [toolTipView viewWithTag:JxCalendarToolTipTagFreeChoiceContainer];
    UILabel *label                      = [container   viewWithTag:JxCalendarToolTipTagLabel];
    UIButton *dayTypeButton             = [container   viewWithTag:JxCalendarToolTipTagDayTypeButton];
    UIButton *freeChoiceButton          = [container   viewWithTag:JxCalendarToolTipTagFreeChoiceButton];
    UISlider *freeChoiceHourSlider      = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider    = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteSlider];
    UIButton *freeChoiceDoneButton      = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceDoneButton];
    UIPickerView *freeChoiceTimePicker  = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceTimePicker];
    
    
    
    void (^animation)(void) = ^{
        
        toolTipView.frame = toolTipRect;
        container.frame = CGRectMake(0, 0, toolTipRect.size.width, toolTipRect.size.height);
        freeContainer.frame = CGRectMake(0, 0, toolTipRect.size.width, toolTipRect.size.height);
        
        label.frame =                   CGRectMake((container.frame.size.width - 100)/2,  0, 100, 40);
        dayTypeButton.frame =           CGRectMake(0, 40, container.frame.size.width, 40);
        freeChoiceButton.frame =        CGRectMake(0, 80, container.frame.size.width, 40);
        freeChoiceHourSlider.frame =    CGRectMake(0, 20, freeContainer.frame.size.width, 30);
        freeChoiceMinuteSlider.frame =  CGRectMake(0, 60, freeContainer.frame.size.width, 30);
        freeChoiceDoneButton.frame =    CGRectMake(0, 90, freeContainer.frame.size.width, 30);
        
        freeChoiceTimePicker.frame = CGRectMake(0, (toolTipRect.size.height-freeChoiceTimePicker.frame.size.height)/2, toolTipRect.size.width, 216);
        
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
        [freeChoiceTimePicker setNeedsLayout];
        [self placeMarkersInRect:freeContainer.frame];
    };
    
    void (^completion)(BOOL finished) = ^(BOOL finished){
        
        
    };
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:animation completion:completion];
    }else{
        animation();
        completion(YES);
    }
}
- (void)placeMarkersInRect:(CGRect)rect{
    
    UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];
    UIView *freeContainer = [toolTipView viewWithTag:JxCalendarToolTipTagFreeChoiceContainer];
    
    CGFloat buttonWidth = 30;
    
    CGFloat labelWidth = 14;
    
    
    
    for (int i = 0; i < self.lengthOfDayInHours/kJxCalendarToolTipTagEveryNstepHourLabel; i++) {
        UILabel *label = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourLabel+i];
        label.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (self.lengthOfDayInHours-1) * (i*kJxCalendarToolTipTagEveryNstepHourLabel))+(buttonWidth/2) -(labelWidth/2), 10, labelWidth, 10);
    }
    for (int i = 0; i < self.lengthOfDayInHours; i++) {
        UIView *marker = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourMarker+i];
        marker.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (self.lengthOfDayInHours-1) * i)+(buttonWidth/2) - 0.5f, 23, 1, 7);
    }
    
    for (int i = 0; i < 5; i++) {
        UILabel *lab = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteLabel+i];
        lab.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (5-1) * i)+(buttonWidth/2) - (labelWidth/2), 50, labelWidth, 10);
        
        
        UIView *marker = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteMarker+i];
        marker.frame = CGRectMake(((freeContainer.frame.size.width-buttonWidth) / (5-1) * i)+(buttonWidth/2) - 0.5f, 63, 1, 7);
    }
    
    UISlider *freeChoiceHourSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceHourSlider];
    UISlider *freeChoiceMinuteSlider = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceMinuteSlider];
    
    [freeContainer bringSubviewToFront:freeChoiceHourSlider];
    [freeContainer bringSubviewToFront:freeChoiceMinuteSlider];
}
- (IBAction)dayTypeChange:(id)sender{
    
    UIButton *dayTypeButton = sender;
    
    JxCalendarDayTypeMask mask = [self.dataSource availableDayTypesForDate:self.toolTipDate];
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    NSDateComponents *components = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.toolTipDate];
    
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
    
    if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax || (mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin) {
        NSIndexPath *path = [self getIndexPathForDate:rangeElement.date];
        if ([self nextCellIsInRangeWithIndexPath:path]) {
            if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax){
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMax)];
                
            }else if ((mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin){
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMin)];
            }
        }else{
            if ((mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin){
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMin)];
                
            }else if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax){
                [availableOptions addObject:@(JxCalendarDayTypeFreeChoiceMax)];
            }
        }
        
    }

    [availableOptions addObjectsFromArray:availableOptions];
    
    JxCalendarDayType doType = JxCalendarDayTypeUnknown;
    
    for (int i = 0; i < availableOptions.count; i++) {
        NSNumber *type = availableOptions[i];
        if (rangeElement.dayType == type.intValue ) {
            
            doType = [availableOptions[i+1] intValue];
            break;
        }
    }
    if (doType == JxCalendarDayTypeUnknown && availableOptions.count > 0) {
        doType = (JxCalendarDayType)[availableOptions[0] intValue];
    }
    
    if (doType != rangeElement.dayType) {
        [dayTypeButton setTitle:[self getTitleForDayType:doType] forState:UIControlStateNormal];
        
        JxCalendarRangeElement *element;
        
        if ([self.dataSource respondsToSelector:@selector(preparedRangeElementForDate:andDayType:andMaximumDayLength:)]) {
            element = [self.dataSource preparedRangeElementForDate:self.toolTipDate andDayType:doType andMaximumDayLength:self.lengthOfDayInHours];
            
        }
        if (!element) {
            if (doType == JxCalendarDayTypeFreeChoiceMin) {
                
                NSDate *start, *end;
                
                //anfang bis
                components.hour = 0;
                components.minute = 0;
                components.second = 0;
                start = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
                components.hour = self.lengthOfDayInHours/2;
                components.minute = 0;
                components.second = 0;
                end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
                
                element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                            andDayType:doType
                                                         withStartDate:start
                                                            andEndDate:end];
            }else if (doType == JxCalendarDayTypeFreeChoiceMax) {
                
                NSDate *start, *end;
                
                //von
                components.hour = self.lengthOfDayInHours/2;
                components.minute = 0;
                components.second = 0;
                start = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
                components.hour = self.lengthOfDayInHours-1;
                components.minute = 59;
                components.second = 59;
                end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
                
                element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                            andDayType:doType
                                                         withStartDate:start
                                                            andEndDate:end];
            }else{
                element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                            andDayType:doType
                                                            inCalendar:self.dataSource.calendar
                                                   andMaximumDayLength:self.lengthOfDayInHours];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
            [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:[self getAppearance]];
        }
        
        UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];
        UIView *freeContainer = [toolTipView viewWithTag:JxCalendarToolTipTagFreeChoiceContainer];
        UIPickerView *freeChoiceTimePicker  = [freeContainer viewWithTag:JxCalendarToolTipTagFreeChoiceTimePicker];
        [freeChoiceTimePicker reloadAllComponents];
    }
    
    NSIndexPath *path = [self getIndexPathForDate:self.toolTipDate];
    
    [self updateRangeForCell:(JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path] atIndexPath:path animated:YES];
    
    [self updateToolTipAnimated:YES];
    
    
}
- (NSString *)getTitleForDayType:(JxCalendarDayType)type{
    switch (type) {
        case JxCalendarDayTypeWholeDay:
            return NSLocalizedString(kJxCalendarDayTypeOptionWholeDay, nil);
        case JxCalendarDayTypeHalfDay:
            return NSLocalizedString(kJxCalendarDayTypeOptionHalfDay, nil);
        case JxCalendarDayTypeHalfDayMorning:
            return NSLocalizedString(kJxCalendarDayTypeOptionHalfDayMorning, nil);
        case JxCalendarDayTypeHalfDayAfternoon:
            return NSLocalizedString(kJxCalendarDayTypeOptionHalfDayAfternoon, nil);
        case JxCalendarDayTypeWorkDay:
            return NSLocalizedString(kJxCalendarDayTypeOptionWorkDay, nil);
        case JxCalendarDayTypeFreeChoice:
            return NSLocalizedString(kJxCalendarDayTypeOptionFreeChoice, nil);
        case JxCalendarDayTypeFreeChoiceMin:
        case JxCalendarDayTypeFreeChoiceMax:
            return NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMinMax, nil);
        case JxCalendarDayTypeUnknown:
            return NSLocalizedString(kJxCalendarDayTypeOptionUnknown, nil);
    }
}
- (IBAction)freeChoiceChange:(id)sender{
    // timepicker oder ähnliches öffnen
    
    UIView *toolTipView = [self.view viewWithTag:JxCalendarToolTipTagView];

    
    CGFloat newWidth = 250.0f;
    
    NSIndexPath *indexPath = [self getIndexPathForDate:self.toolTipDate];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = CGRectMake(cell.frame.origin.x-self.collectionView.contentOffset.x,
                             cell.frame.origin.y-self.collectionView.contentOffset.y,
                             cell.frame.size.width,
                             cell.frame.size.height);
    
    [self updateToolTipSizeFromSourceRect:rect withSize:CGSizeMake(newWidth, toolTipView.frame.size.height) animated:YES withVisibleArea:JxCalendarToolTipAreaFreeChoice];
    
//    [self updateToolTipSizeWithRect:CGRectMake(toolTipView.frame.origin.x- ((toolTipView.frame.size.width-newWidth)/2),
//                                               toolTipView.frame.origin.y,
//                                               newWidth,//self.view.frame.size.width-(kJxCalendarToolTipMinDistanceToBorder*2),
//                                               toolTipView.frame.size.height)
//                           animated:YES
//                    withVisibleArea:JxCalendarToolTipAreaFreeChoice];
    
}

#pragma mark <UIPickerDataSource>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        return 3;
    }
    return 5;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        switch (component) {
            case 0:{
                int count = 0;
                JxCalendarDayTypeMask mask = [self.dataSource availableDayTypesForDate:self.toolTipDate];
                if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax) {
                    count++;
                }
                if ((mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin) {
                    count++;
                }
                return count;
            }break;
            case 1:
                return 24;
            case 2:
                return 60;
            default:
                return 1;
                break;
        }
        
    }else{
        switch (component) {
            case 0:
            case 3:
                return 24;
            case 1:
            case 4:
                return 60;
            default:
                return 1;
                break;
        }
    }
}
#pragma mark <UIPickerDelegate>


//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//    return pickerView.frame.size.width/5;
//}
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED;

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    //NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"titel" attributes:@{}];
    return @"~";
}
- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *rowString = [NSString stringWithFormat:@"%2ld", (long)row];
    rowString = [rowString stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    
    
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        switch (component) {
            case 0:{
                NSMutableArray *types = [NSMutableArray array];
                
                JxCalendarDayTypeMask mask = [self.dataSource availableDayTypesForDate:self.toolTipDate];
                if ((mask & JxCalendarDayTypeMaskFreeChoiceMax) == JxCalendarDayTypeMaskFreeChoiceMax) {
                    [types addObject:[[NSAttributedString alloc] initWithString:NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMax, nil) attributes:@{}]];
                }
                if ((mask & JxCalendarDayTypeMaskFreeChoiceMin) == JxCalendarDayTypeMaskFreeChoiceMin) {
                    [types addObject:[[NSAttributedString alloc] initWithString:NSLocalizedString(kJxCalendarDayTypeOptionFreeChoiceMin, nil) attributes:@{}]];
                }
                
                return types[row];
            }
            default:
                return [[NSAttributedString alloc] initWithString:rowString attributes:@{}];
        }
    }else{
        switch (component) {
            case 2:
                return [[NSAttributedString alloc] initWithString:@" – " attributes:@{}];
            default:
                return [[NSAttributedString alloc] initWithString:rowString attributes:@{}];
        }
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    JxCalendarRangeElement *rangeElement = [self.dataSource rangeElementForDate:self.toolTipDate];
    
    NSDate *start, *end;
    JxCalendarDayType newDayType = rangeElement.dayType;
    
    NSDateComponents *components = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.toolTipDate];
    
    if (rangeElement.dayType == JxCalendarDayTypeFreeChoiceMin || rangeElement.dayType == JxCalendarDayTypeFreeChoiceMax) {
        
        if (component == 0) {
            
            if ([pickerView numberOfRowsInComponent:0] < 2) {
                return;
            }
            
            if(row == 0){
                newDayType = JxCalendarDayTypeFreeChoiceMax;
            }else{
                newDayType = JxCalendarDayTypeFreeChoiceMin;
            }

        }
        
        
        components.hour = [pickerView selectedRowInComponent:1];
        components.minute = [pickerView selectedRowInComponent:2];
        components.second = 0;
        NSDate *date = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
        
        if (newDayType == JxCalendarDayTypeFreeChoiceMax) {
            //von
            start = date;
            components.hour = self.lengthOfDayInHours-1;
            components.minute = 59;
            components.second = 59;
            
            end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
            
        }else{
            //bis
            components.hour = 0;
            components.minute = 0;
            components.second = 0;
            
            start = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
            end = date;
        }
        
    }else{
        if (component == 2) {
            return;
        }
        //check hours
        if (component == 3) {
            if ([pickerView selectedRowInComponent:0] > row) {
                [pickerView selectRow:row inComponent:0 animated:YES];
            }
        }else if (component == 0) {
            if ([pickerView selectedRowInComponent:3] < row) {
                [pickerView selectRow:row inComponent:3 animated:YES];
            }
        }
        
        //check minutes
        if ([pickerView selectedRowInComponent:0] == [pickerView selectedRowInComponent:3]) {
            //gleiche stunde
            if (component > 2) {
                if ([pickerView selectedRowInComponent:1] > [pickerView selectedRowInComponent:4]) {
                    [pickerView selectRow:row inComponent:1 animated:YES];
                }
            }else if(component < 2){
                if ([pickerView selectedRowInComponent:1] > [pickerView selectedRowInComponent:4]) {
                    [pickerView selectRow:[pickerView selectedRowInComponent:1] inComponent:4 animated:YES];
                }
            }
        }
        
        components.hour = [pickerView selectedRowInComponent:0];
        components.minute = [pickerView selectedRowInComponent:1];
        components.second = 0;
        start = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];
        
        components.hour = [pickerView selectedRowInComponent:3];
        components.minute = [pickerView selectedRowInComponent:4];
        components.second = 0;
        end = [self.dataSource.calendar dateByAddingComponents:components toDate:self.toolTipDate options:NSCalendarMatchStrictly];

        if ([end timeIntervalSinceDate:start] > self.lengthOfDayInHours*60*60) {
            end = [self.dataSource.calendar dateByAddingUnit:NSCalendarUnitHour value:self.lengthOfDayInHours toDate:start options:NSCalendarMatchStrictly];
            NSDateComponents *newEndComponents = [self.dataSource.calendar components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:end];
            
            [pickerView selectRow:newEndComponents.hour inComponent:3 animated:YES];
            [pickerView selectRow:newEndComponents.minute inComponent:4 animated:YES];
        }
    }
        
    JxCalendarRangeElement *element = [[JxCalendarRangeElement alloc] initWithDate:self.toolTipDate
                                                                        andDayType:newDayType
                                                                     withStartDate:start
                                                                        andEndDate:end];
    
    if ([self.delegate respondsToSelector:@selector(calendar:didRange:whileOnAppearance:)]) {
        [self.delegate calendar:[self getCalendarOverview] didRange:element whileOnAppearance:[self getAppearance]];
    }
    
    
    NSIndexPath *path = [self getIndexPathForDate:self.toolTipDate];
    
    [self updateRangeForCell:(JxCalendarCell *)[self.collectionView cellForItemAtIndexPath:path] atIndexPath:path animated:YES];
    
}

@end
