//
//  ASSlipControl.m
//  ASSlipControl
//
//  Created by jinkelei on 13-4-12.
//  Copyright (c) 2013年  JinKelei. All rights reserved.
//

#define KDefaultSlipMinDistence 100.0f //判断是否滑动成功的最小距离
#define KDefaultAnimationDuration 0.3f   //动画时间
#define KdefaultMinDerectionDistence 10.0f   //判断是否是滑动行为的最小距离

#import "ASSlipControl.h"

@interface ASSlipControl (Private)
- (void)panMove:(CGPoint)point;
- (void)panEnded:(CGPoint)point;
- (void)actionEnded;
@end

@implementation ASSlipControl
@synthesize centerViewController = _centerViewController;
@synthesize rightViewController = _rightViewController;
@synthesize leftViewController = _leftViewController;
@synthesize animationDuration = _animationDuration;
@synthesize delegate = _delegate;
@synthesize isFullScreen = _isFullScreen;

#pragma mark - init
- (id)init
{
    if (self = [super init]) {
        _centerViewController = nil;
        _rightViewController = nil;
        _leftViewController = nil;
        _slipViewMode = KSlipViewModeCenter;
        _slipDerection = KSlipViewDerectionNone;
        _animationDuration = KDefaultAnimationDuration;
        _touchDownPoint = CGPointZero;
        _animationLocked = NO;
        _isFullScreen = NO;
        _isFirstMove = YES;
        _centerOriY = _leftOriY = _rightOriY = 0;
        _slipCurViewController = nil;
    }
    return self;
}

- (id)initWithCenterViewController:(UIViewController *)centerViewController
               rightViewController:(UIViewController *)rightViewController
                leftViewController:(UIViewController *)leftViewController
{
    if (self = [super init]) {
        _centerViewController = [centerViewController retain];
        if (rightViewController != nil) {
            _rightViewController = [rightViewController retain];
        }else{
            _rightViewController = nil;
        }
        if (leftViewController != nil) {
            _leftViewController = [leftViewController retain];
        }else{
            _leftViewController = nil;
        }
        _slipViewMode = KSlipViewModeCenter;
        _slipDerection = KSlipViewDerectionNone;
        _animationDuration = KDefaultAnimationDuration;
        _touchDownPoint = CGPointZero;
        _animationLocked = NO;
        _isFullScreen = NO;
        _isFirstMove = YES;
        _centerOriY = _leftOriY = _rightOriY = 0;
        _slipCurViewController = _centerViewController;
    }
    return self;
}

#pragma mark - Oritation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (_slipPresentModeViewController) {
        return _slipPresentModeViewController.supportedInterfaceOrientations;
    }else if(_slipCurViewController){
        return _slipCurViewController.supportedInterfaceOrientations;
    }else{
        return _centerViewController.supportedInterfaceOrientations;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_slipPresentModeViewController) {
        return [_slipPresentModeViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }else if(_slipCurViewController){
        return [_slipCurViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }else{
        return [_centerViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}



#pragma mark - dealloc
- (void)dealloc
{
    [_centerViewController release];_centerViewController = nil;
    [_rightViewController release];_rightViewController = nil;
    [_leftViewController release];_leftViewController = nil;
    [_pan release];_pan = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipPresentDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipPresentControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipControlMoveRight object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipControlMoveLeft object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipControlDisableMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ASSlipControlEnableMoveNotification object:nil];
    [super dealloc];
}

#pragma mark - view life
- (void)loadView
{
    [super loadView];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, _isFullScreen?0:20, self.view.bounds.size.width, self.view.bounds.size.height)];
    view.backgroundColor = [UIColor blackColor];
//    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view = view;
    [view release];view = nil;
    
    [self slipEnablePan];
    
    if (_centerViewController) {
        CGRect centerFrame = _centerViewController.view.frame;
        _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        _centerOriY = centerFrame.origin.y;
        _centerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_centerViewController.view];
    }
    if (_rightViewController) {
        CGRect rightFrame = _rightViewController.view.frame;
        CGRect frame = CGRectMake(_centerViewController.view.frame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
        _rightViewController.view.frame = frame;
        _rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _rightOriY = rightFrame.origin.y;
        [self.view addSubview:_rightViewController.view];
    }
    if (_leftViewController) {
        CGRect leftFrame = _leftViewController.view.frame;
        _leftViewController.view.frame = CGRectMake(-leftFrame.size.width, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
        _leftOriY = leftFrame.origin.y;
        _leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_leftViewController.view];
    }
    
    
    if (_isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    }
    self.wantsFullScreenLayout = YES;
    
    //注册present dismiss通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissed) name:ASSlipDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentModalViewControllerDismissed) name:ASSlipPresentDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentModalViewController:) name:ASSlipPresentControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slipMoveLeft) name:ASSlipControlMoveLeft object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slipMoveRight) name:ASSlipControlMoveRight object:nil];
    
    //注册拖拽功能通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slipEnablePan) name:ASSlipControlEnableMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slipDisablePan) name:ASSlipControlDisableMoveNotification object:nil];
}

