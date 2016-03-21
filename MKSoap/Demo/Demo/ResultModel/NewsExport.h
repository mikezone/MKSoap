//
//  NewsExport.h
//  Demo
//
//  Created by Mike on 16/3/21.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersonExport;
@class NewsTypeExport;
@class TextHtmlExport;

@interface NewsExport : NSObject

/*
 createTime
 creater 是一个PersonExport类
 newsType 是一个NewsTypeExport类
 flowContent_html 是一个TextHtmlExport类
 id 整型
 title 字符串
 clickNum 整型
 linkURL 字符串
 attachments
 */

@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, strong) PersonExport *creater;
@property (nonatomic, strong) NewsTypeExport *newsType;
@property (nonatomic, strong) TextHtmlExport *flowContent_html;
@property (nonatomic, assign) unsigned long long newsId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger clickNum;
@property (nonatomic, copy) NSString *linkURL;
@property (nonatomic, strong) NSArray *attachments;

@end
