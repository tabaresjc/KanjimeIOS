//
//  Order+Rest.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Order+Rest.h"

@implementation Order (Rest)

+ (Order *)buildOrderFromParameters:(NSString *)name
                          withEmail:(NSString *)email
                         withTattoo:(NSString *)tattoo
                       withComments:(NSString *)comments
                    withPaymentInfo:(NSDictionary *)paypalPaymentInfo
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    Order *order = [NSEntityDescription insertNewObjectForEntityForName:@"Order"
                                               inManagedObjectContext:context];
    
    order.name = name;
    order.email = email;
    order.tattoo = tattoo;
    order.comments = comments;
    
    if([paypalPaymentInfo valueForKeyPath:@"proof_of_payment.adaptive_payment"]){
        order.payment_kind = @"PAYPAL";
        order.payment_key = [paypalPaymentInfo valueForKeyPath:@"proof_of_payment.adaptive_payment.pay_key"];
        order.payment_status = [paypalPaymentInfo valueForKeyPath:@"proof_of_payment.adaptive_payment.payment_exec_status"];
    } else {
        order.payment_kind = @"CREDIT_CARD";
        order.payment_key = [paypalPaymentInfo valueForKeyPath:@"proof_of_payment.rest_api.payment_id"];
        order.payment_status = [paypalPaymentInfo valueForKeyPath:@"proof_of_payment.rest_api.state"];
    }
    order.payment_description = [paypalPaymentInfo valueForKeyPath:@"payment.short_description"];
    order.payment_amount = [NSDecimalNumber decimalNumberWithString:[paypalPaymentInfo valueForKeyPath:@"payment.amount"]];
    order.payment_currency = [paypalPaymentInfo valueForKeyPath:@"payment.currency_code"];
    order.payment_env = [paypalPaymentInfo valueForKeyPath:@"client.environment"];
    order.is_sent = false;
    order.option = 0;
    return order;
}

- (NSDictionary *)getHttpDataForCreation
{
    NSString *textComments = [NSString stringWithFormat:@"Tattoo:%@|Comments:%@|Option:%@",self.tattoo,self.comments,self.option];
    NSDictionary *httpDataOrder = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.name, @"name",
                                   self.email, @"email",
                                   self.comments, textComments,
                                   self.payment_kind, @"payment_kind",
                                   self.payment_key, @"payment_key",
                                   self.payment_status, @"payment_status",
                                   self.payment_description, @"payment_description",
                                   self.payment_amount, @"payment_amount",
                                   self.payment_currency, @"payment_currency",
                                   self.payment_env, @"payment_env",
                                   nil];
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
