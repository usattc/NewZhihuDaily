//
//  CustomImageView.m
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import "CustomImageView.h"
#import "Defines.h"

@interface CustomImageView () {
    UILabel *_label;
}

@end

@implementation CustomImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // 设置用户能够与用户交互
        self.userInteractionEnabled = YES;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, ScreenWidth - 20, 50)];
        _label.textColor = [UIColor whiteColor];
        _label.numberOfLines = 2;
        _label.font = [UIFont boldSystemFontOfSize:17];
        _label.shadowColor = [UIColor darkGrayColor];
        _label.shadowOffset = CGSizeMake(1, 1);
        [self addSubview:_label];
    }
    _label.text = title;
}

- (void)clickButton:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(customImageView:didClickButton:)]) {
        [_delegate customImageView:self didClickButton:button];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
