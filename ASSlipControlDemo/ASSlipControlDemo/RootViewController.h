//
//  RootViewController.h
//  ASSlipControlDemo
//
//  Created by jinkelei on 13-5-21.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASSlipControl.h"

@interface RootViewController : UIViewController<ASSlipControlDelegate>
{
    ASSlipControl *_slipControl;
}

@end
