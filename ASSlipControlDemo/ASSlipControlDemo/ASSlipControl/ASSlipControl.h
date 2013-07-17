//
//  ASSlipControl.h
//  ASSlipControl
//
//  Created by jinkelei on 13-4-12.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//
// 目前只支持IPAD 横屏
// 支持拖拽动画，左右两个viewController与centerViewController同时动画
// 支持从ASSlipControl present ViewController

#import <UIKit/UIKit.h>

#define IPAD_DEVICE (([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 1 : 0)

#define ASSlipDismissNotification @"dismissed"

#define ASSlipPresentDismissNotification @"presentControllerDismissed"
#define ASSlipPresentControllerNotification @"presentController"
//通过通知控制ASSlipControl进行左移和右移
#define ASSlipControlMoveLeft @"asSlipControlMoveLeft"
#define ASSlipControlMoveRight @"asSlipControlMoveRight"

//通过通知关闭或者启动AS的拖拽功能
#define ASSlipControlDisableMoveNotification @"asSlipControlDisableMove"
#define ASSlipControlEnableMoveNotification @"asSlipControlEnableMove"

//key
#define ASSlipPresentKey @"asSlipPresentController"

typedef enum{
    KSlipViewModeCenter = 1,
    KSlipViewModeRight,
    KSlipViewModeLeft
}KSlipViewMode;  //当前主屏显示的viewController

typedef enum{
    KSlipViewDerectionLeft = 1,
    KSlipViewDerectionRight,
    KSlipViewDerectionNone
}KSlipViewDerection;

@class ASSlipControl;
@protocol ASSlipControlDelegate <NSObject>
@optional
//center -> left
- (void)slipViewWillSlipLeftViewController:(UIViewController *)leftViewController
                  fromCenterViewController:(UIViewController *)centerViewController;

- (void)slipViewDidSlipLeftViewController:(UIViewController *)leftViewController
                 fromCenterViewController:(UIViewController *)centerViewController
                                 isSucceed:(BOOL)succeed;

//center -> right
- (void)slipViewWillSlipRightViewController:(UIViewController *)rightViewController
                   fromCenterViewController:(UIViewController *)centerViewController;

- (void)slipViewDidSlipRightViewController:(UIViewController *)rightViewController
                  fromCenterViewController:(UIViewController *)centerViewController
                                isSuccessd:(BOOL)succeed;

//right -> center
- (void)slipViewWillSlipCenterViewController:(UIViewController *)centerViewController
                     fromRightViewController:(UIViewController *)rightViewController;

- (void)slipViewDidSlipCenterViewController:(UIViewController *)centerViewController
                    fromRightViewController:(UIViewController *)rightViewController
                                 isSuccessd:(BOOL)succeed;

//left -> center
- (void)slipViewWillSlipCenterViewController:(UIViewController *)centerViewController
                      fromLeftViewController:(UIViewController *)leftViewController;

- (void)slipViewDidSlipCenterViewController:(UIViewController *)centerViewController
                     fromLeftViewController:(UIViewController *)leftViewController
                                 isSuccessd:(BOOL)succeed;
@end

@interface ASSlipControl : UIViewController<UIGestureRecognizerDelegate>
{
    UIViewController *_centerViewController;
    UIViewController *_rightViewController;
    UIViewController *_leftViewController;
    
    KSlipViewMode _slipViewMode;
    KSlipViewDerection _slipDerection;
    CGFloat _animationDuration;
    BOOL _animationLocked;
    BOOL _isFullScreen;
    BOOL _isFirstMove;
    
    CGPoint _touchDownPoint;
    
    UIPanGestureRecognizer *_pan;
    
    id<ASSlipControlDelegate> _delegate;
    
    @private
    CGFloat _centerOriY;
    CGFloat _leftOriY;
    CGFloat _rightOriY;
    
    //转屏, ASSlipControl本身并不做转屏限制，所有转屏均由初始化时的子Controller提供
    UIViewController *_slipCurViewController; //记录当前显示的controller,left/right/center，用于转屏时做判断
    UIViewController *_slipPresentModeViewController;  //记录从slip present出去的controller，用于转屏时做判断
}

@property(nonatomic,retain)UIViewController *centerViewController;
@property(nonatomic,retain)UIViewController *rightViewController;
@property(nonatomic,retain)UIViewController *leftViewController;
@property(nonatomic,assign)CGFloat animationDuration;
@property(nonatomic,assign)BOOL isFullScreen;
@property(nonatomic,assign)id<ASSlipControlDelegate> delegate;

/**
 *	@brief	初始化ASSlipControl
 *
 *	@param 	centerViewController 	中间的viewController，必须要有
 *	@param 	rightViewController 	右边的viewController，可以为nil
 *	@param 	leftViewController 	左边的viewController，可以为nil
 *                               
 *	@return	初始化完成后的ASSlipControl实例
 */
- (id)initWithCenterViewController:(UIViewController *)centerViewController
               rightViewController:(UIViewController *)rightViewController
                leftViewController:(UIViewController *)leftViewController;


/**
 *	@brief	从ASSlipPresent
 *
 *	@param 	modalViewController 	需要被present的viewController
 *	@param 	animated 	是否支持动画
 *
 *  需要用到该功能时，子viewController必须保存一个ASSlipControl的实例，用于调用该方法，如：
 *  [@code]
 *  rightViewController.delegate = asSlipControl;
 *  [(ASSlipControl)self.delegate slipPresentModalViewController:controller animated:YES];
 *  [@/code]
 */
- (void)slipPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;


@end
