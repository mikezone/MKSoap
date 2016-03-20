//
//  MKm
//  TJRailway
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

- (void)parseToSerializer:(MKXmlSerializer *)parser {
    // 失败时会进入失败回调，因此这里只需解析成功的情况
    MKSoapObject *soapObject = self.bodyOut;
//    NSLog(@"%@", [[NSString alloc] initWithData:self.bodyIn encoding:NSUTF8StringEncoding]);
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:self.bodyIn options:0 error:nil];
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

- (void)parseHeaderToSerializer:(MKXmlSerializer *)xmlSerializer {

}

- (void)parseBodyToSerializer:(MKXmlSerializer *)xmlSerializer {

}

- (void)writeToSerializer:(MKXmlSerializer *)xmlSerializer {
    [xmlSerializer.willSendSoapString appendString:@"<v:Envelope"]; //
    xmlSerializer.setPrefix(@"i", self.xsi);
    xmlSerializer.setPrefix(@"d", self.xsd);
    xmlSerializer.setPrefix(@"c", self.enc);
    xmlSerializer.setPrefix(@"v", self.env);
    [xmlSerializer.willSendSoapString appendString:@">"]; //
//    xmlSerializer.startTag(self.env, @"Envelope");
//    xmlSerializer.startTag(@"v", @"Envelope");
    xmlSerializer.startTag(@"v", @"Header");
    [self writeHeaderToSerializer:xmlSerializer];
//    xmlSerializer.endTag(@"v", @"Header");
    xmlSerializer.startTag(@"v", @"Body");
    [self writeBodyToSerializer:xmlSerializer];
    xmlSerializer.endTag(@"v", @"Body");
    xmlSerializer.endTag(@"v", @"Envelope");
}

- (void)writeHeaderToSerializer:(MKXmlSerializer *)xmlSerializer {
    if (self.headerOut) {
        for (int i = 0; i < self.headerOut.count; i++) {
            // 如何组装HeaderOut
//            [xmlSerializer appendString:];
        }
    }
}

- (void)writeBodyToSerializer:(MKXmlSerializer *)xmlSerializer {
    // 将bodyOut 也就是SoapObject转为xml字符串
    MKSoapObject *soapObject = (MKSoapObject *)self.bodyOut;
    [xmlSerializer appendString:[NSString stringWithFormat:@"<n0:%@ xmlns:n0=\"http://impl.services.v3x.seeyon.com\">", soapObject.methodName]];
    for (NSUInteger i = 0; i < soapObject.parameterCount; i++) {
        NSString *paraValue = [soapObject parameterValueAtIndex:i];
        NSString *paraKey = [soapObject parameterKeyAtIndex:i];
        [xmlSerializer appendString:[NSString stringWithFormat:@"<%@>%@</%@>", paraKey, paraValue, paraKey]];
    }
    [xmlSerializer appendString:[NSString stringWithFormat:@"</n0:%@>", soapObject.methodName]];
}

@end
