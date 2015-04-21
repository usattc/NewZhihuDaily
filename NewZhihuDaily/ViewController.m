//
//  ViewController.m
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import "ViewController.h"
#import "Defines.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NewsCell.h"
#import "CustomImageView.h"
#import "DetailViewController.h"
#import "Progress.h"
#import "AMWaveTransition.h"
#import "FMDatabase.h"
#import "FavoriteViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CustomImageViewDelegate, UINavigationControllerDelegate> {
//    UIScrollView *_scrollView;
    UIRefreshControl *_refreshControl; // 下拉刷新
    NSMutableArray *_dataList; // 新闻列表
    NSMutableArray *_topDataList; // 顶部新闻列表
    NSTimer *_timer; // 顶部新闻列表滚动定时
    UIScrollView *_scrollView; // 顶部滚动新闻
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AMWaveTransition *interactive; // 波浪效果

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _dataList = [NSMutableArray array];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中..."];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
//    UIBarButtonItem *navLeftBtn = [[UIBarButtonItem alloc] initWithTitle:@"收藏夹"
//                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(favorites)];
//    self.navigationItem.rightBarButtonItem = navLeftBtn;

    UIBarButtonItem *navRightBtn = [[UIBarButtonItem alloc] initWithTitle:@"收藏夹"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    self.navigationItem.rightBarButtonItem = navRightBtn;
    
    [self getDataList];
    
    [self openDatabase];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 用于tableView的动画效果
    [self.navigationController setDelegate:self];
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // 用于tableView的动画效果
    [self.interactive detachInteractiveGesture];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tablewView viewForHeaderInSection:(NSInteger)section {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth , 200)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(5 * ScreenWidth, 200);
        for (int i = 0; i < 5; i++) {
            CustomImageView *imgView = [[CustomImageView alloc]initWithFrame:CGRectMake(i * ScreenWidth, 0, ScreenWidth, 200)];
            imgView.delegate = self;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.backgroundColor = [UIColor clearColor];
            imgView.tag = 100 + i;
            [_scrollView addSubview:imgView];
        }
    }
    
    for (int i = 0; i < _topDataList.count; i++) {
        CustomImageView *imgView = _scrollView.subviews[i];
        // 图片
        [imgView sd_setImageWithURL:[NSURL URLWithString:_topDataList[i][@"image"]]];
        // 标题
        imgView.title = _topDataList[i][@"title"];
    }
    return _scrollView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.newsId = _dataList[indexPath.row][@"id"];
    detail.titleStr = _dataList[indexPath.row][@"title"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  80;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"newsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:self options:nil];
        cell = (NewsCell *)[nib objectAtIndex:0];
    }
    if (_dataList.count != 0) {
        cell.newsLabel.text = _dataList[indexPath.row][@"title"];
        [cell.newsLabel sizeToFit];
        
        NSString *urlString = _dataList[indexPath.row][@"images"][0];
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.newsImageView sd_setImageWithURL:url];
    }
    return cell;
}

#pragma mark - GetDataList

- (void)getDataList {
    [Progress showProgressWithString:@"正在加载.." andTime:30];
    [[AFHTTPRequestOperationManager manager] GET:@"http://news-at.zhihu.com/api/3/news/latest" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"result:%@", responseObject);
        [_dataList addObjectsFromArray:responseObject[@"stories"]];
        _topDataList = responseObject[@"top_stories"];

        // 关闭等待效果
        [Progress showProgressWithBool:NO];
        [_tableView reloadData];
        
        // 该定时器用于首页图片定时展示
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(dealWithTimer)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        
        if ([_refreshControl isRefreshing]) {
            [_refreshControl endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Refresh

- (void)refresh {
    [self getDataList];
}

#pragma mark - CustomImageViewDelegate

- (void)customImageView:(CustomImageView *)customImgView didClickButton:(UIButton *)button {
    // 获取点击的图片的下标
    NSInteger index = customImgView.tag - 100;
    
    // 根据下标取_topDataList数组取出对应新闻的id
    NSString *ID = [NSString stringWithFormat:@"%@",_topDataList[index][@"id"]] ;
    
    DetailViewController *detail = [[DetailViewController alloc]init];
    detail.newsId = ID;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Favorite

- (void)favorite {
    FavoriteViewController *favoriteVC = [[FavoriteViewController alloc] init];
    [self.navigationController pushViewController:favoriteVC animated:YES];
}

#pragma mark - UITableView动画效果

// 用于TableView的动画效果
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation != UINavigationControllerOperationNone) {
        return [AMWaveTransition transitionWithOperation:operation andTransitionType:AMWaveTransitionTypeBounce];
    }
    return nil;
}

#pragma mark - OpenDatabase

- (void)openDatabase {
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = arr[0];
    NSString *dbPath = [docDir stringByAppendingPathComponent:@"offline.db"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
    }
    else{
        BOOL success = [db executeUpdate:@"create table if not exists offline (id integer primary key, title text, newsId text)"];
        if (success) {
            NSLog(@"建表成功");
        }
        else{
            NSLog(@"建表失败");
        }
    }
}

#pragma mark - dealloc

- (void)dealloc {
    // 用于TableView的动画效果
    [self.navigationController setDelegate:nil];
}

#pragma mark - Timer

// 顶部的定时器
- (void)dealWithTimer {
    CGPoint offset = _scrollView.contentOffset;
    NSInteger page = offset.x / ScreenWidth;
    if (page == _topDataList.count - 1) {
        page = 0;
    }
    else{
        page++;
    }
    
    [_scrollView setContentOffset:CGPointMake(page * ScreenWidth, 0) animated:YES];
}

#pragma mark - Others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