- (void)reLayoutViews
{
    if (_centerViewController) {
        CGRect centerFrame = _centerViewController.view.frame;
        _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        _centerOriY = centerFrame.origin.y;
    }
    if (_rightViewController) {
        CGRect rightFrame = _rightViewController.view.frame;
        CGRect frame = CGRectMake(_centerViewController.view.frame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
        _rightViewController.view.frame = frame;
        _rightOriY = rightFrame.origin.y;
    }
    if (_leftViewController) {
        CGRect leftFrame = _leftViewController.view.frame;
        _leftViewController.view.frame = CGRectMake(-leftFrame.size.width, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
        _leftOriY = leftFrame.origin.y;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark private function
- (void)panMove:(CGPoint)point
{
    if (_animationLocked) {
        return;
    }
    CGFloat distence = point.x - _touchDownPoint.x;
    
    //判断滑动方向
    if (_slipDerection == KSlipViewDerectionNone) {
        if (distence > KdefaultMinDerectionDistence) {
            _slipDerection = KSlipViewDerectionRight;
        }else if(distence < -KdefaultMinDerectionDistence){
            _slipDerection = KSlipViewDerectionLeft;
        }
    }
    
    //排除禁止的滑动行为
    if (_slipViewMode == KSlipViewModeRight && _slipDerection == KSlipViewDerectionLeft) {
        [self actionEnded];
        return;
    }
    if (_slipViewMode == KSlipViewModeLeft && _slipDerection == KSlipViewModeRight) {
        [self actionEnded];
        return;
    }
    if (_slipViewMode == KSlipViewModeCenter) {
        if (_slipDerection == KSlipViewDerectionLeft && _rightViewController == nil) {
            [self actionEnded];
            return;
        }
        if (_slipDerection == KSlipViewDerectionRight && _leftViewController == nil) {
            [self actionEnded];
            return;
        }
    }
    
    //排除滑动超过范围的行为
    if ((distence > 0 && _slipDerection == KSlipViewDerectionLeft)||
        (distence < 0 && _slipDerection == KSlipViewDerectionRight)) {
        return;
    }
    
    //无方向则退出
    if (_slipDerection == KSlipViewDerectionNone) {
        [self actionEnded];
        return;
    }
    
    //处理具体滑动情况
    if (_slipViewMode == KSlipViewModeCenter) {
        if (_slipDerection == KSlipViewDerectionLeft) {
            //向左滑动，显示右视图 center->right
            if (distence >= 0 && _rightViewController) {
                return;
            }
            if (_isFirstMove) {
                if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipRightViewController:
                                                                         fromCenterViewController:)]) {
                    [_delegate slipViewWillSlipRightViewController:_rightViewController
                                          fromCenterViewController:_centerViewController];
                }
                _isFirstMove = NO;
            }
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(distence, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            
            CGRect rightFrame = _rightViewController.view.frame;
            _rightViewController.view.frame = CGRectMake(centerFrame.size.width+distence, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
            
        }else{
            //向右滑动，显示左视图  center -> left
            if (distence <= 0 && _leftViewController) {
                return;
            }
            if (_isFirstMove) {
                if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipLeftViewController:
                                                                         fromCenterViewController:)]) {
                    [_delegate slipViewWillSlipLeftViewController:_leftViewController
                                         fromCenterViewController:_centerViewController];
                }
                _isFirstMove = NO;
            }
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(distence, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            
            CGRect leftFrame = _leftViewController.view.frame;
            _leftViewController.view.frame = CGRectMake(-leftFrame.size.width + distence, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
        }
    }else if(_slipViewMode == KSlipViewModeRight){
        //当前右视图，向右滑动 right->center
        if (_slipDerection == KSlipViewDerectionRight) {
            if (_isFirstMove) {
                if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipCenterViewController: fromRightViewController:)]) {
                    [_delegate slipViewWillSlipCenterViewController:_centerViewController fromRightViewController:_rightViewController];
                }
                _isFirstMove = NO;
            }
            CGRect rightFrame = _rightViewController.view.frame;
            _rightViewController.view.frame = CGRectMake(self.view.bounds.size.width-rightFrame.size.width+distence, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
            
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(-rightFrame.size.width+distence, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
        }else{
            return;
        }
    }else{
        //当前左视图，向左滑动 left -> center
        if (_slipDerection == KSlipViewDerectionLeft) {
            if (_isFirstMove) {
                if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipCenterViewController: fromLeftViewController:)]) {
                    [_delegate slipViewWillSlipCenterViewController:_centerViewController fromLeftViewController:_leftViewController];
                }
                _isFirstMove = NO;
            }
            
            CGRect leftFrame = _leftViewController.view.frame;
            _leftViewController.view.frame = CGRectMake(distence, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
            
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(leftFrame.size.width+distence, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
        }else{
            return;
        }
    }
}

