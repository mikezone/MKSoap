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
#import "NSObject+GDataXML.h"

NSUInteger const QNAME_TYPE = 1;
NSUInteger const QNAME_NAMESPACE = 0;
NSUInteger const QNAME_MARSHAL = 3;

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

- (void)parseToSerializer:(MKXmlSerializer *)serializer {
    [super parseToSerializer:serializer]; // 获取return部分
    
    Class mappingClass = [self getMappingClass];
    NSLog(@"%@", self.returnValuePart);
    NSArray *childrens = self.returnValuePart.children;
    if (childrens.count > 1) {
        id value = [self.returnValuePart valueWithPropertyClass:mappingClass?:[NSDictionary class]];
        serializer.willReturnModel = value?:[NSNull null];
    } else if (childrens.count == 1) {
        GDataXMLElement *element = childrens.firstObject;
        if (mappingClass && [element.name isEqualToString:@"text"]) { // CDATA
            [self parseCDATAString:element.stringValue toSerializer:serializer];
            return;
        } else {
            id value = [self.returnValuePart valueWithPropertyClass:mappingClass?:[NSDictionary class]];
            serializer.willReturnModel = value?:[NSNull null];
        }
        
    }
}

- (void)parseCDATAString:(NSString *)CDATAString toSerializer:(MKXmlSerializer *)serializer {
    NSString *string = [NSString stringWithFormat:@"<B>%@</B>", CDATAString];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:string options:0 error:NULL];
    NSUInteger modelCount = document.rootElement.children.count;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:modelCount];
    for (NSUInteger i = 0; i < modelCount; i++) {
        GDataXMLElement *element = document.rootElement.children[i];
        Class clazz = [self getMappingClass];
        id obj = [[clazz alloc] init];
        [obj setValuesWithGDataElement:element aClass:clazz];
        [array addObject:obj];
    }
    serializer.willReturnModel = array.copy;
}

- (Class)getMappingClass {
    MKSoapObject *soapObject = self.bodyOut;
    Class clazz = soapObject.mappingClass;
    return clazz;
}

//- (void)setValuesWithGDataElement:(GDataXMLElement *)element forObject:(id)obj aClass:(Class)aClass {
//    Class clazz = [self getMappingClass];
//    // 思路一：先将xml转为字典或者数组 再转为模型
//    
//    // 思路二：直接在解析xml的过程中 转为模型
//    NSUInteger childCount = element.children.count;
//    if ([clazz isSubclassOfClass:[NSDictionary class]]) {
//        for (NSUInteger i = 0; i < childCount; i++) {
//            GDataXMLElement *child = element.children[i];
//            id value = [self valueFromGDataElement:child propertyType:@"@\"NSString\""];
//            [obj setValue:value forKey:[NSString stringWithFormat:@"v%tu", i]];
//        }
//        return;
//    }
//    
//    unsigned int count = 0;
//    objc_property_t *properties = class_copyPropertyList(clazz, &count);
//    for (int i = 0; i < count; i++) {
//        const char *name = property_getName(properties[i]);
////        printf("%s\n", name);
//        NSString *key = [NSString stringWithUTF8String:name];
//        if (i < childCount) {
//            const char *typeValue = property_copyAttributeValue(properties[i], "T");
////            printf("%s", attributeValue);
//            NSString *type = [NSString stringWithUTF8String:typeValue];
//            GDataXMLElement *child = element.children[i];
//            id value = [self valueFromGDataElement:child propertyType:type];
//            [obj setValue:value forKey:key];
//        }
//    }
//    return;
//}

//- (id)valueFromGDataElement:(GDataXMLElement *)element propertyType:(NSString *)type{
//    NSString *valueString = element.XMLString;
//    if (valueString.length == 0) {
//        return [NSNull null];
//    }
//    if ([type rangeOfString:@"@"].location != NSNotFound) { // 如果是Foundation的类型统一返回字符串，需要修改(包括id类型)
//        return valueString;
//    }
//    if ([_baseDataType containsObject:type]) {
//        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        return [formatter numberFromString:valueString];
//    }
//    return [NSNull null];
//}

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
