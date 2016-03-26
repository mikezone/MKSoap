//
//  MKSoapTransportManager.m
//  mikezone
//
//  Created by Mike on 16/3/19.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "MKSoapTransportManager.h"
#import "MKSoapSerializationEnvelope.h"
#import "AFNetworking.h"
#import "MKXmlSerializer.h"
#import "GDataXMLNode.h"

@interface MKSoapTransportManager ()

@property (nonatomic, strong) AFHTTPSessionManager *afHTTPManager;

@end

@implementation MKSoapTransportManager


+ (instancetype)manager {
    return [[self alloc] initWithAFHTTPSessionManager:nil];
}

- (instancetype)initWithAFHTTPSessionManager:(AFHTTPSessionManager *)afHTTPManager {
    if (self = [super init]) {
        if (afHTTPManager) {
            self.afHTTPManager = afHTTPManager;
        } else {
            AFHTTPSessionManager *afHTTPManager = [AFHTTPSessionManager manager];
            afHTTPManager.requestSerializer.timeoutInterval = 20;
            afHTTPManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
            [afHTTPManager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            self.afHTTPManager = afHTTPManager;
        }
    }
    return self;
}

- (NSURLSessionDataTask *)service:(NSString *)serviceURLString soapObject:(MKSoapObject *)soapObject success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    MKSoapSerializationEnvelope *soapSerializationEnvelope = [MKSoapSerializationEnvelope soapSerializationEnvelopeWithSoapVersion:VER11];
    soapSerializationEnvelope.bodyOut = soapObject;
    
    MKXmlSerializer *xmlSerializer = [[MKXmlSerializer alloc] init];
    [soapSerializationEnvelope writeToSerializer:xmlSerializer];
    
    NSData *soapMsgData = xmlSerializer.willSendSoapStringData.copy;
//    NSLog(@"%@", [[NSString alloc] initWithData:soapMsgData encoding:NSUTF8StringEncoding]);
    NSString *msgLength = [NSString stringWithFormat:@"%tu", soapMsgData.length];
    [self.afHTTPManager.requestSerializer setValue:msgLength forHTTPHeaderField:@"Content-Length"];
    if (soapObject.SOAPAction.length) {
        [self.afHTTPManager.requestSerializer setValue:soapObject.SOAPAction forHTTPHeaderField:@"SOAPAction"];
    }
    NSURLSessionDataTask *dataTask =
    [self dataTaskWithHTTPMethod:@"POST" URLString:serviceURLString soapStringData:soapMsgData success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        if (success) {
            // 先交给envelope解析出结果， 再进行成功的回调
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                xmlSerializer.returnedXMLStringData = responseObject;
                [soapSerializationEnvelope parseFromSerializer:xmlSerializer];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    success(soapSerializationEnvelope.bodyIn);
                });
            });
        }
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      soapStringData:(NSData *)soapStringData
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.afHTTPManager.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.afHTTPManager.baseURL] absoluteString] parameters:nil error:&serializationError];
    request.HTTPBody = soapStringData;
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.afHTTPManager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.afHTTPManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}

@end
