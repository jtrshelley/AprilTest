//
//  AprilTestNormalizedVariable.m
//  AprilTest
//
//  Created by Tia on 4/20/14.
//  Copyright (c) 2014 Tia. All rights reserved.
//

#import "AprilTestNormalizedVariable.h"

@implementation AprilTestNormalizedVariable
@synthesize publicInstallCost = _publicInstallCost;
@synthesize publicDamages = _publicDamages;
@synthesize publicMaintenanceCost = _publicMaintenanceCost;
@synthesize privateInstallCost = _privateInstallCost;
@synthesize privateDamages = _privateDamages;
@synthesize privateMaintenanceCost = _privateMaintenanceCost;
@synthesize standingWater = _standingWater;
@synthesize impactNeighbors = _impactNeighbors;
@synthesize neighborsImpactMe = _neighborsImpactMe;
@synthesize infiltration = _infiltration;
@synthesize efficiency = _efficiency;
@synthesize trialNum = _trialNum;

-(id) init: (NSString *) pageResults withTrialNum:(int)trialNum {
    NSArray * components = [pageResults componentsSeparatedByString:@"\n\n"];
    
    _publicInstallCost = [[components objectAtIndex :0] floatValue];
    _privateInstallCost = [[components objectAtIndex:1] floatValue];
    _publicDamages = [[components objectAtIndex:2] floatValue];
    _privateDamages = [[components objectAtIndex:3] intValue];
    _publicMaintenanceCost = [[components objectAtIndex:4] intValue];
    _privateMaintenanceCost = [[components objectAtIndex:5]intValue];
    _standingWater = [[components objectAtIndex:6]floatValue];
    _impactNeighbors = [[components objectAtIndex:7] floatValue];
    _neighborsImpactMe = [[components objectAtIndex:8] floatValue];
    _infiltration = [[components objectAtIndex:9] floatValue];
    _efficiency = [[components objectAtIndex:10] floatValue];
    _trialNum = trialNum;
    
    NSLog(@"%@", components);
    
    return self;
}
@end
