//
//  PresentViewController.m
//  ASSlipControlDemo
//
//  Created by jinkelei on 13-5-21.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//

#import "PresentViewController.h"
#import "ASSlipControl.h"

#define KButtonWidth 100.0f
#define KButtonHeight 44.0f

@interface PresentViewController ()

@end

@implementation PresentViewController

- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.backgroundColor = [UIColor greenColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = view;
    [view release];view = nil;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(0, 0, KButtonWidth, KButtonHeight);
    backButton.center = self.view.center;
    [backButton setTitle:@"exit present" forState:UIControlStateNormal];
    [backButton  setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    backButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
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
- (void)backAction
{
    [[NSNotificationCenter defaultCenter]postNotificationName:ASSlipPresentDismissNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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
