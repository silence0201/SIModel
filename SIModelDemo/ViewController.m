//
//  ViewController.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 16/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "ViewController.h"


static NSString *const cellIdentifier = @"Cell" ;
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView ;

@property (nonatomic,strong) NSArray *tableDataSource ;
@property (nonatomic,strong) NSArray *classArray ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"请选择" ;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault] ;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]] ;
    
    [self.view addSubview:self.tableView] ;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds] ;
        _tableView.delegate = self ;
        _tableView.dataSource = self ;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds] ;
        imageView.image = [UIImage imageNamed:@"1"] ;
        
        UIVisualEffectView *visual = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]] ;
        visual.frame = self.view.bounds ;
        [imageView addSubview:visual] ;
        
        _tableView.backgroundView = imageView ;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    }
    return _tableView ;
}


- (NSArray *)tableDataSource{
    if (!_tableDataSource) {
        _tableDataSource = @[@"字典转模型",@"数组字典转模型",@"模型转数组"] ;
    }
    return _tableDataSource ;
}

- (NSArray *)classArray{
    if (!_classArray) {
        _classArray = @[@"DictionaryToModel",@"ArrayToModel",@"ModelToDictionary"] ;
    }
    return _classArray ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableDataSource.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier] ;
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] ;
    }
    cell.backgroundColor = [UIColor clearColor] ;
    cell.textLabel.text = self.tableDataSource[indexPath.row] ;
    cell.detailTextLabel.text = self.classArray[indexPath.row] ;
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES] ;
    UIViewController *vc = [[NSClassFromString(self.classArray[indexPath.row]) alloc]init] ;
    [self.navigationController pushViewController:vc animated:YES] ;
}


@end
