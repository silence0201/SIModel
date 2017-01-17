# SIModel
将JSON快速转换模型

使用说明
====
###安装
#####手工导入
将项目目录下的`SIModel`导入项目中

###使用
1. 导入头文件

	```objective-c
	#import "NSObject+SIModel.h"
	```
	
2. 建立模型对象,进行属性定义`(仅支持默认get和set方法)`
3. 如果`Array`中包含自定义`Class`,需要实现:

	```objective-c
	+ (NSDictionary <NSString *,Class> *)si_clazzInArray{
    	return @{@"users":[User class]} ;
	}
	```
	
4. 如何属性名和JSON或字典中的key不相同,需要实现:

		```objective-c
		+ (NSDictionary <NSString *,NSString *> *)si_replaceKeyFromPropertyName{
    		return @{
             		@"ID" : @"id" ,
             		@"desc" : @"desciption"
             		} ;
		}
		```
		
5. 过程处理

		```objective-c
		+ (void)si_beginObjectToModel:(id)obj{
    		NSLog(@"开始转换:%@",obj) ;
		}
		+ (void)si_endObjectToModel:(id)model{
   	 		NSLog(@"结束转换:%@",model) ;
		}
		```
		
6. 更多请查看`NSObject+SIModel.h`说明

##SIModel
SIModel is available under the MIT license. See the LICENSE file for more info.