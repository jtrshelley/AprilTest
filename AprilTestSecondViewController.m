//
//  AprilTestSecondViewController.m
//  AprilTest
//
//  Created by Tia on 4/7/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestSecondViewController.h"
#import "AprilTestTabBarController.h"
#import "AprilTestSimRun.h"
#import "AprilTestVariable.h"
#import "FebTestIntervention.h"
#import "FebTestWaterDisplay.h"
#import "AprilTestEfficiencyView.h"
#import "AprilTestNormalizedVariable.h"

@interface AprilTestSecondViewController ()

@end

@implementation AprilTestSecondViewController
@synthesize studyNum = _studyNum;
@synthesize url = _url;
@synthesize dataWindow = _dataWindow;
@synthesize mapWindow = _mapWindow;
@synthesize titleWindow = _titleWindow;
@synthesize thresholdValue = _thresholdValue;
@synthesize hoursAfterStorm = _hoursAfterStorm;
@synthesize thresholdValueLabel = _thresholdValueLabel;
@synthesize hoursAfterStormLabel = _hoursAfterStormLabel;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize scenarioNames = _scenarioNames;

NSMutableArray * trialRuns;
NSMutableArray * trialRunsNormalized;
NSMutableArray * waterDisplays;
NSMutableArray * maxWaterDisplays;
NSMutableArray * efficiency;
NSMutableArray *lastKnownConcernProfile;
NSMutableArray *bgCols;
UILabel *redThreshold;
NSArray *arrStatus;
NSMutableDictionary *scoreColors;
int lastMoved = 0;
int trialNum = 0;
bool passFirstThree = FALSE;
float kOFFSET_FOR_KEYBOARD = 425.0;
float offsetForMoving = 0.0;
float originalOffset = 0.0;
UITextField *edittingTX;

@synthesize currentConcernRanking = _currentConcernRanking;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AprilTestTabBarController *tabControl = (AprilTestTabBarController *)[self parentViewController];
    _currentConcernRanking = tabControl.currentConcernRanking;
    _studyNum = tabControl.studyNum;
    _url = tabControl.url;
    trialRuns = [[NSMutableArray alloc] init];
    trialRunsNormalized = [[NSMutableArray alloc] init];
    waterDisplays = [[NSMutableArray alloc] init];
    maxWaterDisplays = [[NSMutableArray alloc] init];
    efficiency = [[NSMutableArray alloc] init];
    _scenarioNames = [[NSMutableArray alloc] init];
    _mapWindow.delegate = self;
    _dataWindow.delegate = self;
    _titleWindow.delegate = self;
    bgCols = [[NSMutableArray alloc] init];
    float translateThreshValue = _thresholdValue.value/_thresholdValue.maximumValue * _thresholdValue.frame.size.width;
    redThreshold = [[UILabel alloc] initWithFrame: CGRectMake(_thresholdValue.frame.origin.x + translateThreshValue + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4 - translateThreshValue , _thresholdValue.frame.size.height/2)];
    [redThreshold setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:redThreshold];
    [self.view sendSubviewToBack:redThreshold];
    UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradientScale.png"]];
    [gradient setFrame: CGRectMake(_thresholdValue.frame.origin.x + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4, _thresholdValue.frame.size.height/2)];
    [self.view addSubview: gradient];
    [self.view sendSubviewToBack:gradient];
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = @"Map and Score";
    valueLabel.frame =CGRectMake(20, 55, 0, 0);
    valueLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [valueLabel sizeToFit ];
    valueLabel.textColor = [UIColor blackColor];
    [self.view addSubview:valueLabel];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingIndicator.center = CGPointMake(512, 300);
    _loadingIndicator.color = [UIColor blueColor];
    [self.view addSubview:_loadingIndicator];

     arrStatus = [[NSArray alloc] initWithObjects:@"Trial Number", @"Best Score", @"Public Cost", @"Private Cost", @"Rainwater to Neighbors", @"Rainwater from Neighbors", @"Intervention Efficiency", @"% Rainwater Infiltrated", nil];
    
    scoreColors = [[NSMutableDictionary alloc] initWithObjects:
                   [[NSArray alloc] initWithObjects : [UIColor colorWithHue:.165 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.08 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.16 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.24 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.42 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.32 saturation:.3 brightness:9 alpha: 1.0], [UIColor colorWithHue:.4 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.48 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.56 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.64 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.72 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.8 saturation:.3 brightness:.9 alpha: 1.0], [UIColor colorWithHue:.88 saturation:.3 brightness:.9 alpha: 1.0], nil ]    forKeys: [[NSArray alloc] initWithObjects: @"publicCost", @"publicCostI", @"publicCostD", @"publicCostM", @"privateCost", @"privateCostI", @"privateCostD", @"privateCostM", @"impactingMyNeighbors", @"neighborImpactingMe", @"groundwaterInfiltration", @"puddleTime", @"efficiencyOfIntervention", nil] ];
    
}

