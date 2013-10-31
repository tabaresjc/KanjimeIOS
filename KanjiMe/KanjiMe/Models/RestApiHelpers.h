//
//  RestApiHelpers.h
//  KanjiMe
//
//  Created by Lion User on 8/15/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestApiHelpers : NSObject
+ (NSString *)getStandardHtmlPage:(NSString *)content;
+ (NSString *)getHtmlArticle:(NSString *)rawJson
                   withTitle:(NSString *)title
                withSubtitle:(NSString *)subTitle
             withDescription:(NSString *)description;
+ (NSURL *)getUrlToWebServerFolder;
+ (NSString *)getDateTimeFromString:(NSString *)rawDateString;
+ (NSString *)getFormattedHtml:(NSString *)rawHtmlString;
+ (NSDictionary *)getDataFromJson:(NSString *)jsonString;
+ (NSString *)formatFields: (NSString *)content;
+ (void)setAlertMessage:(NSString *)message withTitle:(NSString *)title;
+ (NSString *)getStringFromNSdata:(NSData *)data;
@end
