//
//  NSObject+SIModel.m
//  SIModelDemo
//
//  Created by 杨晴贺 on 16/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "NSObject+SIModel.h"
#import <objc/objc-class.h>

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

@interface SIProperty : NSObject

@property (nonatomic,assign,readonly) objc_property_t property ;
@property (nonatomic,strong,readonly) NSString *propertyName ;
@property (nonatomic,assign,readonly) SIDataType dataType ;
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
        _dataType = [self dataTypeWithAttribute:[NSString stringWithUTF8String:property_copyAttributeValue(property, "T")]] ;
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
        return SIDataTypeCustomObject ;
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
@property (nonatomic,strong,readonly) NSDictionary <NSString *,Class> *clazzInArray ;
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
            clazz = class_getSuperclass(clazz) ;
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

+ (instancetype)si_modelWithObj:(id)obj{
    NSDictionary *dic = [self dictionaryWithObj:obj] ;
    if (!dic) return nil ;
    SIClass *clazz = [SIClass siclassWithClazz:self] ;
    return [self setModelClass:clazz dictionary:dic] ;
}


+ (NSDictionary *)dictionaryWithObj:(id)obj{
    if(!obj) return nil ;
    NSDictionary *dictonary ;
    NSData *jsonData ;
    
    if([obj isKindOfClass:[NSDictionary class]]){
        dictonary = obj ;
    }else if ([obj isKindOfClass:[NSString class]]){
        NSString *str = (NSString *)obj ;
        jsonData = [str dataUsingEncoding:NSUTF8StringEncoding] ;
    }else if ([obj isKindOfClass:[NSData class]]){
        jsonData = obj ;
    }
    
    if (jsonData) {
        dictonary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL] ;
        if (![dictonary isKindOfClass:[NSDictionary class]]) dictonary = nil ;
    }
    
    return dictonary ;
}

+ (NSObject *)setModelClass:(SIClass *)modelClass dictionary:(NSDictionary *)dictionary{
    if([modelClass.clazz respondsToSelector:@selector(si_beginObjectToModel:)]){
        [modelClass.clazz si_beginObjectToModel:dictionary] ;
    }
    NSObject *obj = [modelClass.clazz new] ;
    for (SIProperty *p in modelClass.properties){
        id value ;
        if ([modelClass.replaceKeyFromPropertyName.allKeys containsObject:p.propertyName]) {
            NSString *key = modelClass.replaceKeyFromPropertyName[p.propertyName] ;
            value = dictionary[key] ;
        }else{
            value = dictionary[p.propertyName] ;
        }
        
        switch (p.dataType) {
            case SIDataTypeBool:
                ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value boolValue] : 0);
                break;
            case SIDataTypeFloat:
                ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value floatValue] : 0);
                break;
            case SIDataTypeDouble:
                ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value doubleValue] : 0);
                break;
            case SIDataTypeChar:
                ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value charValue] : 0);
                break;
            case SIDataTypeShort:
                ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value shortValue] : 0);
                break;
            case SIDataTypeInt:
                ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value intValue] : 0);
                break;
            case SIDataTypeLongLong:
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value longLongValue] : 0);
                break;
            case SIDataTypeUnsignedChar:
                ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedCharValue] : 0);
                break;
            case SIDataTypeUnsignedShort:
                ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedShortValue] : 0);
                break;
            case SIDataTypeUnsignedInt:
                ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedIntValue] : 0);
                break;
            case SIDataTypeUnsignedLongLong:
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? [value unsignedLongLongValue] : 0);
                break;
            case SIDataTypeNSNumber:
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, [value isKindOfClass:[NSNumber class]] ? value : nil);
                break;
            case SIDataTypeCustomObject:
                ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, [p.propertyClazz si_modelWithObj:value]);
                break;
            case SIDataTypeNSString:
            case SIDataTypeNSMutableString:
                if([value isKindOfClass:[NSString class]]){
                    NSString *str = (NSString *)value;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, p.dataType == SIDataTypeNSMutableString ? str.mutableCopy : str);
                }
                break;
            case SIDataTypeNSDictionary:
            case SIDataTypeNSMutableDictionary:
                if([value isKindOfClass:[NSDictionary class]]){
                    NSDictionary *dictionary = (NSDictionary *)value;
                    ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, p.dataType == SIDataTypeNSMutableDictionary ? dictionary.mutableCopy : dictionary);
                }
                break;
            case SIDataTypeNSArray:
            case SIDataTypeNSMutableArray:
                if([value isKindOfClass:[NSArray class]]){
                    if([modelClass.clazzInArray.allKeys containsObject:p.propertyName] && modelClass.clazzInArray[p.propertyName]){
                        Class  cls = modelClass.clazzInArray[p.propertyName];
                        NSMutableArray *models = [NSMutableArray array];
                        for(id obj in (NSArray *)value){
                            NSObject *model = [cls si_modelWithObj:obj];
                            if(model) [models addObject:model];
                        }
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, p.dataType == SIDataTypeNSMutableArray ? models : models.copy);
                    }
                    else{
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)obj, p.setter, nil);
                    }
                }
                break;
            default:
                break;
        }
    }
    
    if([modelClass.clazz respondsToSelector:@selector(si_endObjectToModel:)]){
        [modelClass.clazz si_endObjectToModel:obj];
    }
    
    return obj ;
}


