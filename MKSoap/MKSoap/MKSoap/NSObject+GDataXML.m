//
//  NSObject+GDataXML.m
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NSObject+GDataXML.h"
#import "GDataXMLNode.h"
#import <objc/runtime.h>
#import "NSString+Convert.h"

NSString *const LABEL_DataPojo = @"DataPojo";
NSString *const ATTR_type = @"type";
NSString *const ATTR_propertyname = @"propertyname";
NSString *const ATTR_valuetype = @"valuetype";
NSString *const ATTR_value = @"value";
NSString *const ATTR_length = @"length";
NSString *const ATTR_isnull = @"isnull";
NSString *const ATTR_isnull_TRUE= @"true";

/*
 valuetype 11 类型
 valuetype 1 字符串
 valuetype 3 长整型
 valuetype 0 整型
 valuetype 10 数组
 */
typedef NS_ENUM(NSUInteger, ValueType){
    ValueTypeInt = 0,
    ValueTypeString = 1,
    ValueTypeLong = 3,
    ValueTypeArray = 10,
    ValueTypeClass = 11
};


NSString *const MKDataTypeChar = @"c";
NSString *const MKDataTypeShort = @"s";
NSString *const MKDataTypeInt = @"i";
NSString *const MKDataTypeLong = @"l";
NSString *const MKDataTypeLongLong = @"q";
NSString *const MKDataTypeFloat = @"f";
NSString *const MKDataTypeDouble = @"d";

NSString *const MKDataTypeUnsignedChar = @"C";
NSString *const MKDataTypeUnsignedShort = @"S";
NSString *const MKDataTypeUnsignedInt = @"I";
NSString *const MKDataTypeUnsignedLong = @"L";
NSString *const MKDataTypeUnsignedLongLong = @"Q";

NSString *const MKDataTypeBOOL = @"B";
NSString *const MKDataTypePointer = @"*";

NSString *const MKDataTypeIvar = @"^{objc_ivar=}";
NSString *const MKDataTypeMethod = @"^{objc_method=}";
NSString *const MKDataTypeBlock = @"@?";
NSString *const MKDataTypeClass = @"#";
NSString *const MKDataTypeSEL = @":";
NSString *const MKDataTypeId = @"@";

@implementation NSObject (GDataXML)

static NSSet *_foundationDataType;
static NSSet *_baseDataType;

+ (void)load
{
    _foundationDataType = [NSSet setWithObjects:
                           [NSObject class],
                           [NSURL class],
                           [NSDate class],
                           [NSNumber class],
                           [NSDecimalNumber class],
                           [NSData class],
                           [NSMutableData class],
                           [NSArray class],
                           [NSMutableArray class],
                           [NSDictionary class],
                           [NSMutableDictionary class],
                           [NSString class],
                           [NSMutableString class], nil];
    
    _foundationDataType = [NSSet setWithObjects:
                           MKDataTypeChar, MKDataTypeShort, MKDataTypeInt, MKDataTypeLong, MKDataTypeLongLong,
                           MKDataTypeUnsignedChar, MKDataTypeUnsignedShort,MKDataTypeUnsignedInt, MKDataTypeUnsignedLong, MKDataTypeUnsignedLongLong,
                           MKDataTypeFloat, MKDataTypeDouble, MKDataTypeBOOL,nil];
}

- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass {
    [self setValuesWithGDataElement:element aClass:aClass inCDATA:NO];
}

- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass inCDATA:(BOOL)inCDATA {
    if (!inCDATA) {
        NSUInteger childCount = element.children.count;
        if ([aClass isSubclassOfClass:[NSDictionary class]]) {
            for (NSUInteger i = 0; i < childCount; i++) {
                GDataXMLElement *child = element.children[i];
                id value = [self valueFromGDataElement:child propertyType:@"@\"NSString\""];
                [self setValue:value forKey:[NSString stringWithFormat:@"v%tu", i]];
            }
            return;
        }
        
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(aClass, &count);
        for (int i = 0; i < count; i++) {
            const char *name = property_getName(properties[i]);
            //        printf("%s\n", name);
            NSString *key = [NSString stringWithUTF8String:name];
            if (i < childCount) {
                const char *typeValue = property_copyAttributeValue(properties[i], "T");
                //            printf("%s", attributeValue);
                NSString *type = [NSString stringWithUTF8String:typeValue];
                GDataXMLElement *child = element.children[i];
                id value = [self valueFromGDataElement:child propertyType:type];
                [self setValue:value forKey:key];
            }
        }
        return;
    }
    
    // inCDATA
//    NSLog(@"%@", element);
    
//    DataPojo
    if ([element.name isEqualToString:LABEL_DataPojo]) {
        GDataXMLNode *typeNode = [element attributeForName:ATTR_type];
        Class clazz = NSClassFromString(typeNode.stringValue);
        if (clazz) {
            for (NSUInteger i = 0; i < element.childCount; i++) {
                GDataXMLElement *child = element.children[i]; // DataProperty
                GDataXMLNode *isnullNode = [child attributeForName:ATTR_isnull];
                if ([isnullNode.stringValue isEqualToString:ATTR_isnull_TRUE]) {
                    continue;
                }
                GDataXMLNode *propertyNameNode = [child attributeForName:ATTR_propertyname];
                GDataXMLNode *valueTypeNode = [child attributeForName:ATTR_valuetype];
                
                NSString *mapedKey = [clazz getMappedPropertyNameWithKey:propertyNameNode.stringValue];
                NSUInteger type = [valueTypeNode.stringValue unsignedIntegerValue];
                if (type == ValueTypeInt || type == ValueTypeLong) {
                    // 取value
                    GDataXMLNode *valueNode = [child attributeForName:ATTR_value];
                    NSNumber *number = [valueNode.stringValue numberValue];
                    [self setValue:number forKey:mapedKey];
                } else if (type == ValueTypeString) {
                    GDataXMLElement *element = child.children.firstObject;
                    [self setValue:element.stringValue forKey:mapedKey];
                } else if (type == ValueTypeArray) {
                    // DataPojo
                    GDataXMLNode *lengthNode = [child attributeForName:ATTR_length];
                    NSUInteger length = [lengthNode.stringValue unsignedIntegerValue];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:length];
                    GDataXMLNode *propertyTypeNode = [element attributeForName:ATTR_type];
                    Class clazz = NSClassFromString(propertyTypeNode.stringValue);
                    for (NSUInteger i = 0; i < length; i++) {
                        id obj = [[clazz alloc] init];
                        [obj setValuesWithGDataElement:child.children[i] aClass:clazz inCDATA:YES];
                        [array addObject:obj];
                    }
                    [self setValue:array.copy forKey:mapedKey];
                } else if (type == ValueTypeClass){
                    if (child.childCount) {
                        GDataXMLElement *element = child.children.firstObject;
                        NSString *classString = [element attributeForName:ATTR_type].stringValue;
                        Class clazz = NSClassFromString(classString);
                        id obj = [[clazz alloc] init];
                        [obj setValuesWithGDataElement:child.children.firstObject aClass:clazz inCDATA:YES];
                        [self setValue:obj forKey:mapedKey];
                    }
                }
            }
        }
    }
}

+ (NSString *)getMappedPropertyNameWithKey:(NSString *)key {
    if ([self respondsToSelector:NSSelectorFromString(@"mkz_mappingKeysFromPerpertyToData")]) {
#warning 换成allKeyForObject
        NSDictionary *mapDict = [self performSelector:NSSelectorFromString(@"mkz_mappingKeysFromPerpertyToData")];
        __block NSString *localKey = nil;
        if ([mapDict.allValues containsObject:key]) {
            [mapDict.allValues enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:key]) {
                    localKey = mapDict.allKeys[idx];
                    *stop = YES;
                }
            }];
            return localKey;
        } else {
            return key;
        }
    }
    return key;
}

- (id)valueFromGDataElement:(GDataXMLElement *)element propertyType:(NSString *)type{
    NSString *valueString = element.XMLString;
    if (valueString.length == 0) {
        return [NSNull null];
    }
    if ([type rangeOfString:@"@"].location != NSNotFound) { // 如果是Foundation的类型统一返回字符串，需要修改(包括id类型)
        return valueString;
    }
    if ([_baseDataType containsObject:type]) {
        return [valueString numberValue];
    }
    return [NSNull null];
}

@end
