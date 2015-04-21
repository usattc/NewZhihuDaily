//
//  FavoriteViewController.m
//  NewZhihuDaily
//
//  Created by TTC on 4/21/15.
//  Copyright (c) 2015 TTC. All rights reserved.
//

#import "FavoriteViewController.h"
#import "DetailViewController.h"
#import "FavoriteCell.h"
#import "FMDatabase.h"

@interface FavoriteViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_favoriteList; // 收藏列表
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _favoriteList = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *navLeftBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(popNav)];
    self.navigationItem.leftBarButtonItem = navLeftBtn;
    
    self.title = @"收藏夹";
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self openDatabase];
}

- (void)viewWillAppear:(BOOL)animated {
    // 显示NavBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - PopNav

- (void)popNav {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailViewController *detail = [[DetailViewController alloc]init];
    if (_favoriteList.count == 0) {
        return;
    }
    detail.newsId = _favoriteList[indexPath.row][@"newsId"];
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  40;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 无收藏, 提示用户"请添加收藏"
    if (_favoriteList.count == 0) {
        return 1;
    }
    else {
        return _favoriteList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"newsCell";
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FavoriteCell" owner:self options:nil];
        cell = (FavoriteCell *)[nib objectAtIndex:0];
    }
    
    if (_favoriteList.count != 0) {
        cell.titleLabel.text = _favoriteList[indexPath.row][@"title"];
        [cell.titleLabel sizeToFit];
    }
    else {
        cell.titleLabel.text = @"请先到新闻页中添加收藏";
        cell.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.titleLabel.font = [UIFont systemFontOfSize:17];
    }

    return cell;
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
    else {
        FMResultSet *rs = [db executeQuery:@"select * from offline"];
        while ([rs next]) {
            NSDictionary *result = [rs resultDictionary];
            [_favoriteList addObject:result];
        }
    }
}

#pragma mark - Others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
