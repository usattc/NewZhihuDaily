//
//  FavoriteCell.m
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import "FavoriteCell.h"

@implementation FavoriteCell

- (void)awakeFromNib {
    // Initialization code
    
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.numberOfLines = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
