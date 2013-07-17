//
//  AppDelegate.h
//  ASSlipControlDemo
//
//  Created by jinkelei on 13-5-21.
//  Copyright (c) 2013年 JinKelei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RootViewController *_rootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
