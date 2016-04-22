//
//  NSObject+GDataXML.m
//  mikezone
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
 valuetype 0 整型
 valuetype 1 字符串
 valuetype 3 长整型
 valuetype 10 数组
 valuetype 11 对象类型
 */
typedef NS_ENUM(NSUInteger, ValueType){
    ValueTypeInt = 0,
    ValueTypeString = 1,
    ValueTypeLong = 3,
    ValueTypeArray = 10,
    ValueTypeObject = 11
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

NSString *const MKDataTypePointer = @"^";
NSString *const MKDataTypeCString = @"*";
NSString *const MKDataTypeObject = @"@";
NSString *const MKDataTypeClass = @"#";
NSString *const MKDataTypeSelector = @":";

NSString *const MKDataTypeIvar = @"^{objc_ivar=}";
NSString *const MKDataTypeMethod = @"^{objc_method=}";
NSString *const MKDataTypeBlock = @"@?";

NSString *const MKDataTypeCArray = @"[";
NSString *const MKDataTypeCStruct = @"{";
NSString *const MKDataTypeCUnion = @"(";

NSString *const MKDataTypeBitfield = @"b";
NSString *const MKDataTypeUnknown = @"?";

@implementation NSObject (GDataXML)

static NSSet *_foundationDataTypeClassSet;
static NSSet *_baseDataTypeCodeSet;

+ (void)load {
    _foundationDataTypeClassSet = [NSSet setWithObjects:
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
    
    _baseDataTypeCodeSet = [NSSet setWithObjects:
                           MKDataTypeChar, MKDataTypeShort, MKDataTypeInt, MKDataTypeLong, MKDataTypeLongLong,
                           MKDataTypeUnsignedChar, MKDataTypeUnsignedShort,MKDataTypeUnsignedInt, MKDataTypeUnsignedLong, MKDataTypeUnsignedLongLong,
                           MKDataTypeFloat, MKDataTypeDouble, MKDataTypeBOOL,nil];
}

- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass {
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
                    continue;
                } else if (type == ValueTypeString) {
                    GDataXMLElement *element = child.children.firstObject;
                    [self setValue:element.stringValue forKey:mapedKey];
                    continue;
                } else if (type == ValueTypeArray) {
                    // DataPojo
                    GDataXMLNode *lengthNode = [child attributeForName:ATTR_length];
                    NSUInteger length = [lengthNode.stringValue unsignedIntegerValue];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:length];
                    if (length) {
                        GDataXMLNode *propertyTypeNode = [child.children[0] attributeForName:ATTR_type];
                        Class arrayElementclazz = NSClassFromString(propertyTypeNode.stringValue);
                        for (NSUInteger i = 0; i < length; i++) {
                            id obj = [[arrayElementclazz alloc] init];
                            [obj setValuesWithGDataElement:child.children[i] aClass:arrayElementclazz];
                            [array addObject:obj];
                        }
                    }                    
                    [self setValue:array.copy forKey:mapedKey];
                    continue;
                } else if (type == ValueTypeObject){
                    if (child.childCount) {
                        GDataXMLElement *element = child.children.firstObject;
                        NSString *classString = [element attributeForName:ATTR_type].stringValue;
                        Class clazz = NSClassFromString(classString);
                        id obj = [[clazz alloc] init];
                        [obj setValuesWithGDataElement:child.children.firstObject aClass:clazz];
                        [self setValue:obj forKey:mapedKey];
                    }
                    continue;
                }
            }
        }
    }
}