- (void) viewWillAppear:(BOOL)animated{
    //[trialRuns removeAllObjects];
    //[waterDisplays removeAllObjects];
    //[efficiency removeAllObjects];
    for (UIView *view in [_titleWindow subviews]){
        [view removeFromSuperview];
    }
    for( UIView *view in [_dataWindow subviews]){
        [view removeFromSuperview];
    }
    for (UIView *view in [_mapWindow subviews]){
        [view removeFromSuperview];
    }
//    int prevTrialNum = trialNum;
//    trialNum = 0;
    for (int i =0; i < trialNum; i++){
        [self drawTrial:i];
    }
    [self drawTitles];
    [_dataWindow setContentOffset:CGPointMake(0, 0)];
    [_mapWindow setContentOffset:CGPointMake(0,0 )];
    [_dataWindow flashScrollIndicators];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pullNextRun:(id)sender {
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    [self loadNextSimulationRun];
}

- (void)loadNextSimulationRun{

    //_url = @"http://192.168.1.42";
    _url = @"http://127.0.0.1";
    //_url= @"http://10.8.234.182";
    _studyNum = 6;
    NSString * urlPlusFile = [NSString stringWithFormat:@"%@/%@", _url, @"simOutput.php"];
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFile ] ];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    //NSLog(@"%@", request);
    NSString *content;
    while( !content){
        NSURLResponse *response;
        NSError *err;
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnData bytes]) content = [NSString stringWithUTF8String:[returnData bytes]];
        NSLog(@"responseData: %@", content);
    }
    NSString *urlPlusFileN = [NSString stringWithFormat:@"%@/%@", _url, @"simOutputN.php"];
    NSString *myRequestStringN = [[NSString alloc] initWithFormat:@"trialID=%d&studyID=%d", trialNum, _studyNum ];
    NSData *myRequestDataN = [ NSData dataWithBytes: [ myRequestStringN UTF8String ] length: [ myRequestStringN length ] ];
    NSMutableURLRequest *requestN = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlPlusFileN ] ];
    [ requestN setHTTPMethod: @"POST" ];
    [ requestN setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ requestN setHTTPBody: myRequestDataN ];
    NSLog(@"%@", request);
    NSString *contentN;
    while( !contentN){
        NSURLResponse *responseN;
        NSError *err;
        NSData *returnDataN = [ NSURLConnection sendSynchronousRequest: requestN returningResponse:&responseN error:&err];
        //NSLog(@"error: %@", err);
        
        if( [returnDataN bytes]) contentN = [NSString stringWithUTF8String:[returnDataN bytes]];
       //NSLog(@"responseData: %@", contentN);
    }
    
    if(content != NULL && content.length > 100 && contentN != NULL){
        AprilTestSimRun *simRun = [[AprilTestSimRun alloc] init:content withTrialNum:trialNum];
        AprilTestNormalizedVariable *simRunNormal = [[AprilTestNormalizedVariable alloc] init: contentN withTrialNum:trialNum];
        [trialRunsNormalized addObject:simRunNormal];
        [trialRuns addObject: simRun];
        [self drawTrial: trialNum];
        trialNum++;
    }
    [_loadingIndicator stopAnimating];
    
}

