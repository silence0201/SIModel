//
//  NSObject+SIModel.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 16/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "NSObject+SIModel.h"
#import <objc/objc-class.h>

@interface SIProperty : NSObject

@property (nonatomic,assign,readonly) objc_property_t property ;
@property (nonatomic,strong,readonly) NSString *propertyName ;
@property (nonatomic,assign,readonly) SIDataType dateType ;
@property (nonatomic,assign,readonly) Class propertyClazz ;
@property (nonatomic,assign,readonly) SEL getter ;
@property (nonatomic,assign,readonly) SEL setter ;

+ (NSArray *)propertiesForClass:(Class)cls ;

- (instancetype)initWithProperty:(objc_property_t)property ;
+ (instancetype)sipropertyWithProperty:(objc_property_t)property ;

@end

@implementation SIProperty

- (instancetype)initWithProperty:(objc_property_t)property{
    if (self = [super init]) {
        _property = property ;
        _propertyName = [NSString stringWithUTF8String:property_getName(property)] ;
        _dateType = [self dataTypeWithAttribute:[NSString stringWithUTF8String:property_copyAttributeValue(property, "T")]] ;
        // 标准get/set方法
        _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_propertyName substringToIndex:1].uppercaseString, [_propertyName substringFromIndex:1]]) ;
        _getter = NSSelectorFromString(_propertyName) ;
    }
    return self ;
}

+ (instancetype)sipropertyWithProperty:(objc_property_t)property{
    return [[self alloc]initWithProperty:property] ;
}

- (SIDataType)dataTypeWithAttribute:(NSString *)attribute{
    if([attribute hasPrefix:@"B"])              return SIDataTypeBool            ;
    else if ([attribute hasPrefix:@"f"])        return SIDataTypeFloat           ;
    else if ([attribute hasPrefix:@"d"])        return SIDataTypeDouble          ;
    else if ([attribute hasPrefix:@"c"])        return SIDataTypeChar            ;
    else if ([attribute hasPrefix:@"s"])        return SIDataTypeShort           ;
    else if ([attribute hasPrefix:@"i"])        return SIDataTypeInt             ;
    else if ([attribute hasPrefix:@"q"])        return SIDataTypeLongLong        ;
    else if ([attribute hasPrefix:@"C"])        return SIDataTypeUnsignedChar    ;
    else if ([attribute hasPrefix:@"S"])        return SIDataTypeUnsignedShort   ;
    else if ([attribute hasPrefix:@"I"])        return SIDataTypeUnsignedInt     ;
    else if ([attribute hasPrefix:@"Q"])        return SIDataTypeUnsignedLongLong;
    else if ([attribute hasPrefix:@"@"]){
        NSString *propertyClass = [attribute stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]] ;
        _propertyClazz = NSClassFromString(propertyClass) ;
        if ([_propertyClazz isSubclassOfClass:[NSNumber class]])           return SIDataTypeNSNumber           ;
        if ([_propertyClazz isSubclassOfClass:[NSMutableString class]])    return SIDataTypeNSMutableString    ;
        if ([_propertyClazz isSubclassOfClass:[NSString class]])           return SIDataTypeNSString           ;
        if ([_propertyClazz isSubclassOfClass:[NSMutableArray class]])     return SIDataTypeNSMutableArray     ;
        if ([_propertyClazz isSubclassOfClass:[NSArray class]])            return SIDataTypeNSArray            ;
        if ([_propertyClazz isSubclassOfClass:[NSMutableDictionary class]])return SIDataTypeNSMutableDictionary;
        if ([_propertyClazz isSubclassOfClass:[NSDictionary class]])       return SIDataTypeNSDictionary       ;
    }
        
    return SIDataTypeUnknow ;
}

+ (NSArray *)propertiesForClass:(Class)cls{
    NSMutableArray *properties = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t * propertyList = class_copyPropertyList(cls, &propertyCount);
    for (int i = 0 ; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        SIProperty *p = [[SIProperty alloc]initWithProperty:property];
        [properties addObject:p];
    }
    free(propertyList);
    return properties;
}

@end

@interface SIClass : NSObject

@property (nonatomic,assign,readonly) Class clazz ;
@property (nonatomic,strong,readonly) NSArray<SIProperty *> *properties ;
@property (nonatomic,strong,readonly) NSDictionary <NSString *,NSString *> *clazzInArray ;
@property (nonatomic,strong,readonly) NSDictionary <NSString *,NSString *> *replaceKeyFromPropertyName ;

- (instancetype)initWithClass:(Class)clazz ;
+ (instancetype)siclassWithClazz:(Class)clazz ;

@end

@implementation SIClass

- (instancetype)initWithClass:(Class)clazz{
    if(self = [super init]){
        _clazz = clazz ;
        if ([clazz respondsToSelector:@selector(si_clazzInArray)]){
            _clazzInArray = [clazz si_clazzInArray] ;
        }
        if ([clazz respondsToSelector:@selector(si_replaceKeyFromPropertyName)]){
            _replaceKeyFromPropertyName = [clazz si_replaceKeyFromPropertyName] ;
        }
        NSMutableArray *properties = [NSMutableArray array] ;
        while (clazz != [NSObject class]) {
            [properties addObjectsFromArray:[SIProperty propertiesForClass:clazz]] ;
        }
        _properties = [properties copy] ;
    }
    return self ;
}

+ (instancetype)siclassWithClazz:(Class)clazz{
    static CFMutableDictionaryRef classCache ;
    static dispatch_semaphore_t semaphore ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks) ;
        semaphore = dispatch_semaphore_create(1) ;
    }) ;
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) ;
    SIClass *siClass = CFDictionaryGetValue(classCache, (__bridge const void *)(clazz)) ;
    dispatch_semaphore_signal(semaphore) ;
    
    if(!siClass){
        siClass = [[SIClass alloc]initWithClass:clazz] ;
        if(siClass){
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) ;
            CFDictionarySetValue(classCache, (__bridge const void *)(clazz), (__bridge const void *)(siClass)) ;
            dispatch_semaphore_signal(semaphore) ;
        }
    }
    
    return siClass ;
}


@end

@implementation NSObject (SIModel)




@end
