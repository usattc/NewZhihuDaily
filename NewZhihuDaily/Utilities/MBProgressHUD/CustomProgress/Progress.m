//
//  Progress.m
//  x-bionic
//
//  Created by TTC on 15/1/7.
//  Copyright (c) 2015年 TTC. All rights reserved.
//

#import "Progress.h"


@implementation Progress

// 无文字, 无取消时间
+ (void)showProgressWithBool:(BOOL)isShow {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 添加等待效果
    if (isShow) {
        [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
    }
    // 取消等待效果
    else {
        // 用hideAllHUDsForView:animated:方法能在多次网络请求时彻底取消等待效果
        [MBProgressHUD hideAllHUDsForView:appDelegate.window.rootViewController.view animated:YES];
//        [MBProgressHUD hideHUDForView:appDelegate.window.rootViewController.view animated:YES];
    }
}

// 无文字, 有取消时间
+ (void)showProgressWithTime:(NSTimeInterval)time {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
    [hub hide:YES afterDelay:time];
}

// 显示文字, 无取消时间
+ (void)showProgressWithString:(NSString *)string {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = string;
}

// 显示文字, 有取消时间
+ (void)showProgressWithString:(NSString *)string andTime:(NSTimeInterval)time {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = string;
    [hud hide:YES afterDelay:time];
}

@end
