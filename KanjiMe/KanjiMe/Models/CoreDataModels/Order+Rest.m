//
//  Order+Rest.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Order+Rest.h"

@implementation Order (Rest)

- (NSDictionary *)getHttpDataForCreation
{
    NSString *textComments = [NSString stringWithFormat:@"Tattoo:%@|Comments:%@|Option:%@",self.tattoo,self.comments,self.option];
    NSMutableDictionary *httpDataOrder = [[NSMutableDictionary alloc] init];
    [httpDataOrder setValue:self.name forKeyPath:@"Order.name"];
    [httpDataOrder setValue:self.email forKeyPath:@"Order.email"];
    [httpDataOrder setValue:textComments forKeyPath:@"Order.comments"];
    [httpDataOrder setValue:self.payment_kind forKeyPath:@"Order.payment_kind"];
    [httpDataOrder setValue:self.payment_key forKeyPath:@"Order.payment_key"];
    [httpDataOrder setValue:self.payment_status forKeyPath:@"Order.payment_status"];
    [httpDataOrder setValue:self.payment_description forKeyPath:@"Order.payment_description"];
    [httpDataOrder setValue:self.payment_amount forKeyPath:@"Order.payment_amount"];
    [httpDataOrder setValue:self.payment_currency forKeyPath:@"Order.payment_currency"];
    [httpDataOrder setValue:self.payment_env forKeyPath:@"Order.name"];
//    NSDictionary *httpDataOrder = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   self.name, @"name",
//                                   self.email, @"email",
//                                   self.comments, textComments,
//                                   self.payment_kind, @"payment_kind",
//                                   self.payment_key, @"payment_key",
//                                   self.payment_status, @"payment_status",
//                                   self.payment_description, @"payment_description",
//                                   self.payment_amount, @"payment_amount",
//                                   self.payment_currency, @"payment_currency",
//                                   self.payment_env, @"payment_env",
//                                   nil];
    
    
    return httpDataOrder;
}

- (NSDecimal *)convertToDecimal:(NSString *)rawstring
{
    NSScanner *aScanner = [NSScanner localizedScannerWithString:rawstring];
    NSDecimal *convertedValue = NULL;
    
    if (![aScanner scanDecimal:convertedValue]) {
        convertedValue = (__bridge NSDecimal *)([NSDecimalNumber zero]);
    }
    return convertedValue;
}


@end
