//
//  MKSoapEnvelope.m
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKSoapEnvelope.h"
#import "MKXmlSerializer.h"
#import "MKSoapObject.h"
#import "GDataXMLNode.h"


NSUInteger const VER10 = 100;
NSUInteger const VER11 = 110;
NSUInteger const VER12 = 120;
NSString *const ENV2001 = @"http://www.w3.org/2001/12/soap-envelope";
NSString *const ENC2001 = @"http://www.w3.org/2001/12/soap-encoding";
NSString *const ENV = @"http://schemas.xmlsoap.org/soap/envelope/";
NSString *const ENC = @"http://schemas.xmlsoap.org/soap/encoding/";
NSString *const XSD = @"http://www.w3.org/2001/XMLSchema";
NSString *const XSI = @"http://www.w3.org/2001/XMLSchema-instance";
NSString *const XSD1999 = @"http://www.w3.org/1999/XMLSchema";
NSString *const XSI1999 = @"http://www.w3.org/1999/XMLSchema-instance";

@interface MKSoapEnvelope ()

@end

@implementation MKSoapEnvelope

- (instancetype)initWithSoapVersion:(NSUInteger)soapVersion {
    if (self = [super init]) {
        self.soapVersion = soapVersion;
        if (soapVersion == VER10) {
            self.xsi = XSI1999;
            self.xsd = XSD1999;
        } else {
            self.xsi = XSI;
            self.xsd = XSD;
        }
        if (soapVersion < VER12) {
            self.enc = ENC;
            self.env = ENV;
        } else {
            self.enc = ENC2001;
            self.env = ENV2001;
        }
    }
    return self;
}

- (void)parseFromSerializer:(MKXmlSerializer *)xmlserializer {
    // 失败时会进入失败回调，因此这里只需解析成功的情况
    MKSoapObject *soapObject = self.bodyOut;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlserializer.returnedXMLStringData options:0 error:nil];
    GDataXMLElement *rootElement = [doc rootElement];
    GDataXMLNode *nameSpaceNode = [rootElement namespaces].firstObject;
    GDataXMLElement *bodyElement = [rootElement elementsForName:[NSString stringWithFormat:@"%@:Body", nameSpaceNode.name]].firstObject;
    GDataXMLElement *responseElement = bodyElement.children.firstObject;
    GDataXMLNode *node = [responseElement namespaces].firstObject;
    NSString *responseNameSpaceName = node.name;
//    NSLog(@"%@", responseElement.name); // ns:authenticateResponse
    if ([responseElement.name isEqualToString:[NSString stringWithFormat:@"%@:%@Response", responseNameSpaceName, soapObject.methodName]]) {
        GDataXMLElement *returnElement = responseElement.children.firstObject;
        self.returnValuePart = returnElement;
    }
}

- (void)parseHeaderFromSerializer:(MKXmlSerializer *)xmlSerializer {

}

- (void)parseBodyFromSerializer:(MKXmlSerializer *)xmlSerializer {

}

- (void)writeToSerializer:(MKXmlSerializer *)xmlSerializer {
    xmlSerializer.setPrefix(@"i", self.xsi);
    xmlSerializer.setPrefix(@"d", self.xsd);
    xmlSerializer.setPrefix(@"c", self.enc);
    xmlSerializer.setPrefix(@"v", self.env);
    xmlSerializer.startTag(self.env, @"Envelope");
    xmlSerializer.startTag(self.env, @"Header");
    [self writeHeaderToSerializer:xmlSerializer];
    xmlSerializer.endTag(self.env, @"Header");
    xmlSerializer.startTag(self.env, @"Body");
    [self writeBodyToSerializer:xmlSerializer];
    xmlSerializer.endTag(self.env, @"Body");
    xmlSerializer.endTag(self.env, @"Envelope");
}

- (void)writeHeaderToSerializer:(MKXmlSerializer *)xmlSerializer {
    if (self.headerOut) {
        for (int i = 0; i < self.headerOut.count; i++) {
            // 组装HeaderOut
        }
    }
}

- (void)writeBodyToSerializer:(MKXmlSerializer *)xmlSerializer {
    NSMutableString *string = [NSMutableString string];
    MKSoapObject *soapObject = (MKSoapObject *)self.bodyOut;
    [string appendFormat:@"<n0:%@ xmlns:n0=\"%@\">", soapObject.methodName, soapObject.nameSpace];
    for (NSUInteger i = 0; i < soapObject.parameterCount; i++) {
        NSString *paraValue = [soapObject parameterValueAtIndex:i];
        NSString *paraKey = [soapObject parameterKeyAtIndex:i];
        [string appendFormat:@"<%@>%@</%@>", paraKey, paraValue, paraKey];
    }
    [string appendFormat:@"</n0:%@>", soapObject.methodName];
    [xmlSerializer appendContent:string];
}

@end
