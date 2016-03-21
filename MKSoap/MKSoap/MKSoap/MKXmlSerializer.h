//
//  MKXmlSerializer.h
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKXmlSerializer : NSObject

@property (nonatomic, copy) NSMutableString *willSendSoapString;
@property (nonatomic, strong) id willReturnModel; // NSMutableDictionary/NSString/Model

- (MKXmlSerializer *(^)(NSString *prefix, NSString *url))setPrefix;
- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))startTag;
- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))endTag;

- (MKXmlSerializer *)appendString:(NSString *)aString;
@end
