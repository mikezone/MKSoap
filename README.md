# MKSoap
easily send SOAP to server and parse response automatically

## Usage

1.create a soapObject. it contains a `mappingClass` property , MKSoap will parse response depend on `mappingClass`.
```objectivec
MKSoapObject *soapObject = [MKSoapObject soapObjectWithNameSpace:@"http://impl.services.v3x.seeyon.com" methodName:@"authenticate"];
soapObject.addParameter(@"userName", @"service-admin").addParameter(@"password", @"123456");
soapObject.mappingClass = [AuthResult class];
```
2.send soap and receive a responseObject. This responseObject is an instance of `mappingClass`.
```objectivec
MKSoapTransportManager *manager = [MKSoapTransportManager manager];
[manager service:@"http://oa.tjtdxy.cn:8080/seeyon/services/authorityService?wsdl" soapObject:soapObject success:^(id obj) {
    NSLog(@"%@", obj);
    AuthResult *res = obj;
    NSLog(@"%@", res.userToken);
} failure:^(NSError *error) {
    NSLog(@"%@", [error localizedDescription]);
}];
```
 
