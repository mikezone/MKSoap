//
//  MKSoapSerializationEnvelope.h
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSoapEnvelope.h"

@interface MKSoapSerializationEnvelope : MKSoapEnvelope

+ (instancetype)soapSerializationEnvelopeWithSoapVersion:(NSUInteger)soapVersion;

@end
