//
// Copyright (c) 2012 Jason Kozemczak
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//


#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendarView.h"

#define BUTTON_MARGIN 4
#define CALENDAR_MARGIN 0
#define TOP_HEIGHT 44
#define DAYS_HEADER_HEIGHT 20
#define DEFAULT_CELL_WIDTH 44
#define CELL_BORDER_WIDTH 0

@class CALayer;
@class CAGradientLayer;

@interface GradientView : UIView

@property(nonatomic, strong, readonly) CAGradientLayer *gradientLayer;
- (void)setColors:(NSArray *)colors;

@end

@implementation GradientView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
    return (CAGradientLayer *)self.layer;
}

- (void)setColors:(NSArray *)colors {
    /*NSMutableArray *cgColors = [NSMutableArray array];
     for (UIColor *color in colors) {
     [cgColors addObject:(__bridge id)color.CGColor];
     }
     self.gradientLayer.colors = cgColors;*/
}

@end


@interface DateButton : UIButton

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) CKDateItem *dateItem;
@property (nonatomic, strong) NSCalendar *calendar;

@end

@implementation DateButton

- (void)setDate:(NSDate *)date {
    _date = date;
    NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
    [self setTitle:[NSString stringWithFormat:@"%ld", (long)comps.day] forState:UIControlStateNormal];
}

@end

@implementation CKDateItem

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _backgroundColor = [UIColor whiteColor];
        _textColor = [UIColor whiteColor];
        
        _selectedBackgroundColor = RGB(53.0, 191.0, 217.0);
        _selectedTextColor = [UIColor whiteColor];
        
    }
    return self;
}

@end

@interface CKCalendarView ()

@property(nonatomic, strong) UIView *highlight;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) GradientView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSMutableArray *bottomIndicators;

@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic, strong) NSMutableArray *rowLines;

@property (nonatomic, strong) NSDate *monthShowing;
@property (nonatomic, strong) NSCalendar *calendar;
@property(nonatomic, assign) CGFloat cellWidth;

@end

@implementation CKCalendarView

@synthesize highlight = _highlight;
@synthesize titleLabel = _titleLabel;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize calendarContainer = _calendarContainer;
@synthesize daysHeader = _daysHeader;
@synthesize dayOfWeekLabels = _dayOfWeekLabels;
@synthesize dateButtons = _dateButtons;
@synthesize rowLines = _rowLines;
@synthesize bottomIndicators = _bottomIndicators;

@synthesize monthShowing = _monthShowing;
@synthesize calendar = _calendar;
@synthesize dateFormatter = _dateFormatter;

@synthesize delegate = _delegate;

@synthesize cellWidth = _cellWidth;

@synthesize calendarStartDay = _calendarStartDay;
@synthesize onlyShowCurrentMonth = _onlyShowCurrentMonth;
@synthesize adaptHeightToNumberOfWeeksInMonth = _adaptHeightToNumberOfWeeksInMonth;

@synthesize stillActive;

@dynamic locale;

- (instancetype)init {
    return [self initWithStartDay:startSunday selectedDay:nil];
}

- (instancetype)initWithStartDay:(CKCalendarStartDay)firstDay selectedDay:(NSDate*)selectedDate {
    return [self initWithStartDay:firstDay frame:CGRectMake(0, 0, 320, 320) selectedDay:selectedDate];
}

