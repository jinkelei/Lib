//
//  RootViewController.m
//  ASSlipControlDemo
//
//  Created by jinkelei on 13-5-21.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//

#import "RootViewController.h"
#import "RightViewController.h"
#import "LeftViewController.h"
#import "CenterViewController.h"

#define KButtonWidth 100.0f
#define KButtonHeight 44.0f

@interface RootViewController ()

@end

@implementation RootViewController

- (void)loadView
{
    [super loadView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    [view release];view = nil;
    
    UIButton *slipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    slipButton.frame = CGRectMake(0, 0, KButtonWidth, KButtonHeight);
    slipButton.center = self.view.center;
    [slipButton setTitle:@"show slip" forState:UIControlStateNormal];
    [slipButton  setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [slipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    slipButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [slipButton addTarget:self action:@selector(slipAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:slipButton];
    
    _slipControl = nil;
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

- (void)dealloc
{
    if (_slipControl) {
        [_slipControl release];_slipControl = nil;
    }
    [super dealloc];
}

- (void)slipAction
{
    RightViewController *rightViewController = [[RightViewController alloc]init];
    CenterViewController *centerViewController = [[CenterViewController alloc]init];
    LeftViewController *leftViewController = [[LeftViewController alloc]init];
    if (!_slipControl) {
        _slipControl = [[ASSlipControl alloc]initWithCenterViewController:centerViewController
                                                      rightViewController:rightViewController
                                                       leftViewController:leftViewController];
        _slipControl.delegate = self;
    }
    [self presentViewController:_slipControl animated:YES completion:nil];
    [rightViewController release];rightViewController = nil;
    [centerViewController release];centerViewController = nil;
    [leftViewController release];leftViewController = nil;
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
//    return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationPortrait);
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

#pragma mark - ASSlipControl Delegate
//center -> left
- (void)slipViewWillSlipLeftViewController:(UIViewController *)leftViewController
                  fromCenterViewController:(UIViewController *)centerViewController
{
    
}

- (void)slipViewDidSlipLeftViewController:(UIViewController *)leftViewController
                 fromCenterViewController:(UIViewController *)centerViewController
                                isSucceed:(BOOL)succeed
{
    
}

//center -> right
- (void)slipViewWillSlipRightViewController:(UIViewController *)rightViewController
                   fromCenterViewController:(UIViewController *)centerViewController
{
    
}

- (void)slipViewDidSlipRightViewController:(UIViewController *)rightViewController
                  fromCenterViewController:(UIViewController *)centerViewController
                                isSuccessd:(BOOL)succeed
{
    
}

//right -> center
- (void)slipViewWillSlipCenterViewController:(UIViewController *)centerViewController
                     fromRightViewController:(UIViewController *)rightViewController
{
    
}

- (void)slipViewDidSlipCenterViewController:(UIViewController *)centerViewController
                    fromRightViewController:(UIViewController *)rightViewController
                                 isSuccessd:(BOOL)succeed
{
    
}

//left -> center
- (void)slipViewWillSlipCenterViewController:(UIViewController *)centerViewController
                      fromLeftViewController:(UIViewController *)leftViewController
{
    
}

- (void)slipViewDidSlipCenterViewController:(UIViewController *)centerViewController
                     fromLeftViewController:(UIViewController *)leftViewController
                                 isSuccessd:(BOOL)succeed
{
    
}

@end
