//
//  Progress.h
//  x-bionic
//
//  Created by TTC on 15/1/7.
//  Copyright (c) 2015年 TTC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface Progress : MBProgressHUD

// 无文字, 无取消时间
+ (void)showProgressWithBool:(BOOL)isShow;

// 无文字, 有取消时间
+ (void)showProgressWithTime:(NSTimeInterval)time;

// 显示文字, 无取消时间
+ (void)showProgressWithString:(NSString *)string;

// 显示文字, 有取消时间
+ (void)showProgressWithString:(NSString *)string andTime:(NSTimeInterval)time;

@end
