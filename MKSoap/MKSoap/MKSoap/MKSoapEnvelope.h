//
//  MKSoapEnvelope.h
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSUInteger const VER10;
FOUNDATION_EXPORT NSUInteger const VER11;
FOUNDATION_EXPORT NSUInteger const VER12;
FOUNDATION_EXPORT NSString *const ENV2001;
FOUNDATION_EXPORT NSString *const ENC2001;
FOUNDATION_EXPORT NSString *const ENV;
FOUNDATION_EXPORT NSString *const ENC;
FOUNDATION_EXPORT NSString *const XSD;
FOUNDATION_EXPORT NSString *const XSI;
FOUNDATION_EXPORT NSString *const XSD1999;
FOUNDATION_EXPORT NSString *const XSI1999;

@class MKXmlSerializer;
@class GDataXMLElement;

@interface MKSoapEnvelope : NSObject

@property (nonatomic, strong) id bodyIn; // NSMutableDictionary/NSString/Model
@property (nonatomic, strong) id bodyOut; // MKSoapObject
@property (nonatomic, copy) GDataXMLElement *returnValuePart;
@property (nonatomic, strong) NSArray *headerIn;
@property (nonatomic, strong) NSArray *headerOut;
@property (nonatomic, copy) NSString *encodingStyle;
/// The SOAP version, set by the constructor
@property (nonatomic, assign) NSUInteger soapVersion;
/// Envelope namespace, set by the constructor
@property (nonatomic, copy) NSString *env;
/// Encoding namespace, set by the constructor
@property (nonatomic, copy) NSString *enc;
/// Xml Schema instance namespace, set by the constructor
@property (nonatomic, copy) NSString *xsi;
/// Xml Schema data namespace, set by the constructor
@property (nonatomic, copy) NSString *xsd;

- (instancetype)initWithSoapVersion:(NSUInteger)soapVersion;
- (void)parseFromSerializer:(MKXmlSerializer *)xmlSerializer;
- (void)parseHeaderFromSerializer:(MKXmlSerializer *)xmlSerializer;
- (void)parseBodyFromSerializer:(MKXmlSerializer *)xmlSerializer;
- (void)writeToSerializer:(MKXmlSerializer *)xmlSerializer;
- (void)writeHeaderToSerializer:(MKXmlSerializer *)xmlSerializer;
- (void)writeBodyToSerializer:(MKXmlSerializer *)xmlSerializer;

@end
