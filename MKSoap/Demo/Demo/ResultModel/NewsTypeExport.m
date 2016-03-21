//
//  NewsTypeExport.m
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NewsTypeExport.h"
#import "MKSoapKeyMappingProtocol.h"

@implementation NewsTypeExport

+ (NSDictionary *)mkz_mappingKeysFromPerpertyToData {
    return @{@"newsTypeId":@"id"};
}

@end
