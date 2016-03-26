//
//  NSObject+GDataXML.h
//  mikezone
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@class GDataXMLElement;

@interface NSObject (GDataXML)

- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass;

@end


@interface GDataXMLNode (DataTypeConvert)

- (id)valueWithPropertyClass:(Class)aClass;
- (id)valueWithPropertyTypeCode:(NSString *)typeCode;

- (NSDictionary *)dictionaryValue;
- (NSArray *)arrayValue;
- (NSSet *)setValue;
- (NSNumber *)numberValue;
- (NSData *)dataValue;
- (NSDate *)dateValue;
- (NSURL *)URLValue;

@end
