//
//  CustomImageView.h
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;

// protocol用户传送用户点击事件
@protocol CustomImageViewDelegate <NSObject>

- (void)customImageView:(CustomImageView *)customImgView didClickButton:(UIButton *)button;

@end

@interface CustomImageView : UIImageView

@property (strong, nonatomic) NSString *title;
@property (nonatomic) id<CustomImageViewDelegate> delegate;

@end
