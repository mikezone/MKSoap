//
//  MKXmlSerializer.h
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKXmlSerializer : NSObject

@property (nonatomic, strong) NSData *willSendSoapStringData;
@property (nonatomic, strong) NSData *returnedXMLStringData;

- (MKXmlSerializer *(^)(NSString *prefix, NSString *url))setPrefix;
- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))startTag;
- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))endTag;

- (MKXmlSerializer *)appendContent:(NSString *)contentString;
- (void)absorb:(id)obj;

@end
