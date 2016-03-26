//
//  MKSoapObject.h
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKSoapObject : NSObject

@property (nonatomic, copy) NSString *nameSpace;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, assign) Class mappingClass;
@property (nonatomic, copy) NSString *SOAPAction;

+ (instancetype)soapObjectWithNameSpace:(NSString *)nameSpace methodName:(NSString *)methodName;
- (NSString *)parameterKeyAtIndex:(NSUInteger)index;
- (id)parameterValueAtIndex:(NSUInteger)index;
- (id)parameterValueWithKey:(NSString *)key;
- (NSUInteger)parameterCount;
- (void)setParameter:(id)parameter atIndex:(NSUInteger)atIndex;

- (MKSoapObject *(^)(NSString *key, id value))addParameter;
- (instancetype)addParameterWithKey:(NSString *)key value:(id)value;
- (instancetype)addParameterWithKeys:(NSArray *)keys values:(NSArray *)values;

@end
