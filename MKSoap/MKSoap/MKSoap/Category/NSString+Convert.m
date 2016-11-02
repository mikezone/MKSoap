//
//  NSString+Convert.m
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

- (NSNumber *)numberValue {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:self];
}

- (NSInteger)integerValue {
    NSNumber *number = [self numberValue];
    return [number integerValue];
}

- (NSUInteger)unsignedIntegerValue {
    NSNumber *number = [self numberValue];
    return [number unsignedIntegerValue];
}

// change

@end
