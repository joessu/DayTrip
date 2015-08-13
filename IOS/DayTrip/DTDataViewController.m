//
//  DTDataViewController.m
//  DayTrip
//
//  Created by Joe Andresen on 3/2/14.
//  Copyright (c) 2014 Joseph Andresen. All rights reserved.
//

#import "DTDataViewController.h"

@interface DTDataViewController ()

@end

@implementation DTDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

@end
