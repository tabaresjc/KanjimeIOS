//
//  UtilHelper.m
//  KanjiMe
//
//  Created by Lion User on 10/3/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "UtilHelper.h"

@implementation UtilHelper
+(BOOL)isVersion6AndBelow {
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}
@end
