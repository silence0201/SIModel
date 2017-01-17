//
//  ModelToDictionary.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 17/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "ModelToDictionary.h"
#import "NSObject+SIModel.h"
#import "Members.h"

@interface ModelToDictionary ()

@end

@implementation ModelToDictionary

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    self.title = @"模型转数组" ;
    
    NSDictionary *json = @{
                           @"desciption":@"这是简单描述信息",
                           @"id":@"10010",
                           @"name":@"Silence",
                           @"users": @[@{
                                           @"name" : @"Silence",
                                           @"age" : @"17",
                                           @"sex" : @"男"
                                           }],
                           @"leader":@{
                                   @"name" : @"Silence",
                                   @"age" : @"17",
                                   @"sex" : @"男"
                                   }
                           } ;
    Members *members = [Members si_modelWithObj:json] ;
    
    NSDictionary *dic = [members si_modelToDictionary] ;
    UITextView *view = [[UITextView alloc]initWithFrame:self.view.bounds] ;
    [self.view addSubview:view] ;
    view.text = [NSString stringWithFormat:@"%@",dic] ;
}


@end
