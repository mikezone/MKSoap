//
//  PersonExport.m
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "PersonExport.h"
#import "MKSoapKeyMappingProtocol.h"

@implementation PersonExport

+ (NSDictionary *)mkz_mappingKeysFromPerpertyToData {
    return @{@"personId":@"id"};
}

@end
