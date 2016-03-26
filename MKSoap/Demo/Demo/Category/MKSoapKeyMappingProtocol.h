//
//  NSObject+MKSoap.h
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSArray *getPropertyListWithClass(Class aClass);

@interface NSObject (MKSoapKeyValueProtocol)

+ (NSDictionary *)mkz_mappingArrayPropertyElementType;
+ (NSDictionary *)mkz_mappingKeysFromPerpertyToData;

@end
