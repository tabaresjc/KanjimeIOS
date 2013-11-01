//
//  RestApiHelpers.m
//  KanjiMe
//
//  Created by Lion User on 8/15/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "RestApiHelpers.h"

@implementation RestApiHelpers
+ (NSString *)getStandardHtmlPage:(NSString *)content
{
    NSString *htmlRaw = @"<!DOCTYPE html>"
    "<html lang=\"en\">"
    "<head>"
    "    <meta charset=\"utf-8\">"
    "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    "    <meta name=\"description\" content=\"\">"
    "    <meta name=\"author\" content=\"\">"
    "    <!-- Le styles -->"
    "    <link href=\"bootstrap/css/bootstrap.css\" type=\"text/css\" rel=\"stylesheet\">"
    "    <link href=\"bootstrap/css/font-awesome.css\" type=\"text/css\" rel=\"stylesheet\">"
    "    <link href=\"resource/css/style.css\" type=\"text/css\" rel=\"stylesheet\">"
    "    <link href=\"bootstrap/css/prettify.css\" rel=\"stylesheet\" type=\"text/css\" >"
    "    <link href=\"resource/wysi/css/bootstrap-wysihtml5.css\" type=\"text/css\" rel=\"stylesheet\">"
    "    <link href=\"bootstrap/css/bootstrap-responsive.min.css\" rel=\"stylesheet\">"
    "    <script type=\"text/javascript\" src=\"bootstrap/js/jquery.js\"></script>"
    "    <script type=\"text/javascript\" src=\"bootstrap/js/bootstrap.js\"></script>"
    "</head>"
    "<body>"
    "<div class=\"container-fluid\">"
    "<div class=\"row-fluid\">"
    "<div class=\"span12\">"
    "%@"
    "<script type=\"text/javascript\" src=\"resource/wysi/js/wysihtml5-0.3.0.js\"></script>"
    "<script type=\"text/javascript\" src=\"resource/wysi/js/prettify.js\"></script>"
    "<script type=\"text/javascript\" src=\"resource/wysi/js/bootstrap-wysihtml5.js\"></script>"
    "<script>"
    "    $('.textarea').wysihtml5();"
    "</script>"
    "</body>"
    "</html>";
    return [NSString stringWithFormat:htmlRaw, content];
}

+ (NSString *)getHtmlArticle:(NSString *)rawJson
                   withTitle:(NSString *)title
                withSubtitle:(NSString *)subTitle
             withDescription:(NSString *)description
{
    
    NSString *htmlRaw = [NSString stringWithFormat:@"<h2>Name: %@</h2><h4>Kanji: %@</h4><h4>Katakana: %@</h4><br/>",
                         title,subTitle,description];
    NSDictionary *data = [RestApiHelpers getDataFromJson:rawJson];
    
    if(data){
        NSDictionary *dataList = [data valueForKeyPath:@"kanjiList"];
        for(id value in dataList){
            NSString *kunYomiString = [RestApiHelpers splitListToHtmlLines:[RestApiHelpers formatFields:[value valueForKey:@"kunyomi"]]];
            NSString *onYomiString = [RestApiHelpers splitListToHtmlLines:[RestApiHelpers formatFields:[value valueForKey:@"onyomi"]]];
            NSString *meaning = [RestApiHelpers formatFields:[value valueForKey:@"meaning"]];
            
            NSString *singleItemHtml = [NSString stringWithFormat:@""
                                        "<table class=\"table table-bordered table-condensed single_kanji\">"
                                        "   <tr class=\"label label-inverse\">"
                                        "       <td colspan=\"2\"><h3>%@</h3></td>"
                                        "   </tr>"
                                        "   <tr>"
                                        "       <td style=\"width:30%%;\"><strong>Kun</strong></td>"
                                        "       <td>%@</td>"
                                        "   </tr>"
                                        "   <tr>"
                                        "       <td><strong>On</strong></td>"
                                        "       <td>%@</td>"
                                        "   </tr>"
                                        "   <tr>"
                                        "       <td><strong>Meaning</strong></td>"
                                        "       <td>%@</td>"
                                        "   </tr>"
                                        "</table>", [value objectForKey:@"kanji"],kunYomiString,onYomiString,meaning];
            htmlRaw = [NSString stringWithFormat:@"%@%@",htmlRaw,singleItemHtml];
        }
    }
    return htmlRaw;
}

+ (NSURL *)getUrlToWebServerFolder
{
    NSURL *baseUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] bundlePath],@"/www/" ]];
    return baseUrl;
}



+ (NSString *)getDateTimeFromString:(NSString *)rawDateString
{
    return [self dateStringFromString:rawDateString
                         sourceFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"
                    destinationFormat:@"EEEE, MMMM d, yyyy h:mm a"];
}

+ (NSString *)dateStringFromString:(NSString *)sourceString
                      sourceFormat:(NSString *)sourceFormat
                 destinationFormat:(NSString *)destinationFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:sourceFormat];
    NSDate *date = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat:destinationFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromServer:(NSString *)sourceString withFormat:(NSDateFormatter *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:sourceString];
    return date;
}

+ (NSString *)getFormattedHtml:(NSString *)rawHtmlString
{
    return [NSString stringWithFormat:@"%@%@%@",
            @"<div styke='width:80%'>",
            rawHtmlString,
            @"</div>"];
}

+ (NSDictionary *)getDataFromJson:(NSString *)jsonString
{
    NSError *e = [[NSError alloc] init];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&e];
    return data;
}

+ (NSString *)formatFields: (NSString *)content
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*(.*?)\\*" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, [content length]) withTemplate:@"<strong>$1</strong>"];
    return modifiedString;
}

+ (NSString *)splitListToHtmlLines: (NSString *)content
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(, )" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, [content length]) withTemplate:@"<br/>"];
    return modifiedString;
}

+ (void)setAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

+ (NSString *)getStringFromNSdata:(NSData *)data
{
    NSUInteger dataLength = [data length];
    NSMutableString *dataString = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [data bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [dataString appendFormat:@"%02x", dataBytes[idx]];
    }
    return dataString;
}

@end
