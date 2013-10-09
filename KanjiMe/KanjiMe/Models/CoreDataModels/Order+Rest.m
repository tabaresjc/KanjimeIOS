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
    NSMutableDictionary *dataOrder = [[NSMutableDictionary alloc] init];
    [dataOrder setValue:self.name forKey:@"name"];
    [dataOrder setValue:self.email forKey:@"email"];
    [dataOrder setValue:textComments forKey:@"comments"];
    [dataOrder setValue:self.payment_kind forKey:@"payment_kind"];
    [dataOrder setValue:self.payment_key forKey:@"payment_key"];
    [dataOrder setValue:self.payment_status forKey:@"payment_status"];
    [dataOrder setValue:self.payment_description forKey:@"payment_description"];
    [dataOrder setValue:self.payment_amount forKey:@"payment_amount"];
    [dataOrder setValue:self.payment_currency forKey:@"payment_currency"];
    [dataOrder setValue:self.payment_env forKey:@"name"];
    NSDictionary *httpDataOrder = [NSDictionary dictionaryWithObjectsAndKeys:dataOrder,@"Order", nil];
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