+ (NSArray *)si_modelArrayWithObj:(id)obj{
    NSArray *array = [self arrayWithObj:obj] ;
    if(!array) return nil ;
    NSMutableArray *models = [NSMutableArray array] ;
    for (NSDictionary *dictionary in array) {
        if(![dictionary isKindOfClass:[NSNull class]] && dictionary){
            NSObject *model = [self si_modelWithObj:dictionary];
            if(model) [models addObject:model];
        }
    }
    return models ;
}

+ (NSArray *)arrayWithObj:(id)obj{
    if (!obj) return nil ;
    NSArray *array ;
    NSData *jsonData ;
    
    if ([obj isKindOfClass:[NSArray class]]) {
        array = obj ;
    }else if ([obj isKindOfClass:[NSString class]]){
        NSString *str = (NSString *)obj ;
        jsonData = [str dataUsingEncoding:NSUTF8StringEncoding] ;
    }else if ([obj isKindOfClass:[NSData class]]){
        jsonData = obj ;
    }
    
    if(jsonData){
        array = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL] ;
        if (![array isKindOfClass:[NSArray class]]) array = nil ;
    }
    return array ;
}



- (NSMutableDictionary *)si_modelToDictionary{
    SIClass *clazz = [SIClass siclassWithClazz:self.class] ;
    return [self dictionaryForModelClass:clazz] ;
}

- (NSMutableDictionary *)dictionaryForModelClass:(SIClass *)modelClass{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary] ;
    for (SIProperty *p in modelClass.properties){
        NSString *key = p.propertyName ;
        if ([modelClass.replaceKeyFromPropertyName.allKeys containsObject:key]){
            key = modelClass.replaceKeyFromPropertyName[p.propertyName] ;
        }
        switch (p.dataType) {
            case SIDataTypeBool:{
                NSNumber *num = @(((bool (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeFloat:{
                NSNumber *num = @(((float (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeDouble:{
                NSNumber *num = @(((double (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeChar:{
                NSNumber *num = @(((char (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeShort:{
                NSNumber *num = @(((short (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeInt:{
                NSNumber *num = @(((int (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeLongLong:{
                NSNumber *num = @(((long long (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeUnsignedChar:{
                NSNumber *num = @(((unsigned char (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeUnsignedShort:{
                NSNumber *num = @(((unsigned short (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeUnsignedInt:{
                NSNumber *num = @(((unsigned int (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeUnsignedLongLong:{
                NSNumber *num = @(((unsigned long long (*)(id, SEL))(void *) objc_msgSend)(self, p.getter));
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeNSNumber:{
                NSNumber *num = ((NSNumber * (*)(id, SEL))(void *) objc_msgSend)(self, p.getter);
                if(num) dictionary[key] = num;
            }
                break;
            case SIDataTypeNSString:
            case SIDataTypeNSMutableString:{
                NSString *str = ((NSString * (*)(id, SEL))(void *) objc_msgSend)(self, p.getter);
                if(str) dictionary[key] = str;
            }
                break;
            case SIDataTypeNSDictionary:
            case SIDataTypeNSMutableDictionary:{
                NSDictionary *dict = ((NSDictionary * (*)(id, SEL))(void *) objc_msgSend)(self, p.getter);
                NSDictionary *mDict = [self dictionaryForDictionaryInModels:dict];
                if(mDict && mDict.count) dictionary[key] = mDict;
            }
                break;
            case SIDataTypeNSArray:
            case SIDataTypeNSMutableArray:{
                NSArray *array = ((NSArray * (*)(id, SEL))(void *) objc_msgSend)(self, p.getter);
                NSArray *mArray = [self arrayDictionaryForArrayInModels:array];
                if(mArray && mArray.count) dictionary[key] = mArray;
            }
                break;
            case SIDataTypeCustomObject:{
                NSObject *object = ((NSObject * (*)(id, SEL))(void *) objc_msgSend)(self, p.getter);
                NSDictionary *dict = [object si_modelToDictionary];
                if(dict && dict.count) dictionary[key] = dict;
            }
                break;
            default:
                break;
        }
    }
    return dictionary ;
}

- (NSDictionary *)dictionaryForDictionaryInModels:(NSDictionary *)models{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary] ;
    for (id obj in models.allKeys){
        id value = models[obj] ;
        
        if ([value isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
            dictionary[obj] = value ;
        }else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]){
            NSArray *array = [self arrayDictionaryForArrayInModels:value] ;
            if (array) dictionary[obj] = array ;
        }else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]]){
            NSDictionary *dict = [self dictionaryForDictionaryInModels:value] ;
            if (dict) dictionary[obj] = dict ;
        }else{
            NSDictionary *dict = [value si_modelToDictionary] ;
            if (dict) dictionary[obj] = dict ;
        }
    }
    
    return dictionary ;
}

- (NSArray *)arrayDictionaryForArrayInModels:(NSArray *)models{
    NSMutableArray *array = [NSMutableArray array] ;
    for (id obj in models){
        if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
            [array addObject:obj] ;
        }else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]){
            NSArray *arr = [self arrayDictionaryForArrayInModels:obj] ;
            if (arr) [array addObject:arr] ;
        }else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSMutableDictionary class]]){
            NSDictionary *dic = [self dictionaryForDictionaryInModels:obj] ;
            if (dic) [array addObject:dic] ;
        }else{
            NSDictionary *dic = [obj si_modelToDictionary] ;
            if (dic) [array addObject:dic] ;
        }
    }
    return array ;
}

@end
