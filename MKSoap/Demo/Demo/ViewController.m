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
#import "NewsExport.h"
#import "PersonExport.h"
#import "NewsTypeExport.h"
#import "TextHtmlExport.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"namespace" methodName:@"methodone"];
    soapObject.addParameter(@"1", @"v1").addParameter(@"2", @"v2").addParameter(@"3", @"v3");
    
    // Sentence above equals to these
    [soapObject addParameterWithKey:@"1" value:@"v1"];
    [soapObject addParameterWithKey:@"2" value:@"v2"];
    [soapObject addParameterWithKey:@"3" value:@"v3"];
}

- (IBAction)getTokenButtonDidClicked:(UIButton *)sender {
    
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.services.v3x.seeyon.com" methodName:@"authenticate"];
    soapObject.addParameter(@"userName", @"service-admin").addParameter(@"password", @"123456");
//    soapObject.mappingClass = [NSDictionary class];
    soapObject.mappingClass = [AuthResult class];
    
    MKSoapTransportManager *manager = [MKSoapTransportManager manager];
    [manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/authorityService?wsdl" soapObject:soapObject success:^(id obj) {
        NSLog(@"%@", obj);
        AuthResult *res = obj;
        NSLog(@"%@", res.userToken);
        self.token = res.userToken;
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (IBAction)getNewsButtonDidClicked:(UIButton *)sender {
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.document.services.v3x.seeyon.com" methodName:@"exportRecentNews"];
    soapObject
    .addParameter(@"token", self.token)
    .addParameter(@"accountId", @"670869647114347")
    .addParameter(@"ticket", @"test2")
    .addParameter(@"firstNum", @"0")
    .addParameter(@"pageSize", @"2");
    soapObject.mappingClass = [NewsExport class];
    
    MKSoapTransportManager *manager = [MKSoapTransportManager manager];
    [manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/documentService?wsdl" soapObject:soapObject success:^(id obj) {
        NSArray *array = obj;
        for (NewsExport *newsExport in array) {
            NSLog(@"%@", newsExport.createTime);
            NSLog(@"%@", newsExport.creater);
            NSLog(@"%llu", newsExport.creater.personId);
            NSLog(@"%@", newsExport.creater.name);
            NSLog(@"%@", newsExport.newsType);
            NSLog(@"%llu", newsExport.newsType.newsTypeId);
            NSLog(@"%@", newsExport.newsType.newsTypeName);
            NSLog(@"%@", newsExport.flowContent_html);
            NSLog(@"%@", newsExport.flowContent_html.context);
            NSLog(@"%llu", newsExport.newsId);
            NSLog(@"%@", newsExport.title);
            NSLog(@"%zd", newsExport.clickNum);
            NSLog(@"%@", newsExport.linkURL);
            NSLog(@"%@", newsExport.attachments);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (IBAction)getBulletinByAccountId:(UIButton *)sender {
//    exportRecentAccountBulletinByAccountId
    MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.document.services.v3x.seeyon.com" methodName:@"exportRecentAccountBulletinByAccountId"];
    soapObject
    .addParameter(@"token", self.token)
    .addParameter(@"accountId", @"670869647114347")
    .addParameter(@"ticket", @"test2")
    .addParameter(@"firstNum", @"0")
    .addParameter(@"pageSize", @"2");
    
    MKSoapTransportManager *manager = [MKSoapTransportManager manager];
    [manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/documentService?wsdl" soapObject:soapObject success:^(id obj) {
//        NSLog(@"%@", [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding]);
        NSLog(@"%@", obj);
    } failure:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}



@end
