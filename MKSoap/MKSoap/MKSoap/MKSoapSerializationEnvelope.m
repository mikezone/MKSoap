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

- (void)parseFromSerializer:(MKXmlSerializer *)serializer {
    [super parseFromSerializer:serializer]; // 获取return部分
    
    Class mappingClass = [self getMappingClass];
    NSArray *childrens = self.returnValuePart.children;
    if (childrens.count > 1) {
        id value = [self.returnValuePart valueWithPropertyClass:mappingClass?:[NSDictionary class]];
        self.bodyIn = value?:[NSNull null];
    } else if (childrens.count == 1) {
        GDataXMLElement *element = childrens.firstObject;
        if (mappingClass && [element.name isEqualToString:@"text"]) { // CDATA
            [self parseCDATAString:element.stringValue toSerializer:serializer];
            return;
        } else {
            id value = [self.returnValuePart valueWithPropertyClass:mappingClass?:[NSDictionary class]];
            self.bodyIn = value?:[NSNull null];
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
    self.bodyIn = array.copy;
}

- (Class)getMappingClass {
    MKSoapObject *soapObject = self.bodyOut;
    Class clazz = soapObject.mappingClass;
    return clazz;
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
