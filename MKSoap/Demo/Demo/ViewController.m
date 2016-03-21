//
//  ViewController.m
//  TJRailway
//
//  Created by Mike on 16/3/18.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "ViewController.h"
#import "MKSoapObject.h"
#import "MKSoapTransportManager.h"
#import "AuthResult.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"namespace" methodName:@"methodone"];
    soapObject.addParameter(@"1", @"v1").addParameter(@"2", @"v2").addParameter(@"3", @"v3");
    
//    NSLog(@"%@", soapObject);
    
}

- (IBAction)getTokenButtonDidClicked:(UIButton *)sender {
    
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.services.v3x.seeyon.com" methodName:@"authenticate"];
    soapObject.addParameter(@"userName", @"service-admin").addParameter(@"password", @"123456");
    soapObject.mappingClass = [NSDictionary class];
//    soapObject.mappingClass = [AuthResult class];
    
    MKSoapTransportManager *manager = [MKSoapTransportManager manager];
    [manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/authorityService?wsdl" soapObject:soapObject success:^(id obj) {
        NSLog(@"%@", obj);
        AuthResult *res = obj;
        NSLog(@"%@", res.userToken);
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (IBAction)getNewsButtonDidClicked:(UIButton *)sender {
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.document.services.v3x.seeyon.com" methodName:@"exportRecentNews"];
    soapObject
    .addParameter(@"token", @"3a102b97-2c28-45a4-8cfb-4df2c49cbde3")
    .addParameter(@"accountId", @"service-admin")
    .addParameter(@"ticket", @"")
    .addParameter(@"firstNum", @"0")
    .addParameter(@"pageSize", @"1");
    
    MKSoapTransportManager *manager = [MKSoapTransportManager manager];
    [manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/documentService?wsdl" soapObject:soapObject success:^(id obj) {
        NSLog(@"%@", [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding]);
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}


@end
