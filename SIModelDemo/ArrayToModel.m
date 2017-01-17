//
//  ArrayToModel.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 17/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "ArrayToModel.h"
#import "NSObject+SIModel.h"
#import "Members.h"

@interface ArrayToModel ()

@end

@implementation ArrayToModel

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    self.title = @"数组字典模型" ;
    
    NSArray *json = @[
                      @{
                          @"desciption":@"测试描述",
                          @"id":@"10010",
                          @"name":@"Silence",
                          @"users":@[
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"26",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"16",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"36",
                                      @"sex" : @"女"
                                      }
                                  
                                  ],
                          @"leader":@{
                                  @"name" : @"Silence",
                                  @"age" : @"17",
                                  @"sex" : @"男"
                                  }
                          
                          },
                      @{
                          @"desciption":@"测试描述",
                          @"id":@"10010",
                          @"name":@"Silence",
                          @"users":@[
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"26",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"16",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"36",
                                      @"sex" : @"女"
                                      }
                                  
                                  ],
                          @"leader":@{
                                  @"name" : @"Silence",
                                  @"age" : @"17",
                                  @"sex" : @"男"
                                  }
                          
                          },
                      @{
                          @"desciption":@"测试描述",
                          @"id":@"10010",
                          @"name":@"Silence",
                          @"users":@[
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"26",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"16",
                                      @"sex" : @"男"
                                      },
                                  @{
                                      @"name" : @"silence",
                                      @"age" : @"36",
                                      @"sex" : @"女"
                                      }
                                  ],
                          @"leader":@{
                                  @"name" : @"Silence",
                                  @"age" : @"17",
                                  @"sex" : @"男"
                                  }
                          
                          },
                      ];
    
    NSArray *models = [Members si_modelArrayWithObj:json] ;
    
    UITextView *view = [[UITextView alloc]initWithFrame:self.view.bounds] ;
    [self.view addSubview:view] ;
    view.text = [NSString stringWithFormat:@"%@",models] ;

}


@end