- (void)_init:(CKCalendarStartDay)firstDay selectedDate:(NSDate*)selectedDate {
    
    self.selectedDate = selectedDate;
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    
    self.cellWidth = DEFAULT_CELL_WIDTH;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateFormatter.dateFormat = @"LLLL yyyy";
    
    self.calendarStartDay = firstDay;
    self.onlyShowCurrentMonth = YES;
    self.adaptHeightToNumberOfWeeksInMonth = YES;
    
    self.layer.cornerRadius = 0.0f;
    
    UIView *highlight = [[UIView alloc] initWithFrame:CGRectZero];
    highlight.backgroundColor = [UIColor clearColor];
    highlight.layer.cornerRadius = 0.0f;
    [self addSubview:highlight];
    self.highlight = highlight;
    
    // SET UP THE HEADER
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor greenBoatDay];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"cal_arrow_left"] forState:UIControlStateNormal];
    //[prevButton setImage:[UIImage imageNamed:@"cal_arrow_left_white"] forState:UIControlStateHighlighted];
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(_moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    self.prevButton = prevButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"cal_arrow_right"] forState:UIControlStateNormal];
    //[nextButton setImage:[UIImage imageNamed:@"cal_arrow_right_white"] forState:UIControlStateHighlighted];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [nextButton addTarget:self action:@selector(_moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    self.nextButton = nextButton;
    
    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    calendarContainer.layer.borderWidth = 1.0f;
    calendarContainer.layer.borderColor = [UIColor clearColor].CGColor;
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.layer.cornerRadius = 0.0f;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;
    
    GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.calendarContainer addSubview:daysHeader];
    daysHeader.backgroundColor = [UIColor mediumGreenBoatDay];
    self.daysHeader = daysHeader;
    
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        //dayOfWeekLabel.shadowColor = [UIColor whiteColor];
        //dayOfWeekLabel.shadowOffset = CGSizeMake(0, 1);
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    self.dayOfWeekLabels = labels;
    [self _updateDayOfWeekLabels];
    
    NSMutableArray *lines = [NSMutableArray array];
    for (int i = 1; i < 6; ++i) {
        UIView *line = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 1.0)];
        line.backgroundColor = [UIColor whiteColor];
        [lines addObject:line];

    }
    self.rowLines = lines;
    
    // at most we'll need 42 buttons, so let's just bite the bullet and make them now...
    NSMutableArray *dateButtons = [NSMutableArray array];
    NSMutableArray *bottomIndicators = [NSMutableArray array];

    for (NSInteger i = 1; i <= 42; i++) {
        
        DateButton *dateButton = [DateButton buttonWithType:UIButtonTypeCustom];
        dateButton.calendar = self.calendar;
        [dateButton addTarget:self action:@selector(_dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *bottomIndicator = [[UIView alloc] init];
        bottomIndicator.frame = CGRectMake(6.0, 40.0, 34.0, 6.0);
        bottomIndicator.backgroundColor = [UIColor clearColor];
        [dateButton addSubview:bottomIndicator];
        
        [dateButtons addObject:dateButton];
        [bottomIndicators addObject:bottomIndicator];

    }
    self.dateButtons = dateButtons;
    self.bottomIndicators = bottomIndicators;
    
    // initialize the thing
    if (self.selectedDate) {
        self.monthShowing = self.selectedDate;
    }
    else {
        self.monthShowing = [NSDate date];
    }
    
    [self _setDefaultStyle];
    
    [self layoutSubviews];
}

- (instancetype)initWithStartDay:(CKCalendarStartDay)firstDay frame:(CGRect)frame selectedDay:(NSDate*)selectedDate {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init:firstDay selectedDate:selectedDate];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStartDay:startSunday frame:frame selectedDay:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init:startSunday selectedDate:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    self.cellWidth = ((floorf(containerWidth / 7.0)) - CELL_BORDER_WIDTH) + 1;
    
    NSInteger numberOfWeeksToShow = 6;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self _numberOfWeeksInMonthContainingDate:self.monthShowing];
    }
    CGFloat containerHeight = (numberOfWeeksToShow * (self.cellWidth + CELL_BORDER_WIDTH) + DAYS_HEADER_HEIGHT);
    
    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT;
    self.frame = newFrame;
    
    self.highlight.frame = CGRectMake(0, TOP_HEIGHT - 1, self.bounds.size.width, 1);
    
    self.titleLabel.text = [[self.dateFormatter stringFromDate:_monthShowing] uppercaseString];
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN, BUTTON_MARGIN , 48, 38);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - 48 - BUTTON_MARGIN, BUTTON_MARGIN , 48, 38);
    
    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.titleLabel.frame), containerWidth, containerHeight);
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);
    
    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in self.dayOfWeekLabels) {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + CELL_BORDER_WIDTH, lastDayFrame.origin.y, self.cellWidth, self.daysHeader.frame.size.height);
        lastDayFrame = dayLabel.frame;
    }
    
    for (DateButton *dateButton in self.dateButtons) {
        [dateButton removeFromSuperview];
    }
    
    for (UIView *line in self.rowLines) {
        [line removeFromSuperview];
    }
    
    NSDate *date = [self _firstDayOfMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        while ([self _placeInWeekForDate:date] != 0) {
            date = [self _previousDay:date];
        }
    }
    
    NSDate *endDate = [self _firstDayOfNextMonthContainingDate:self.monthShowing];
    if (!self.onlyShowCurrentMonth) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeekOfMonth:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }
    
    NSUInteger dateButtonPosition = 0;
    while ([date laterDate:endDate] != date) {
        DateButton *dateButton = self.dateButtons[dateButtonPosition];
        
        UIView *bottomIndicator = self.bottomIndicators[dateButtonPosition];
        bottomIndicator.backgroundColor = [UIColor clearColor];
        
        dateButton.date = date;
        CKDateItem *item = [[CKDateItem alloc] init];
        
        if([self.maximumStartDate timeIntervalSinceDate:date] > 0) {
            item.textColor = [UIColor mediumGrayBoatDay];
            item.backgroundColor = [UIColor lightGrayBoatDay];
            dateButton.userInteractionEnabled = NO;
        }
        else {
            if([self.maximumEndDate timeIntervalSinceDate:date] < 0) {
                item.textColor = [UIColor mediumGrayBoatDay];
                item.backgroundColor = [UIColor lightGrayBoatDay];
                dateButton.userInteractionEnabled = NO;
            }
            else {
                dateButton.userInteractionEnabled = YES;
                
                //If is today
                if ([self _dateIsToday:dateButton.date]) {
                    
                    item.textColor = RGB(53.0, 191.0, 217.0);
                    item.backgroundColor = [UIColor lightGrayBoatDay];
                    
                    if (![date isSameDay:self.selectedDate]) {
                        [self setBottomIndicatorsBackgroundColor:RGB(53.0, 191.0, 217.0)
                                                         forDate:date
                                                         atIndex:dateButtonPosition];
                    }

                } else
                    if (!self.onlyShowCurrentMonth && [self _compareByMonth:date toDate:self.monthShowing] != NSOrderedSame) {
                        if([date timeIntervalSinceDate:[NSDate date]] > 0 ){
                            //if is next month
                            item.textColor = [UIColor mediumGrayBoatDay];
                            item.backgroundColor = [UIColor lightGrayBoatDay];
                            
                            if (![date isSameDay:self.selectedDate]) {
                                [self setBottomIndicatorsBackgroundColor:[UIColor mediumGrayBoatDay]
                                                                 forDate:date
                                                                 atIndex:dateButtonPosition];
                            }

                        }
                        else{
                            //if is previous month
                            item.textColor = [UIColor mediumGrayBoatDay];
                            item.backgroundColor = [UIColor lightGrayBoatDay];
                            
                            if (![date isSameDay:self.selectedDate]) {
                                [self setBottomIndicatorsBackgroundColor:[UIColor mediumGrayBoatDay]
                                                                 forDate:date
                                                                 atIndex:dateButtonPosition];
                            }
                            
                        }
                    }
                    else {
                        //if is current month
                        item.textColor = [UIColor darkGrayBoatDay];
                        item.backgroundColor = [UIColor lightGrayBoatDay];
                        
                        [self setBottomIndicatorsBackgroundColor:RGB(53.0, 191.0, 217.0)
                                                         forDate:date
                                                         atIndex:dateButtonPosition];
                        
                    }
       
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(calendar:configureDateItem:forDate:)]) {
            [self.delegate calendar:self configureDateItem:item forDate:date];
        }
        
        if (self.selectedDate && [self date:self.selectedDate isSameDayAsDate:date]) {
            dateButton.userInteractionEnabled = NO;
            [dateButton setTitleColor:item.selectedTextColor forState:UIControlStateNormal];
            [dateButton setBackgroundImage:[self imageWithColor:item.selectedBackgroundColor] forState:UIControlStateNormal];
        } else {
            [dateButton setTitleColor:item.textColor forState:UIControlStateNormal];
            [dateButton setTitleColor:item.selectedTextColor forState:UIControlStateHighlighted];
            [dateButton setBackgroundImage:[self imageWithColor:item.backgroundColor] forState:UIControlStateNormal];
            [dateButton setBackgroundImage:[self imageWithColor:item.selectedBackgroundColor] forState:UIControlStateHighlighted];
            
        }
        
        dateButton.frame = [self _calculateDayCellFrame:date andPosition:dateButtonPosition];
        
        [self.calendarContainer addSubview:dateButton];
        
        if(stillActive){
            float duration = (3 + arc4random() % (6+1-1)) * .1;
            
            [UIView transitionWithView:dateButton
                              duration:duration
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{} completion:^(BOOL finished){}];
        }
        
        date = [self _nextDay:date];
        dateButtonPosition++;
    }
    
    for (int row = 0; row < self.rowLines.count; row++) {
        
        UIView *line = self.rowLines[row];
        CGFloat y = ((row+1) * (self.cellWidth + CELL_BORDER_WIDTH)) + DAYS_HEADER_HEIGHT;
        
        line.frame = CGRectMake(0.0, y, line.frame.size.width, line.frame.size.height);
        [self.calendarContainer addSubview:line];
        
    }
    
}

