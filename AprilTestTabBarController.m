//
//  AprilTestTabBarController.m
//  AprilTest
//
//  Created by Tia on 4/10/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestTabBarController.h"
#import "AprilTestVariable.h"

@interface AprilTestTabBarController ()


@end


@implementation AprilTestTabBarController
@synthesize currentConcernRanking = _currentConcernRanking;
@synthesize url = _url;
@synthesize studyNum = _studyNum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //manually derived list of variables that are going to be implemented in this test. Eventually, should be replaced with a access to database, such that width, etc, are all documented as such.

    _currentConcernRanking = [[NSMutableArray alloc] initWithObjects: [[AprilTestVariable alloc] initWith: @"publicCost" withDisplayName:@"Public Cost" withNumVar: 3 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith: @"privateCost" withDisplayName:@"Private Cost" withNumVar: 3 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith: @"publicStandingWater" withDisplayName:@"Standing Water" withNumVar: 1 withWidth: 0 withRank:1], [[AprilTestVariable alloc]initWith:@"waterReuse" withDisplayName:@"Reusing Water" withNumVar: 1 withWidth:0 withRank:1], [[AprilTestVariable alloc] initWith:@"visualAppearence" withDisplayName:@"Visual Appearence" withNumVar: 1 withWidth:0 withRank:1], [[AprilTestVariable alloc] initWith:@"puddleTime" withDisplayName:@"Length of Time of Flooding" withNumVar: 1 withWidth:320 withRank:1], [[AprilTestVariable alloc] initWith:@"impactingMyNeighbors" withDisplayName:@"Impact on my Neighbors" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"neighborImpactingMe" withDisplayName:@"Amount Neighbors Impact Me" withNumVar: 1 withWidth: 220 withRank:1], [[AprilTestVariable alloc] initWith:@"streetClosureInconvenience" withDisplayName:@"Inconvenience Due to Street Closures" withNumVar: 2 withWidth:0 withRank:1], [[AprilTestVariable alloc] initWith:@"groundwaterInfiltration" withDisplayName:@"Amount of Water Returned to Groundwater Supply" withNumVar: 1 withWidth:220 withRank:1], [[AprilTestVariable alloc] initWith:@"efficiencyOfIntervention" withDisplayName:@"Efficiency of Intervention" withNumVar: 1 withWidth:220 withRank:1], nil];
     
     _url= @"";
    _studyNum=1;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
