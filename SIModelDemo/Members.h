//
//  Members.h
//  SIModelDemo
//
//  Created by 杨晴贺 on 17/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User ;
@interface Members : NSObject<NSCoding>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSArray *users;
@property (nonatomic) User *leader ;

@end
