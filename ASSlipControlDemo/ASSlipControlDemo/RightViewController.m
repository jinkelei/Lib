//
//  RightViewController.m
//  ASSlipControlDemo
//
//  Created by jinkelei on 13-5-21.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//

#import "RightViewController.h"
#import "ASSlipControl.h"
#import "PresentViewController.h"

#define KButtonWidth 100.0f
#define KButtonHeight 44.0f

@interface RightViewController ()

@end

@implementation RightViewController

- (void)loadView
{
    [super loadView];
    UIView *view = [[UIView alloc]initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor redColor];
    self.view = view;
    [view release];view = nil;
    
    UIButton *presentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    presentButton.frame = CGRectMake(0, 0, KButtonWidth, KButtonHeight);
    presentButton.center = self.view.center;
    [presentButton setTitle:@"present controller" forState:UIControlStateNormal];
    [presentButton  setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [presentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    presentButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [presentButton addTarget:self action:@selector(presentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:presentButton];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action
- (void)presentAction
{
    PresentViewController *controller = [[PresentViewController alloc]init];
    [[NSNotificationCenter defaultCenter]postNotificationName:ASSlipPresentControllerNotification object:nil userInfo:[NSDictionary dictionaryWithObject:controller forKey:ASSlipPresentKey]];
    [controller release];controller = nil;
}

#pragma mark - Oritation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

@end