-(void) drawTrial: (int) trial{
    //NSLog (@"Drawing trial number: %d", trial);
    AprilTestSimRun *simRun = [trialRuns objectAtIndex:trial];
    AprilTestNormalizedVariable *simRunNormal = [trialRunsNormalized objectAtIndex:trial];
    FebTestIntervention *interventionView = [[FebTestIntervention alloc] initWithPositionArray:simRun.map andFrame:(CGRectMake(20, 175 * (trial) + 40, 115, 125))];
    interventionView.view = _mapWindow;
    [interventionView updateView];
//    UILabel *trialLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 175*(trial+1)-47, 0, 0)];
//    trialLabel.text = [NSString stringWithFormat:  @"Trial %d", trial + 1];
//    trialLabel.font = [UIFont systemFontOfSize:14.0];
//    [trialLabel sizeToFit];
//    trialLabel.textColor = [UIColor blackColor];
//    [_mapWindow addSubview:trialLabel];
    [_mapWindow setContentSize: CGSizeMake(_mapWindow.contentSize.width, (simRun.trialNum+1)*200)];
    
    //int scoreBar=0;
    float priorityTotal= 0;
    float scoreTotal = 0;
    
    for(int i = 0; i < _currentConcernRanking.count; i++){
        //NSLog(@"%@", [_currentConcernRanking objectAtIndex:i] );
        priorityTotal += [(AprilTestVariable *)[_currentConcernRanking objectAtIndex:i] currentConcernRanking];
    }
    UITextField *tx;
    if(trial >= _scenarioNames.count){
        tx = [[UITextField alloc] initWithFrame:CGRectMake(20, 175*(trial)+5, 245, 30)];
        tx.borderStyle = UITextBorderStyleRoundedRect;
        tx.font = [UIFont systemFontOfSize:15];
        tx.placeholder = @"enter text";
        tx.autocorrectionType = UITextAutocorrectionTypeNo;
        tx.keyboardType = UIKeyboardTypeDefault;
        tx.returnKeyType = UIReturnKeyDone;
        tx.clearButtonMode = UITextFieldViewModeWhileEditing;
        tx.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tx.delegate = self;
        tx.text = [NSString stringWithFormat:  @"Trial %d", trial + 1];
        [_mapWindow addSubview:tx];
        [_scenarioNames addObject:tx];
    } else {
        tx = [_scenarioNames objectAtIndex:trial];
        tx.frame = CGRectMake(20, 175*(trial)+5, 245, 30);
        [_mapWindow addSubview:tx];
    }
    
    int width = 0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    NSMutableArray *scoreVisVals = [[NSMutableArray alloc] init];
    NSMutableArray *scoreVisNames = [[NSMutableArray alloc] init];
    int visibleIndex = 0;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){
        
        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        if(simRun.trialNum ==0 && visibleIndex %2 == 0 && currentVar.widthOfVisualization > 0){
            UILabel *bgCol = [[UILabel alloc] initWithFrame:CGRectMake(width, -2, currentVar.widthOfVisualization - 10, _dataWindow.contentSize.height + 100)];
            bgCol.backgroundColor = [UIColor whiteColor];
            bgCol.layer.borderColor = [UIColor lightGrayColor].CGColor;
            bgCol.layer.borderWidth = 2.0;
            [_dataWindow addSubview:bgCol];
            [bgCols addObject:bgCol];
        }
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"Installation Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.publicInstallCost] ]]   withConcernPosition:width+25 andyValue: (simRun.trialNum) * 175 + 20 ];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt: simRun.publicDamages]]] withConcernPosition:width +25 andyValue: (simRun.trialNum * 175) +50];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.publicMaintenanceCost]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) +80];
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicInstallCost);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicDamages);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicMaintenanceCost);
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicInstallCost)]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicMaintenanceCost)]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.publicDamages)]];
            [scoreVisNames addObject: @"publicCostI"];
            [scoreVisNames addObject: @"publicCostM"];
            [scoreVisNames addObject: @"publicCostD"];
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"Installation Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateInstallCost]]] withConcernPosition:width +25 andyValue: (simRun.trialNum * 175 + 20)] ;
            [self drawTextBasedVar: [NSString stringWithFormat:@"Rain Damage: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateDamages]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum*175) +50];
            [self drawTextBasedVar: [NSString stringWithFormat:@"Maintenance Cost: $%@", [formatter stringFromNumber: [NSNumber numberWithInt:simRun.privateMaintenanceCost]]] withConcernPosition:width + 25 andyValue: (simRun.trialNum * 175) + 80];
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateInstallCost);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateDamages);
            scoreTotal += (currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateMaintenanceCost);
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateInstallCost)]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateMaintenanceCost)]];
            [scoreVisVals addObject:[NSNumber numberWithFloat:(currentVar.currentConcernRanking/3.0)/priorityTotal * (1 - simRunNormal.privateDamages)]];
            [scoreVisNames addObject: @"privateCostI"];
            [scoreVisNames addObject: @"privateCostM"];
            [scoreVisNames addObject: @"privateCostD"];
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.impactNeighbors] withConcernPosition:width +50 andyValue: (simRun.trialNum ) * 175 + 50];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (simRunNormal.impactNeighbors);
            [scoreVisVals addObject:[NSNumber numberWithFloat: currentVar.currentConcernRanking/priorityTotal * (simRunNormal.impactNeighbors)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.neighborsImpactMe] withConcernPosition:width + 50 andyValue: (simRun.trialNum)*175 + 50];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * ( simRunNormal.neighborsImpactMe)]];
            [scoreVisNames addObject: currentVar.name];
        } else if ([currentVar.name compare: @"groundwaterInfiltration"] == NSOrderedSame){
            [self drawTextBasedVar: [NSString stringWithFormat:@"%.2f%%", 100*simRun.infiltration] withConcernPosition:width + 50 andyValue: (simRun.trialNum)* 175 + 50 ];
            scoreTotal += currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.infiltration);
            [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal * (1 - simRunNormal.infiltration)]];
            [scoreVisNames addObject: currentVar.name];
        } else if([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            FebTestWaterDisplay * wd;
            //NSLog(@"%d, %d", waterDisplays.count, i);
            if(waterDisplays.count <= trial){
                //NSLog(@"Drawing water display for first time");
                wd = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 10, (simRun.trialNum)*175 + 5, 115, 125) andContent:simRun.standingWater];
                wd.view = _dataWindow;
                [waterDisplays addObject:wd];
            } else {
                //NSLog(@"Repositioning water display");
                wd = [waterDisplays objectAtIndex:trial];
                wd.frame = CGRectMake(width + 10, (simRun.trialNum)*175 + 5, 115, 125);
            }
            //display window for maxHeights
            FebTestWaterDisplay * mwd;
            if(maxWaterDisplays.count <= trial){
                mwd  = [[FebTestWaterDisplay alloc] initWithFrame:CGRectMake(width + 145, (simRun.trialNum)*175 + 5, 115, 125) andContent:simRun.maxWaterHeights];
                mwd.view = _dataWindow;
                [maxWaterDisplays addObject:mwd];
            } else {
                mwd = [maxWaterDisplays objectAtIndex:trial];
                mwd.frame = CGRectMake(width + 145, (simRun.trialNum)*175 + 5, 115, 125);
            }
            wd.thresholdValue = _thresholdValue.value;
            [wd updateView: _hoursAfterStorm.value];
            mwd.thresholdValue = _thresholdValue.value;
            [mwd updateView:48];
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            AprilTestEfficiencyView *ev;
            if( efficiency.count <= trial){
                //NSLog(@"Drawing efficiency display for first time");
            ev = [[AprilTestEfficiencyView alloc] initWithFrame:CGRectMake(width, (simRun.trialNum )*175 + 15, 130, 150) withContent: simRun.efficiency];
                ev.trialNum = i;
                ev.view = _dataWindow;
                [efficiency addObject:ev];
            } else {
                //NSLog(@"Repositioning efficiency display");
                ev = [efficiency objectAtIndex:trial];
                ev.frame = CGRectMake(width, (simRun.trialNum )*175 + 15, 130, 150);
            }
            scoreTotal += currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency;
                    [scoreVisVals addObject:[NSNumber numberWithFloat:currentVar.currentConcernRanking/priorityTotal *  simRunNormal.efficiency]];
            //NSLog(@"%@", NSStringFromCGRect(ev.frame));
            [scoreVisNames addObject: currentVar.name];
            
            [ev updateViewForHour: _hoursAfterStorm.value];
            
        }

        width+= currentVar.widthOfVisualization;
        if (currentVar.widthOfVisualization > 0) visibleIndex++;
    }
    UILabel *fullValue = [[UILabel alloc] initWithFrame:CGRectMake(150, (simRun.trialNum)*175 + 90,  110, 22)];
    fullValue.backgroundColor = [UIColor grayColor];
  
    [_mapWindow addSubview:fullValue];
    //NSLog(@" %@", scoreVisVals);
    float maxX = 150.5;
    float totalScore = 0;
    for(int i =  0; i < scoreVisVals.count; i++){
        float scoreWidth = [[scoreVisVals objectAtIndex: i] floatValue] * 100;
        if (scoreWidth < 0) scoreWidth = 0.5;
        totalScore += scoreWidth;
          UILabel * componentScore = [[UILabel alloc] initWithFrame:CGRectMake(maxX, (simRun.trialNum)*175 + 90, floor(scoreWidth), 21)];
        componentScore.backgroundColor = [scoreColors objectForKey:[scoreVisNames objectAtIndex:i]];
        componentScore.layer.borderWidth= .5;
        componentScore.layer.borderColor= [UIColor grayColor].CGColor;
        [_mapWindow addSubview:componentScore];
        maxX+=floor(scoreWidth) + 1;
    }

    
    [_dataWindow setContentSize:CGSizeMake(width+=100, (simRun.trialNum+1)*200)];
    for(UILabel * bgCol in bgCols){
        if(_dataWindow.contentSize.height > _dataWindow.frame.size.height){
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.contentSize.height + 100)];
        }else {
            [bgCol setFrame: CGRectMake(bgCol.frame.origin.x, bgCol.frame.origin.y, bgCol.frame.size.width, _dataWindow.frame.size.height + 100)];
        }
    }
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 50, 0, 0)];
    scoreLabel.text = [NSString stringWithFormat:  @"Score: %.0f / 100", totalScore];
    scoreLabel.font = [UIFont systemFontOfSize:14.0];
    [scoreLabel sizeToFit];
    scoreLabel.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel];
    UILabel *scoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 175*(trial) + 75, 0, 0)];
    scoreLabel2.text = [NSString stringWithFormat:  @"Broken down by source:"];
    scoreLabel2.font = [UIFont systemFontOfSize:10.0];
    [scoreLabel2 sizeToFit];
    scoreLabel2.textColor = [UIColor blackColor];
    [_mapWindow addSubview:scoreLabel2];
    
    
    [_dataWindow flashScrollIndicators];          
    
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    for (int i = 0; i < _scenarioNames.count; i++){
        UITextField *tx = [_scenarioNames objectAtIndex:i];
        if ( [tx isEditing]){
            if ((tx.frame.origin.y - _mapWindow.contentOffset.y) > (self.view.frame.size.height - 450)){
                lastMoved = 1;
                edittingTX = tx;
                [self setViewMovedUp:YES];
            }
        }
    }
    
}

