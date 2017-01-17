//
//  DictionaryToModel.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 17/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "DictionaryToModel.h"
#import "NSObject+SIModel.h"
#import "Members.h"

@interface DictionaryToModel ()

@end

@implementation DictionaryToModel

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    self.title = @"字典转模型" ;
    
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
    
    UITextView *view = [[UITextView alloc]initWithFrame:self.view.bounds] ;
    [self.view addSubview:view] ;
    view.text = [NSString stringWithFormat:@"%@",members] ;
}

@end
