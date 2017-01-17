//
//  Members.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 17/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "Members.h"
#import "User.h"

@implementation Members

+ (NSDictionary <NSString *,Class> *)si_clazzInArray{
    return @{@"users":[User class]} ;
}
+ (NSDictionary <NSString *,NSString *> *)si_replaceKeyFromPropertyName{
    return @{
             @"ID" : @"id" ,
             @"desc" : @"desciption"
             } ;
}

+ (void)si_beginObjectToModel:(id)obj{
    NSLog(@"开始转换:%@",obj) ;
}
+ (void)si_endObjectToModel:(id)model{
    NSLog(@"结束转换:%@",model) ;
}

@end