- (void) setBottomIndicatorsBackgroundColor:(UIColor*)color forDate:(NSDate*)date atIndex:(NSInteger)index {

    if ([self.delegate respondsToSelector:@selector(calendar:bottomIndicatorForDate:)]) {
        
        if ([self.delegate calendar:self bottomIndicatorForDate:date]) {
            UIView *bottomIndicator = self.bottomIndicators[index];
            bottomIndicator.backgroundColor = color;
        }
        
    }
}

- (void)_updateDayOfWeekLabels {
    NSArray *weekdays = [self.dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }
    
    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [self.dayOfWeekLabels[i] setText:[day uppercaseString]];
        i++;
    }
}

- (void)setCalendarStartDay:(CKCalendarStartDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self _updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self _firstDayOfMonthContainingDate:aMonthShowing];
    [self setNeedsLayout];
}

- (void)setOnlyShowCurrentMonth:(BOOL)onlyShowCurrentMonth {
    _onlyShowCurrentMonth = onlyShowCurrentMonth;
    [self setNeedsLayout];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout];
}

- (void)selectDate:(NSDate *)date makeVisible:(BOOL)visible {
    NSMutableArray *datesToReload = [NSMutableArray array];
    if (self.selectedDate) {
        [datesToReload addObject:self.selectedDate];
    }
    if (date) {
        [datesToReload addObject:date];
    }
    self.selectedDate = date;
    /*[self reloadDates:datesToReload];
     if (visible && date) {
     self.monthShowing = date;
     }*/
}

