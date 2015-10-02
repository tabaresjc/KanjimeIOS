//
//  Order+Rest.h
//  KanjiMe
//
//  Created by Lion User on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Order.h"

@interface Order (Rest)

typedef enum orderSteps
{
    ORDERSTART,
    ORDER_API_COMLETED,
    ORDER_CONFIRMATION,
    ORDER_ERROR
} OrderSteps;

- (NSDictionary *)getHttpDataForCreation;

@end
