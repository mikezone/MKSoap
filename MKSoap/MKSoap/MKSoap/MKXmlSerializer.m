//
//  MKXmlSerializer.m
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKXmlSerializer.h"

@implementation MKXmlSerializer

- (instancetype)init {
    if (self = [super init]) {
        _willSendSoapString = @"".mutableCopy;
//        _willReturnModel = @{}.mutableCopy;
    }
    return self;
}

- (MKXmlSerializer *(^)(NSString *prefix, NSString *url))setPrefix {
    return ^MKXmlSerializer *(NSString *prefix, NSString *url){
        [self.willSendSoapString appendFormat:@" xmlns:%@=\"%@\"", prefix, url];
        return self;
    };
}

- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))startTag {
    return ^MKXmlSerializer *(NSString *nameSpace, NSString *tagName){
        if ([tagName isEqualToString:@"Header"]) {
            [self.willSendSoapString appendFormat:@"<%@:%@ />", nameSpace, tagName];
        } else {
            [self.willSendSoapString appendFormat:@"<%@:%@>", nameSpace, tagName];
        }
        return self;
    };
}

- (MKXmlSerializer *(^)(NSString *nameSpace, NSString *tagName))endTag {
    return ^MKXmlSerializer *(NSString *nameSpace, NSString *tagName){
        [self.willSendSoapString appendFormat:@"</%@:%@>", nameSpace, tagName];
        return self;
    };
}

- (MKXmlSerializer *)appendString:(NSString *)aString {
    [self.willSendSoapString appendString:aString];
    return self;
}


@end
