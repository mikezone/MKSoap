//
//  MKSoapObject.m
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKSoapObject.h"

@interface MKSoapObject ()

@property (nonatomic, strong) NSMutableArray *paraKeys;
@property (nonatomic, strong) NSMutableArray *paraValues;

@end

@implementation MKSoapObject

+ (instancetype)soapObjectWithNameSpace:(NSString *)nameSpace methodName:(NSString *)methodName {
    return [[self alloc] initWithNameSpace:nameSpace methodName:methodName];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace methodName:(NSString *)methodName {
    if (self = [super init]) {
        self.nameSpace = nameSpace;
        self.methodName = methodName;
    }
    return self;
}

- (NSString *)parameterKeyAtIndex:(NSUInteger)index {
    if (index >= self.paraKeys.count) {
        return nil;
    }
    return self.paraKeys[index];
}

- (id)parameterValueAtIndex:(NSUInteger)index {
    if (index >= self.paraValues.count) {
        return nil;
    }
    return self.paraValues[index];
}

- (id)parameterValueWithKey:(NSString *)key {
    if (key.length) {
        NSUInteger index = [self.paraKeys indexOfObject:key];
        return self.paraValues[index];
    }
    return nil;
}

- (NSUInteger)parameterCount {
    return self.paraKeys.count;
}

- (void)setParameter:(id)parameter atIndex:(NSUInteger)atIndex {
    if (!parameter || [parameter isEqual:[NSNull null]] || atIndex >= self.paraValues.count) {
        return;
    }
    self.paraValues[atIndex] = parameter;
}

- (MKSoapObject *(^)(NSString *key, id value))addParameter{
    return ^id(NSString *key, id value){
        [self.paraKeys addObject:key];
        [self.paraValues addObject:value];
        return self;
    };
}

- (instancetype)addParameterWithKey:(NSString *)key value:(id)value {
    [self.paraKeys addObject:key];
    [self.paraValues addObject:value];
    return self;
}

- (instancetype)addParameterWithKeys:(NSArray *)keys values:(NSArray *)values {
    if (keys.count != values.count) {
        return self;
    }
    for (NSUInteger i = 0; i < keys.count; i++) {
        [self.paraKeys addObject:keys[i]];
        [self.paraValues addObject:values[i]];
    }
    return self;
}

#pragma lazy load

- (NSMutableArray *)paraKeys {
    if (!_paraKeys) {
        _paraKeys = [NSMutableArray array];
    }
    return _paraKeys;
}

- (NSMutableArray *)paraValues {
    if (!_paraValues) {
        _paraValues = [NSMutableArray array];
    }
    return _paraValues;
}

@end
