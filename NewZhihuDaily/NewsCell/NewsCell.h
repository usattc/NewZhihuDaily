//
//  NewsCell.h
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *newsLabel; // 标题
@property (weak, nonatomic) IBOutlet UIImageView *newsImageView; // 新闻图片

@end