+ (NSString *)getMappedPropertyNameWithKey:(NSString *)key {
    if ([self respondsToSelector:NSSelectorFromString(@"mkz_mappingKeysFromPerpertyToData")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *mapDict = [self performSelector:NSSelectorFromString(@"mkz_mappingKeysFromPerpertyToData")];
#pragma clang diagnostic pop
        NSArray *localKeys = [mapDict allKeysForObject:key];
        if (localKeys.count) {
            return localKeys[0];
        }
    }
    return key;
}

@end

@implementation GDataXMLNode (DataTypeConvert)

- (id)valueWithPropertyClass:(Class)aClass {
    if (aClass) {
        NSString *typeCode = [NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(aClass)];
        return [self valueWithPropertyTypeCode:typeCode];
    } else {
        return nil;
    }
}

- (id)valueWithPropertyTypeCode:(NSString *)typeCode {
    NSString *stringValue = self.stringValue;
    if (stringValue.length == 0) {
        return [NSNull null];
    }
    
    if ([typeCode rangeOfString:@"@"].location != NSNotFound) {
        NSUInteger length = typeCode.length;
        if (length < 3) {
            return [NSNull null];
        }
        NSString *type = [typeCode substringWithRange:NSMakeRange(2, length - 3)];
        Class clazz = NSClassFromString(type);
        if ([_foundationDataTypeClassSet containsObject:clazz]) {
            // 1.foundation数据类型的处理
            if ([clazz isSubclassOfClass:[NSDictionary class]]) {
                return [self dictionaryValue];
            } else if ([clazz isSubclassOfClass:[NSArray class]]) {
                return [self arrayValue];
            } else if ([clazz isSubclassOfClass:[NSSet class]]) {
                return [self setValue];
            } else if ([clazz isSubclassOfClass:[NSNumber class]]) {
                return [self numberValue];
            } else if ([clazz isSubclassOfClass:[NSData class]]) {
                return [self dataValue];
            } else if ([clazz isSubclassOfClass:[NSDate class]]) {
                return [self dateValue];
            } else if ([clazz isSubclassOfClass:[NSURL class]]) {
                return [self URLValue];
            } else if ([clazz isSubclassOfClass:[NSString class]]) {
                return stringValue;
            }
        } else {
            // 2.自定义class类型的处理
            NSUInteger childCount = self.children.count;
            
            id obj = [[clazz alloc] init];
            unsigned int count = 0;
            objc_property_t *properties = class_copyPropertyList(clazz, &count);
            for (int i = 0; i < count; i++) {
                const char *name = property_getName(properties[i]);
                NSString *key = [NSString stringWithUTF8String:name];
                if (i < childCount) {
                    const char *typeCodeChars = property_copyAttributeValue(properties[i], "T");
                    NSString *typeCode = [NSString stringWithUTF8String:typeCodeChars];
                    GDataXMLElement *child = self.children[i];
                    id value = [child valueWithPropertyTypeCode:typeCode];
                    [obj setValue:value forKey:key];
                    continue;
                } else {
                    break;
                }
            }
            return obj;
            
        }
    }
    // 3.基本数据类型
    if ([_baseDataTypeCodeSet containsObject:typeCode]) {
        return [stringValue numberValue];
    }
    // 4.没有找到合适的类型，返回valueString
    return stringValue;
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSUInteger childCount = self.children.count;
    for (NSUInteger i = 0; i < childCount; i++) {
        GDataXMLElement *child = self.children[i];
        NSString *value = [child stringValue];
        [dictionary setValue:value ?:[NSNull null] forKey:[NSString stringWithFormat:@"v%tu", i]];
    }
    return dictionary.copy;
}

- (NSArray *)arrayValue {
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger childCount = self.children.count;
    for (NSUInteger i = 0; i < childCount; i++) {
        GDataXMLElement *child = self.children[i];
        NSString *value = [child stringValue];
        [array addObject:value ?:[NSNull null]];
    }
    return array.copy;
}

- (NSSet *)setValue {
    NSMutableSet *set = [NSMutableSet set];
    NSUInteger childCount = self.children.count;
    for (NSUInteger i = 0; i < childCount; i++) {
        GDataXMLElement *child = self.children[i];
        NSString *value = [child stringValue];
        [set addObject:value ?:[NSNull null]];
    }
    return set.copy;
}

- (NSNumber *)numberValue {
    return [self.stringValue numberValue] ?:@(0);
}

- (NSData *)dataValue {
    return [self.stringValue dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDate *)dateValue {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter dateFromString:self.stringValue];
}

- (NSURL *)URLValue {
    return [NSURL URLWithString:self.stringValue];
}

@end
