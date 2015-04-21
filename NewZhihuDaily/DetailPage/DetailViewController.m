//
//  DetailViewController.m
//  2014-12-05-3
//
//  Created by TTC on 12/6/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "DetailViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "Defines.h"
#import "Progress.h"
#import "FMDatabase.h"

@interface DetailViewController () {
    UIWebView *_webView;
    UIImageView *_imageView;
    UIView *_bottomBar;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Progress showProgressWithString:@"正在加载.." andTime:30];

    // 本页面不需要显示navigationBar
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 35)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.decelerationRate = 1;
    _webView.userInteractionEnabled = YES;
    [self.view addSubview:_webView];
    
    [self initBottomBar];
    
    // 添加_imageView在_webView的scrollView上面, 让_imageView可以跟着_webView一起滚动
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [_webView.scrollView addSubview:_imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    // 请求数据
    NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/3/news/%@", self.newsId];
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        // 设置图片
        [_imageView sd_setImageWithURL:[NSURL URLWithString:responseObject[@"image"]]];
        // 获取HTML代码
        NSString *body = responseObject[@"body"];
        // 加载CSS格式
        NSString *cssUrl = responseObject[@"css"][0];
        NSString *linkString = [NSString stringWithFormat:@"<link rel=\"Stylesheet\" type=\"text/css\" href=\"%@\" />", cssUrl];
        // 拼接包含CSS的HTML代码
        NSString *htmlString = [NSString stringWithFormat:@"%@%@", linkString, body];
        // 加载HTML代码
        [_webView loadHTMLString:htmlString baseURL:nil];
        [Progress showProgressWithBool:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)initBottomBar {
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 35, ScreenWidth, 35)];
    _bottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bottomBar];
    
    // 添加阴影凸显边缘
    _bottomBar.layer.shadowColor = [UIColor grayColor].CGColor;
    _bottomBar.layer.shadowOffset = CGSizeMake(0, 2);
    _bottomBar.layer.shadowOpacity = 1;
    
    // 添加返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 35);
    [backButton setTitle:@"<" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:backButton];
    
    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteButton.frame = CGRectMake(ScreenWidth / 2 - 25, 0, 50, 35);
    favoriteButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [favoriteButton setTitle:@"收藏" forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [favoriteButton addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:favoriteButton];
}

#pragma mark - AddFavorite

- (void)favorite {
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = arr[0];
    NSString *dbPath = [docDir stringByAppendingPathComponent:@"offline.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
    }
    else {
        BOOL success = [db executeUpdate:@"insert into offline (title, newsId) values (?, ?)", _titleStr, _newsId];
        if (success) {
            NSLog(@"数据插入成功");
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window.rootViewController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"收藏成功";
            [hud hide:YES afterDelay:1];
        }
        else {
            NSLog(@"数据插入失败");
        }
    }
}

#pragma mark - PopNav

- (void)pop {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
