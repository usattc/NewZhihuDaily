//
//  NewsCell.m
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (void)awakeFromNib {
    // Initialization code

    _newsLabel.textColor = [UIColor blackColor];
    _newsLabel.numberOfLines = 2;
    
    _newsImageView.backgroundColor = [UIColor clearColor];
    _newsImageView.contentMode = UIViewContentModeScaleAspectFill;
    _newsImageView.clipsToBounds = YES;
    // 图片圆角
    _newsImageView.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
