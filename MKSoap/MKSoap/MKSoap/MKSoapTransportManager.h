//
//  MKSoapTransportManager.h
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSoapObject.h"

@interface MKSoapTransportManager : NSObject

+ (instancetype)manager;
- (NSURLSessionDataTask *)service:(NSString *)serviceURLString
                       soapObject:(MKSoapObject *)soapObject
                          success:(void (^)(id))success
                          failure:(void (^)(NSError *))failure;
@end
