//
//  NSObject+SIModel.h
//  SIModelDemo
//
//  Created by 杨晴贺 on 16/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger,SIDataType){
    SIDataTypeUnknow = 0,
    SIDataTypeBool,
    SIDataTypeFloat,
    SIDataTypeDouble,
    SIDataTypeChar,
    SIDataTypeShort,
    SIDataTypeInt,
    SIDataTypeLongLong,
    SIDataTypeUnsignedInt,
    SIDataTypeUnsignedShort,
    SIDataTypeUnsignedChar,
    SIDataTypeUnsignedLongLong,
    SIDataTypeNSNumber,
    SIDataTypeNSString,
    SIDataTypeNSMutableString,
    SIDataTypeNSArray,
    SIDataTypeNSMutableArray,
    SIDataTypeNSDictionary,
    SIDataTypeNSMutableDictionary,
    SIDataTypeCustomObject,
};

@protocol SIModel <NSObject>

+ (NSDictionary <NSString *,NSString *> *)si_clazzInArray ;
+ (NSDictionary <NSString *,NSString *> *)si_replaceKeyFromPropertyName ;

+ (void)si_beginObjectToModel:(id)obj ;
+ (void)si_endObjectToModel:(id)model ;

@end


@interface NSObject (SIModel)

+ (instancetype)si_modelWithObj:(id)obj ;
+ (instancetype)si_modelArrayWithObj:(id)obj ;

- (NSMutableDictionary *)si_modelToDictionary ;

@end