- (void)reloadData {
    self.selectedDate = nil;
    [self setNeedsLayout];
}

- (void)reloadDates:(NSArray *)dates {
    [self setNeedsLayout];
}

- (void)_setDefaultStyle {
    self.backgroundColor = [UIColor lightGrayBoatDay];
    
    [self setTitleColor:[UIColor whiteColor]];
    [self setTitleFont:[UIFont abelFontWithSize:16.0]];
    
    [self setDayOfWeekFont:[UIFont abelFontWithSize:12.0]];
    [self setDayOfWeekTextColor:[UIColor whiteColor]];
    [self setDayOfWeekBottomColor: [UIColor clearColor] topColor:[UIColor clearColor]];
    
    [self setDateFont:[UIFont abelFontWithSize:20.0]];
    [self setDateBorderColor:[UIColor clearColor]];
}

- (CGRect)_calculateDayCellFrame:(NSDate *)date andPosition:(NSInteger)position {
    NSInteger numberOfDaysSinceBeginningOfThisMonth = position;
    NSInteger row = numberOfDaysSinceBeginningOfThisMonth / 7;
	
    NSInteger placeInWeek = [self _placeInWeekForDate:date];
    
    return CGRectMake(placeInWeek * (self.cellWidth + CELL_BORDER_WIDTH), (row * (self.cellWidth + CELL_BORDER_WIDTH)) + CGRectGetMaxY(self.daysHeader.frame) + CELL_BORDER_WIDTH, self.cellWidth, self.cellWidth);
}

