//
//  MKXmlSerializer.m
//  TJRailway
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKXmlSerializer.h"
#import "MKSoapObject.h"

@interface MKXmlSerializer ()

//@property (nonatomic, strong) NSMutableArray *outHeaderArray;

@property (nonatomic, copy) NSMutableString *cacheString;
@property (nonatomic, strong) NSMutableDictionary *cachePrefixDictionary;
@property (nonatomic, strong) NSMutableArray *cacheTagStack;
@property (nonatomic, copy) NSMutableString *cacheContentString;

@end

@implementation MKXmlSerializer

- (instancetype)init {
    if (self = [super init]) {
//        _outHeaderArray = @[].mutableCopy;
        
        _cacheString = @"".mutableCopy;
        _cacheTagStack = @[].mutableCopy;
    }
    return self;
}

- (MKXmlSerializer *(^)(NSString *prefix, NSString *url))setPrefix {
    return ^MKXmlSerializer *(NSString *prefix, NSString *url){
        if (!_cachePrefixDictionary) {
            _cachePrefixDictionary = [NSMutableDictionary dictionary];
        }
        [_cachePrefixDictionary setObject:url forKey:prefix];
        return self;
    };
}

- (MKXmlSerializer *(^)(NSString *nameSpaceURL, NSString *tagName))startTag {
    return ^MKXmlSerializer *(NSString *nameSpaceURL, NSString *tagName){
        NSArray *prefixes = [self.cachePrefixDictionary allKeysForObject:nameSpaceURL];
        NSString *tag = prefixes.count ? [NSString stringWithFormat:@"%@:%@", prefixes.firstObject, tagName] : tagName;
        [self.cacheTagStack addObject: tag];
        return self;
    };
}

- (MKXmlSerializer *(^)(NSString *nameSpaceURL, NSString *tagName))endTag {
    return ^MKXmlSerializer *(NSString *nameSpaceURL, NSString *tagName){
        NSArray *prefixes = [self.cachePrefixDictionary allKeysForObject:nameSpaceURL];
        NSString *cacheTag = [self.cacheTagStack lastObject];
        if (prefixes.count && [[NSString stringWithFormat:@"%@:%@", prefixes.firstObject, tagName] isEqualToString:cacheTag]) {
            [self contactContentWithTag:cacheTag];
        } else if ([tagName isEqualToString:cacheTag]) {
            [self contactContentWithTag:tagName];
        }
        self.cacheContentString = nil;
        return self;
    };
}

- (void)contactContentWithTag:(NSString *)tag {
    if (!tag.length) {
        return;
    }
    
    NSMutableString *string = [NSMutableString string];
    if ([self.cacheTagStack.lastObject isEqualToString:tag]) {
        [self.cacheTagStack removeLastObject];
    }
    [string appendFormat:@"<%@", tag];
    if ([tag rangeOfString:@"Envelope"].location != NSNotFound) {
        if (self.cachePrefixDictionary) {
            for (NSString *prefix in self.cachePrefixDictionary.allKeys) {
                [string appendFormat:@" xmlns:%@=\"%@\"", prefix, self.cachePrefixDictionary[prefix]];
            }
        }
        _cacheString = [NSMutableString stringWithFormat:@"%@>%@", string, self.cacheString];
        [_cacheString appendFormat:@"</%@>", tag];
        return;
    }
    if (!self.cacheContentString.length) {
        [string appendString:@" />"];
        return;
    }
    [string appendString:@">"];
    [string appendString:self.cacheContentString];
    [string appendFormat:@"</%@>", tag];
    [self.cacheString appendString:string.copy];
}

- (MKXmlSerializer *)appendContent:(NSString *)contentString {
    if (!_cacheContentString) {
        _cacheContentString = [NSMutableString string];
    }
    [_cacheContentString appendString:contentString];
    return self;
}

- (NSData *)willSendSoapStringData {
    return [self.cacheString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)absorb:(id)obj {
//    if ([obj isKindOfClass:[MKSoapObject class]]) {
//        self.soapObject = obj;
//    }
}

@end
