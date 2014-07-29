//
//  AprilTestSecondViewController.h
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AprilTestSecondViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property NSMutableArray * currentConcernRanking;
@property int studyNum;
@property (strong, nonatomic) IBOutlet UIScrollView *dataWindow;
@property (strong, nonatomic) IBOutlet UIScrollView *mapWindow;

@property (strong, nonatomic) IBOutlet UIScrollView *titleWindow;
@property NSString * url;
@property (strong, nonatomic) IBOutlet UISlider *hoursAfterStorm;
@property (strong, nonatomic) IBOutlet UILabel *hoursAfterStormLabel;
@property (strong, nonatomic) IBOutlet UISlider *thresholdValue;
@property (strong, nonatomic) IBOutlet UILabel *thresholdValueLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UIPickerView *sortingPicker;

@end