- (void)_moveCalendarToNextMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)_moveCalendarToPreviousMonth {
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    NSDate *newMonth = [self.calendar dateByAddingComponents:comps toDate:self.monthShowing options:0];
    if ([self.delegate respondsToSelector:@selector(calendar:willChangeToMonth:)] && ![self.delegate calendar:self willChangeToMonth:newMonth]) {
        return;
    } else {
        self.monthShowing = newMonth;
        if ([self.delegate respondsToSelector:@selector(calendar:didChangeToMonth:)] ) {
            [self.delegate calendar:self didChangeToMonth:self.monthShowing];
        }
    }
}

- (void)_dateButtonPressed:(id)sender {
    DateButton *dateButton = sender;
    NSDate *date = dateButton.date;
    if ([date isEqualToDate:self.selectedDate]) {
        // deselection..
        if ([self.delegate respondsToSelector:@selector(calendar:willDeselectDate:)] && ![self.delegate calendar:self willDeselectDate:date]) {
            return;
        }
        date = nil;
    } else if ([self.delegate respondsToSelector:@selector(calendar:willSelectDate:)] && ![self.delegate calendar:self willSelectDate:date]) {
        return;
    }
    
    [self selectDate:date makeVisible:YES];
    if ([self.delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [self.delegate calendar:self didSelectDate:date];
    }
    [self setNeedsLayout];
}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setMonthButtonColor:(UIColor *)color {
    
    [self.prevButton setImage:[UIImage imageNamed:@"cal_arrow_left"] forState:UIControlStateNormal];
    //[self.prevButton setImage:[UIImage imageNamed:@"cal_arrow_left_white"] forState:UIControlStateHighlighted];
    
    [self.nextButton setImage:[UIImage imageNamed:@"cal_arrow_right"] forState:UIControlStateNormal];
    //[self.nextButton setImage:[UIImage imageNamed:@"cal_arrow_right_white"] forState:UIControlStateHighlighted];
    
}

- (void)setInnerBorderColor:(UIColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor {
    [self.daysHeader setColors:@[topColor, bottomColor]];
}

- (void)setDateFont:(UIFont *)font {
    for (DateButton *dateButton in self.dateButtons) {
        dateButton.titleLabel.font = font;
    }
}
- (UIFont *)dateFont {
    return (self.dateButtons.count > 0) ? ((DateButton *)[self.dateButtons lastObject]).titleLabel.font : nil;
}

- (void)setDateBorderColor:(UIColor *)color {
    self.calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor {
    return self.calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)_firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)_firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (BOOL)dateIsInCurrentMonth:(NSDate *)date {
    return ([self _compareByMonth:date toDate:self.monthShowing] != NSOrderedSame);
}

- (NSComparisonResult)_compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate {
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];
    
    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)_placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger result = (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
    return result;
}

- (BOOL)_dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)_numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)_nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)_previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)_numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
