//
//  RestApiFetcher.h
//  KanjiMe
//
//  Created by Lion User on 8/11/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestApiHelpers.h"
#import "Name.h"

@interface RestApiFetcher : NSObject

#define REST_API_ERROR 1

typedef enum httpMethodsType
{
    GET,
    POST,
    PUT,
    DELETE,
    HEADER
} HttpMethods;


- (void)getNames:(NSUInteger)count
   startingPoint:(NSUInteger)offset
         success:(void (^)(id jsonData))success
         failure:(void (^)(NSError *error))failure;

- (void)createOrder:(NSDictionary *)requestData
            success:(void (^)(id jsonData))success
            failure:(void (^)(NSError *error))failure;
@end