- (void)panEnded:(CGPoint)point
{
    if (_animationLocked) {
        return;
    }
    if (_slipDerection == KSlipViewDerectionNone) {
        [self actionEnded];
        return;  
    }
    _animationLocked = YES;
    
    CGFloat distence = point.x - _touchDownPoint.x;
    
    //判断滑动是否超出范围
    if ((distence > 0 && _slipDerection == KSlipViewDerectionLeft)||
        (distence < 0 && _slipDerection == KSlipViewDerectionRight)) {
        distence = 0;
    }
    
    if (abs(distence) <= KDefaultSlipMinDistence) {
        //滑动不成功，回滚动画
        if (_slipViewMode == KSlipViewModeCenter) {
            if (_slipDerection == KSlipViewDerectionLeft) {
                //左滑失败 center -/-> right
                [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                    CGRect centerFrame = _centerViewController.view.frame;
                    _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                    
                    CGRect rightFrame = _rightViewController.view.frame;
                    _rightViewController.view.frame = CGRectMake(centerFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
                }completion:^(BOOL finished){
                    _slipViewMode = KSlipViewModeCenter;
                    [self actionEnded];
                    if (_delegate && [_delegate respondsToSelector:@selector
                                      (slipViewDidSlipRightViewController:
                                       fromCenterViewController:
                                       isSuccessd:)]) {
                        [_delegate slipViewDidSlipRightViewController:_rightViewController
                                             fromCenterViewController:_centerViewController
                                                           isSuccessd:FALSE];
                    }
                }];
            }else{
                //右滑失败 center -/-> left
                [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                    CGRect centerFrame = _centerViewController.view.frame;
                    _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                    
                    CGRect leftFrame = _leftViewController.view.frame;
                    _leftViewController.view.frame = CGRectMake(-leftFrame.size.width, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
                }completion:^(BOOL finished){
                    _slipViewMode = KSlipViewModeCenter;
                    [self actionEnded];
                    if (_delegate && [_delegate respondsToSelector:@selector
                                      (slipViewDidSlipLeftViewController:
                                       fromCenterViewController:
                                       isSucceed:)]) {
                        [_delegate slipViewDidSlipLeftViewController:_leftViewController fromCenterViewController:_centerViewController isSucceed:FALSE];
                    }
                }];
            }
        }else if(_slipViewMode == KSlipViewModeRight){
            //当前为右视图，滑动不成功 right -/-> center
            [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                CGRect rightFrame = _rightViewController.view.frame;
                _rightViewController.view.frame = CGRectMake(self.view.bounds.size.width-rightFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
                
                CGRect centerFrame = _centerViewController.view.frame;
                _centerViewController.view.frame = CGRectMake(-rightFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            }completion:^(BOOL finished){
                _slipViewMode = KSlipViewModeRight;
                [self actionEnded];
                if (_delegate && [_delegate respondsToSelector:@selector
                                  (slipViewDidSlipCenterViewController:
                                   fromRightViewController:
                                   isSuccessd:)]) {
                    [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                           fromRightViewController:_rightViewController
                                                        isSuccessd:FALSE];
                }
            }];
        }else{
            //当前为左视图，滑动不成功 left -/-> center
            [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                CGRect leftFrame = _leftViewController.view.frame;
                _leftViewController.view.frame = CGRectMake(0, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
                
                CGRect centerFrame = _centerViewController.view.frame;
                _centerViewController.view.frame = CGRectMake(leftFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            }completion:^(BOOL finished){
                _slipViewMode = KSlipViewModeLeft;
                [self actionEnded];
                if (_delegate && [_delegate respondsToSelector:@selector
                                  (slipViewDidSlipCenterViewController:
                                   fromLeftViewController:
                                   isSuccessd:)]) {
                    [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                            fromLeftViewController:_leftViewController
                                                        isSuccessd:FALSE];
                }
            }];
        }
    }else{
        //滑动成功，完成动画
        if (_slipViewMode == KSlipViewModeCenter) {
            if (_slipDerection == KSlipViewDerectionLeft) {
                //center -> right
                [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                    CGRect rightFrame = _rightViewController.view.frame;
                    _rightViewController.view.frame = CGRectMake(self.view.bounds.size.width-rightFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
                    
                    CGRect centerFrame = _centerViewController.view.frame;
                    _centerViewController.view.frame = CGRectMake(-rightFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                }completion:^(BOOL finished){
                    _slipViewMode = KSlipViewModeRight;
                   [self actionEnded];
                    _slipCurViewController = _rightViewController;
                    if (_delegate && [_delegate respondsToSelector:
                                      @selector(slipViewDidSlipRightViewController:
                                                fromCenterViewController:
                                                isSuccessd:)]) {
                        [_delegate slipViewDidSlipRightViewController:_rightViewController
                                             fromCenterViewController:_centerViewController
                                                           isSuccessd:TRUE];
                    }
                }];
            }else{
                //center -> left
                [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                    CGRect leftFrame = _leftViewController.view.frame;
                    _leftViewController.view.frame = CGRectMake(0, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
                    
                    CGRect centerFrame = _centerViewController.view.frame;
                    _centerViewController.view.frame = CGRectMake(leftFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                }completion:^(BOOL finished){
                    _slipViewMode = KSlipViewModeLeft;
                    [self actionEnded];
                    _slipCurViewController = _leftViewController;
                    if (_delegate && [_delegate respondsToSelector:@selector
                                      (slipViewDidSlipLeftViewController:
                                       fromCenterViewController:
                                       isSucceed:)]) {
                        [_delegate slipViewDidSlipLeftViewController:_leftViewController
                                            fromCenterViewController:_centerViewController
                                                           isSucceed:TRUE];
                    }
                }];
            }
        }else if (_slipViewMode == KSlipViewModeRight){
            //right -> center
            [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                CGRect centerFrame = _centerViewController.view.frame;
                _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                
                CGRect rightFrame = _rightViewController.view.frame;
                _rightViewController.view.frame = CGRectMake(centerFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
            }completion:^(BOOL finished){
                _slipViewMode = KSlipViewModeCenter;
                [self actionEnded];
                _slipCurViewController = _centerViewController;
                if (_delegate && [_delegate respondsToSelector:@selector
                                  (slipViewDidSlipCenterViewController:
                                   fromRightViewController:
                                   isSuccessd:)]) {
                    [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                           fromRightViewController:_rightViewController
                                                        isSuccessd:TRUE];
                }
            }];
        }else{
            //left -> center
            [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
                CGRect centerFrame = _centerViewController.view.frame;
                _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
                
                CGRect leftFrame = _leftViewController.view.frame;
                _leftViewController.view.frame = CGRectMake(-leftFrame.size.width, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
            }completion:^(BOOL finished){
                _slipViewMode = KSlipViewModeCenter;
                [self actionEnded];
                _slipCurViewController = _centerViewController;
                if (_delegate && [_delegate respondsToSelector:@selector
                                  (slipViewDidSlipCenterViewController:
                                   fromLeftViewController:
                                   isSuccessd:)]) {
                    [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                            fromLeftViewController:_leftViewController
                                                        isSuccessd:TRUE];
                }
            }];
        }
    }
}

- (void)actionEnded
{
    _isFirstMove = YES;
    _animationLocked = NO;
    _slipDerection = KSlipViewDerectionNone;
}

#pragma mark - pan
- (void)panAction:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_animationLocked) {
            return;
        }
        _touchDownPoint = [gesture locationInView:self.view];
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture locationInView:self.view];
        [self panMove:point];
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gesture locationInView:self.view];
        [self panEnded:point];
    }else{
        //UIGestureRecognizerStateCancelled
    }
}

