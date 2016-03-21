//
//  MKSoapSerializationEnvelope.m
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKSoapSerializationEnvelope.h"
#import "MKSoapObject.h"
#import "GDataXMLNode.h"
#import <objc/runtime.h>
#import "MKXmlSerializer.h"

NSUInteger const QNAME_TYPE = 1;
NSUInteger const QNAME_NAMESPACE = 0;
NSUInteger const QNAME_MARSHAL = 3;

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

//static final Marshal DEFAULT_MARSHAL = new DM();
//public Hashtable properties = new Hashtable();
//
//Hashtable idMap = new Hashtable();
//Vector multiRef; // = new Vector();
//
//public boolean implicitTypes;

//public boolean dotNet;
//protected Hashtable qNameToClass = new Hashtable();
//protected Hashtable classToQName = new Hashtable();

@implementation MKSoapSerializationEnvelope

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

+ (instancetype)soapSerializationEnvelopeWithSoapVersion:(NSUInteger)soapVersion {
    return [[self alloc] initWithSoapVersion:soapVersion];
}

- (instancetype)initWithSoapVersion:(NSUInteger)soapVersion {
    if (self = [super initWithSoapVersion:soapVersion]) {
//        addMapping(enc, ARRAY_MAPPING_NAME, PropertyInfo.VECTOR_CLASS);
//        DEFAULT_MARSHAL.register(this);
    }
    return self;
}

- (void)parseToSerializer:(MKXmlSerializer *)parser {
    [super parseToSerializer:parser];
    
    // 这里开始将returnValuePart这个GDataXMLElement类型转为model
//    NSLog(@"%@", self.returnValuePart);
    MKSoapObject *soapObject = self.bodyOut;
    Class clazz = soapObject.mappingClass;
    
    if (!clazz || [clazz isSubclassOfClass:[NSDictionary class]]) {
        clazz = [NSMutableDictionary class];
    }
    
    NSArray *childrens = self.returnValuePart.children;
    if (childrens.count > 1) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:childrens.count];
        for (GDataXMLElement *element in childrens) {
            id obj = [[clazz alloc] init];
            [self setValuesWithGDataElement:element forObject:obj];
            [array addObject:obj];
        }
        parser.willReturnModel = array.copy;
    } else if (childrens.count == 1) {
        id obj = [[clazz alloc] init];
        [self setValuesWithGDataElement:childrens.firstObject forObject:obj];
        parser.willReturnModel = obj;
    }
}

- (void)setValuesWithGDataElement:(GDataXMLElement *)element forObject:(id)obj {
    MKSoapObject *soapObject = self.bodyOut;
    Class clazz = soapObject.mappingClass;
    // 思路一：先将xml转为字典或者数组 再转为模型
    
    // 思路二：直接在解析xml的过程中 转为模型
    NSUInteger childCount = element.children.count;
    if ([clazz isSubclassOfClass:[NSDictionary class]]) {
        for (NSUInteger i = 0; i < childCount; i++) {
            GDataXMLElement *child = element.children[i];
            id value = [self valueFromGDataElement:child propertyType:@"@\"NSString\""];
            [obj setValue:value forKey:[NSString stringWithFormat:@"v%tu", i]];
        }
        return;
    }
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
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
            [obj setValue:value forKey:key];
        }
    }
    return;
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
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        return [formatter numberFromString:valueString];
    }
    return [NSNull null];
}

//- (void)parseBody {
//    
//}
//
//- (void)readSerializable {
//    
//}
//
//- (id)readUnknown {
//    return nil;
//}
//
//- (NSUInteger)getIndex {
//    return 0;
//}
//
//- (void)readVector {
//    
//}
//
//- (id)read {
//    return nil;
//}
//
//- (id)readInstance {
//    return nil;
//}
//
//- (void)getInfo {
//
//}
//
//- (void)addMapping {
//
//}
//
//- (void)addTemplate {
//
//}
//
//- (void)getResponse {
//
//}
//
//- (void)writeBody {
//
//}
//
//- (void)writeObjectBody {
//
//}
//
//- (void)writeProperty {
//
//}
//
//- (void)writeElement {
//
//}
//
//- (void)writeVectorBody {
//
//}
@end
