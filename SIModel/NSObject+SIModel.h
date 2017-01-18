//
//  NSObject+SIModel.h
//  SIModelDemo
//
//  Created by 杨晴贺 on 16/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SIModel <NSObject>

/**
    NSArray对应类的信息字典

    @return 返回key为Array的属性名,Value为对应的类名的字典
 */
+ (NSDictionary <NSString *,Class> *)si_clazzInArray ;


/**
    需要替换的属性名字典

    @return 返回key为属性名,Value为字典或JSON对象中对应的key的名称
 */
+ (NSDictionary <NSString *,NSString *> *)si_replaceKeyFromPropertyName ;


/**
    在开始转换的时候进行调用

    @param obj 成功转换为的字典对象
 */
+ (void)si_beginObjectToModel:(id)obj ;


/**
    在转换成功后进行调用

    @param model 成功转换的模型对象
 */
+ (void)si_endObjectToModel:(id)model ;

@end


@interface NSObject (SIModel)


/**
    将JSON/JSON数据流或字典转换为模型

    @param obj JSON/JSON数据流或字典数据
    @return 成功转换的模型对象
 */
+ (instancetype)si_modelWithObj:(id)obj ;


/**
    将JSON数组/字典数组转换为模型

    @param obj JSON数组/字典数组
    @return 成功转换的数组模型对象
 */
+ (NSArray *)si_modelArrayWithObj:(id)obj ;


/**
    将当然模型转换为字典

    @return 转换成功的字典对象
 */
- (NSMutableDictionary *)si_modelToDictionary ;


/**
    快速解档

    @param aDecoder aDecoder
 */
- (void)si_decode:(NSCoder *)aDecoder ;


/**
    快速归档

    @param aCoder aCoder
 */
- (void)si_encode:(NSCoder *)aCoder ;


/**
 归档的实现
 */
#define SICodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
if (self = [super init]) { \
[self si_decode:decoder]; \
} \
return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
[self si_encode:encoder]; \
}

#define SIModelCodingImplementation SICodingImplementation

@end