#pragma mark present View Controller
- (void)slipPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    _slipPresentModeViewController = [modalViewController retain];
    [self presentViewController:modalViewController animated:YES completion:nil];
}


#pragma mark - dismiss notification
- (void)dismissed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark present notification
- (void)presentModalViewController:(NSNotification *)notification
{
    UIViewController *controller = [notification.userInfo objectForKey:ASSlipPresentKey];
    [self slipPresentModalViewController:controller animated:YES];
}

- (void)presentModalViewControllerDismissed
{
    [_slipPresentModeViewController release];
    _slipPresentModeViewController = nil;
}

#pragma mark - move function
//代码控制滑动，非手势
- (BOOL)slipMoveRight
{
    if (_slipViewMode == KSlipViewModeRight){
        return FALSE;
    }
    if (_slipViewMode == KSlipViewModeCenter) {
        //center -> right
        [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
            CGRect rightFrame = _rightViewController.view.frame;
            _rightViewController.view.frame = CGRectMake(self.view.bounds.size.width-rightFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
            
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(-rightFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            if (_delegate && [_delegate respondsToSelector:@selector
                              (slipViewWillSlipRightViewController:
                               fromCenterViewController:)]) {
                [_delegate slipViewWillSlipRightViewController:_rightViewController
                                      fromCenterViewController:_centerViewController];
            }
        }completion:^(BOOL finished){
            _slipViewMode = KSlipViewModeRight;
            _slipCurViewController = _rightViewController;
            if (_delegate && [_delegate respondsToSelector:@selector
                              (slipViewDidSlipRightViewController:
                               fromCenterViewController:
                               isSuccessd:)]) {
                [_delegate slipViewDidSlipRightViewController:_rightViewController
                                     fromCenterViewController:_centerViewController
                                                   isSuccessd:TRUE];
            }
        }];
    }else if (_slipViewMode == KSlipViewModeLeft){
        //left -> center
        [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            
            CGRect leftFrame = _leftViewController.view.frame;
            _leftViewController.view.frame = CGRectMake(-leftFrame.size.width, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
            if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipCenterViewController:
                                                                     fromLeftViewController:)]) {
                [_delegate slipViewWillSlipCenterViewController:_centerViewController
                                         fromLeftViewController:_leftViewController];
            }
        }completion:^(BOOL finished){
            _slipViewMode = KSlipViewModeCenter;
            _slipCurViewController = _centerViewController;
            if (_delegate && [_delegate respondsToSelector:@selector
                              (slipViewDidSlipCenterViewController:
                               fromLeftViewController:
                               isSuccessd:)]) {
                [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                        fromLeftViewController:_leftViewController
                                                    isSuccessd:TRUE];
            }
        }];
    }
    return TRUE;
}