-(void)keyboardWillHide {
    
       if(lastMoved == 1) [self setViewMovedUp:NO];
    lastMoved = 0;

}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGPoint rect = self.mapWindow.contentOffset;
    CGPoint rect2 = self.dataWindow.contentOffset;
    
    if (movedUp)
    {
        
        originalOffset = rect.y;
        rect.y += (edittingTX.frame.origin.y + _mapWindow.contentOffset.y) - 225;
        rect2.y = rect.y;
    }
    else
    {
        // revert back to the normal state.
        rect.y = originalOffset;
        rect2.y = originalOffset;

    }
    self.mapWindow.contentOffset = rect;
    self.dataWindow.contentOffset = rect2;
    
    [UIView commitAnimations];
}

-(void) drawTextBasedVar: (NSString *) outputValue withConcernPosition: (int) concernPos andyValue: (int) yValue{
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = outputValue;
    valueLabel.frame =CGRectMake(concernPos, yValue, 0, 0);
    [valueLabel sizeToFit ];
    valueLabel.font = [UIFont systemFontOfSize:14.0];
    valueLabel.textColor = [UIColor blackColor];
    [[self dataWindow] addSubview:valueLabel];
    
}

-(void) drawTitles{
    int width = 0;

    NSArray *sortedArray = [_currentConcernRanking sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSInteger first = [(AprilTestVariable*)a currentConcernRanking];
        NSInteger second = [(AprilTestVariable*)b currentConcernRanking];
        if(first > second) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    int visibleIndex = 0;
    for(int i = 0 ; i <_currentConcernRanking.count ; i++){

        AprilTestVariable * currentVar =[sortedArray objectAtIndex:i];
        UILabel * currentVarLabel = [[UILabel alloc] init];
        currentVarLabel.backgroundColor = [scoreColors objectForKey:currentVar.name];
        currentVarLabel.frame = CGRectMake(width, 2, currentVar.widthOfVisualization - 10, 40);
        currentVarLabel.font = [UIFont boldSystemFontOfSize:15.3];
        if([currentVar.name compare: @"publicCost"] == NSOrderedSame){
            currentVarLabel.text = @"  Public Cost";
        } else if ([currentVar.name compare: @"privateCost"] == NSOrderedSame){
            currentVarLabel.text =@"  Private Cost";
        } else if ([currentVar.name compare: @"impactingMyNeighbors"] == NSOrderedSame){
            currentVarLabel.text =@"  Rainwater to Neighbors";
        } else if ([currentVar.name compare: @"neighborImpactingMe"] == NSOrderedSame){
            currentVarLabel.text=@"  Rainwater from Neighbors";
        } else if ([currentVar.name compare: @"efficiencyOfIntervention"] == NSOrderedSame){
            currentVarLabel.text =@"  Intervention Efficiency";
        } else if ([currentVar.name compare:@"puddleTime"] == NSOrderedSame){
            currentVarLabel.text = @"  Puddle Depth Viewer";
        } else if( [currentVar.name compare:@"groundwaterInfiltration"] == NSOrderedSame){
            currentVarLabel.text = @"  % Rainwater Infiltrated";
        } else {
            currentVarLabel = NULL;
        }
        if(currentVar.widthOfVisualization != 0) visibleIndex++;
        
        if(currentVarLabel != NULL){
        [_titleWindow addSubview:currentVarLabel];
        }
        width+= currentVar.widthOfVisualization;
    }
    
    [_dataWindow setContentSize: CGSizeMake(width + 10, _dataWindow.contentSize.height)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([scrollView isEqual:_dataWindow]) {
        CGPoint offset = _mapWindow.contentOffset;
        offset.y = _dataWindow.contentOffset.y;
        CGPoint titleOffset = _titleWindow.contentOffset;
        titleOffset.x = _dataWindow.contentOffset.x;
        [_titleWindow setContentOffset:titleOffset];
        [_mapWindow setContentOffset:offset];
    } else {
        CGPoint offset = _dataWindow.contentOffset;
        offset.y = _mapWindow.contentOffset.y;
        [_dataWindow setContentOffset:offset];
    }
    //NSLog(@"content offset: %f",  _dataWindow.contentOffset.x);
    if(!passFirstThree && _dataWindow.contentOffset.x > 50){
        NSMutableString * content = [[NSMutableString alloc] initWithString:@"Scrolled past three most important variables"];
        
        [content appendString:@"\n\n"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        passFirstThree = TRUE;
    }
    if(passFirstThree &&  _dataWindow.contentOffset.x <= 50 ){
        NSMutableString * content = [[NSMutableString alloc] initWithString:@"Returned to three most important variables"];
        
        [content appendString:@"\n\n"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        passFirstThree = FALSE;
    }
}
- (IBAction)sliderChanged:(id)sender {
    NSMutableString * content = [NSMutableString alloc];
    [_loadingIndicator performSelectorInBackground:@selector(startAnimating) withObject:nil];
    float threshVal = _thresholdValue.value * 0.0393701;
    [_thresholdValue setEnabled:FALSE];
    [_hoursAfterStorm setEnabled:FALSE];
    [_mapWindow setScrollEnabled:FALSE];
    [_dataWindow setScrollEnabled:FALSE];
    [_titleWindow setScrollEnabled:FALSE];
    _thresholdValueLabel.text = [NSString stringWithFormat:@"%.1F\"", threshVal ];
    float translateThreshValue = _thresholdValue.value/_thresholdValue.maximumValue * _thresholdValue.frame.size.width;
    [redThreshold setFrame: CGRectMake(_thresholdValue.frame.origin.x + translateThreshValue + 2, _thresholdValue.frame.origin.y + _thresholdValue.frame.size.height/2, _thresholdValue.frame.size.width - 4 - translateThreshValue , _thresholdValue.frame.size.height/2)];
    [_thresholdValueLabel sizeToFit];
    for(int i = 0; i < waterDisplays.count; i++){
        FebTestWaterDisplay * temp = (FebTestWaterDisplay *) [waterDisplays objectAtIndex:i];
        temp.thresholdValue = _thresholdValue.value;
        FebTestWaterDisplay * tempHeights = (FebTestWaterDisplay *) [maxWaterDisplays objectAtIndex: i];
        tempHeights.thresholdValue = _thresholdValue.value;
    }
    
    int hoursAfterStorm = floorf(_hoursAfterStorm.value);
    if (hoursAfterStorm % 2 != 0) hoursAfterStorm--;
    _hoursAfterStorm.value = hoursAfterStorm;
    _hoursAfterStormLabel.text = [NSString stringWithFormat:@"%d hours", hoursAfterStorm];
    [_hoursAfterStormLabel sizeToFit];
    for(int i = 0; i < waterDisplays.count; i++){
        FebTestWaterDisplay * temp = (FebTestWaterDisplay *) [waterDisplays objectAtIndex:i];
        AprilTestEfficiencyView * temp2 = (AprilTestEfficiencyView *)[efficiency objectAtIndex:i];
        FebTestWaterDisplay * tempHeights = (FebTestWaterDisplay *) [maxWaterDisplays objectAtIndex: i];
        [temp2 updateViewForHour:hoursAfterStorm];
        [temp updateView:hoursAfterStorm];
        [tempHeights updateView:48];
    }
    [_thresholdValue setEnabled:TRUE];
    [_hoursAfterStorm setEnabled:TRUE];
    [_mapWindow setScrollEnabled:TRUE];
    [_dataWindow setScrollEnabled:TRUE];
    [_titleWindow setScrollEnabled:TRUE];
    [_loadingIndicator stopAnimating];
    if(sender == _thresholdValue){
        content = [content initWithFormat:@"Threshold value set to:%f", threshVal];
    } else {
        content = [content initWithFormat:@"Hours after storm set to: %d", hoursAfterStorm];
    }
    
        
        [content appendString:@"\n\n"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"logfile_simResults.txt"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];;
}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = [arrStatus count];
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.frame = CGRectMake(0, 0, 250, 30);
        tView.font = [UIFont boldSystemFontOfSize:15.0];

    }
    tView.text = [arrStatus objectAtIndex:row];
    // Fill the label text here

    return tView;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [arrStatus objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 250;
    
    return sectionWidth;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    int rowHeight = 20;
    return rowHeight;
}

@end
