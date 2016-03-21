//
//  NewsExport.m
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NewsExport.h"
#import "MKSoapKeyMappingProtocol.h"

@implementation NewsExport

+ (NSDictionary *)mkz_mappingKeysFromPerpertyToData {
    return @{@"newsId":@"id"};
}

@end
