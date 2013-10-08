//
//  Order.h
//  KanjiMe
//
//  Created by Juan Tabares on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Order : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tattoo;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * payment_key;
@property (nonatomic, retain) NSString * payment_kind;
@property (nonatomic, retain) NSString * payment_status;
@property (nonatomic, retain) NSString * payment_description;
@property (nonatomic, retain) NSDecimalNumber * payment_amount;
@property (nonatomic, retain) NSString * payment_currency;
@property (nonatomic, retain) NSString * payment_env;
@property (nonatomic) BOOL is_sent;
@property (nonatomic, retain) NSNumber * option;

@end