- (BOOL)slipMoveLeft
{
    if (_slipViewMode == KSlipViewModeLeft) {
        return FALSE;
    }
    if (_slipViewMode == KSlipViewModeCenter) {
        //center -> left
        [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
            CGRect leftFrame = _leftViewController.view.frame;
            _leftViewController.view.frame = CGRectMake(0, leftFrame.origin.y, leftFrame.size.width, leftFrame.size.height);
            
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(leftFrame.size.width, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            if (_delegate && [_delegate respondsToSelector:@selector
                              (slipViewWillSlipLeftViewController:
                               fromCenterViewController:)]) {
                [_delegate slipViewWillSlipLeftViewController:_leftViewController
                                     fromCenterViewController:_centerViewController];
            }
        }completion:^(BOOL finished){
            _slipViewMode = KSlipViewModeLeft;
            _slipCurViewController = _leftViewController;
            if (_delegate && [_delegate respondsToSelector:@selector
                              (slipViewDidSlipLeftViewController:
                               fromCenterViewController:
                               isSucceed:)]) {
                [_delegate slipViewDidSlipLeftViewController:_leftViewController
                                    fromCenterViewController:_centerViewController
                                                   isSucceed:TRUE];
            }
        }];
    }else if (_slipViewMode == KSlipViewModeRight){
        //right -> center
        [UIView animateWithDuration:KDefaultAnimationDuration animations:^{
            CGRect centerFrame = _centerViewController.view.frame;
            _centerViewController.view.frame = CGRectMake(0, centerFrame.origin.y, centerFrame.size.width, centerFrame.size.height);
            
            CGRect rightFrame = _rightViewController.view.frame;
            _rightViewController.view.frame = CGRectMake(centerFrame.size.width, rightFrame.origin.y, rightFrame.size.width, rightFrame.size.height);
            if (_delegate && [_delegate respondsToSelector:@selector(slipViewWillSlipCenterViewController:
                                                                     fromRightViewController:)]) {
                [_delegate slipViewWillSlipCenterViewController:_centerViewController
                                        fromRightViewController:_rightViewController];
            }
        }completion:^(BOOL finished){
            _slipViewMode = KSlipViewModeCenter;
            _slipCurViewController = _centerViewController;
            if (_delegate && [_delegate respondsToSelector:@selector(slipViewDidSlipCenterViewController:
                                                                     fromRightViewController:
                                                                     isSuccessd:)]) {
                [_delegate slipViewDidSlipCenterViewController:_centerViewController
                                       fromRightViewController:_rightViewController
                                                    isSuccessd:TRUE];
            }
        }];
    }
    return TRUE;
}

#pragma mark - pan notification
- (void)slipEnablePan
{
    if (_pan == nil) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        [self.view addGestureRecognizer:_pan];
    }
}

- (void)slipDisablePan
{
    [self.view removeGestureRecognizer:_pan];
    [_pan release];_pan = nil;
}

@end
