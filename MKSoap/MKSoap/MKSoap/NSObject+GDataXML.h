//
//  NSObject+GDataXML.h
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface NSObject (GDataXML)

- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass;
- (void)setValuesWithGDataElement:(GDataXMLElement *)element aClass:(Class)aClass inCDATA:(BOOL)inCDATA;

@end
