//
//  Order+Rest.h
//  KanjiMe
//
//  Created by Juan Tabares on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Order.h"

@interface Order (Rest)

typedef enum orderSteps
{
    ORDERSTART,
    ORDER_API_COMLETED,
    ORDER_API_CANCELED,
    ORDER_CONFIRMATION
} OrderSteps;


+ (Order *)buildOrderFromParameters:(NSString *)name
                          withEmail:(NSString *)email
                         withTattoo:(NSString *)tattoo
                       withComments:(NSString *)comments
                    withPaymentInfo:(NSDictionary *)paypalPaymentInfo
             inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSDictionary *)getHttpDataForCreation;
@end
