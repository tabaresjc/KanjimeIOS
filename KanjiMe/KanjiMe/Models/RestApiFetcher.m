//
//  RestApiFetcher.m
//  KanjiMe
//
//  Created by Lion User on 8/11/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "RestApiFetcher.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFJSONRequestOperation.h>


static NSUInteger const ClientDefaultMaxConcurrentOperationCount = 4;

@interface RestApiFetcher()
@property (nonatomic, strong) NSURL *urlEndpoint;
@property (nonatomic, strong) NSMutableDictionary *defaultHeaders;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation RestApiFetcher

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.urlEndpoint = [NSURL URLWithString:API_ENDPOINT_URL];
    self.operationQueue = [[NSOperationQueue alloc] init];
	[self.operationQueue setMaxConcurrentOperationCount:ClientDefaultMaxConcurrentOperationCount];
    return self;
}

- (void)getNames:(NSUInteger)count
   startingPoint:(NSUInteger)offset
         success:(void (^)(id jsonData))success
         failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%d",count], @"limit",
                                       [NSString stringWithFormat:@"%d",offset], @"offset",
                                       nil];
    
    [self callMethod:@"collections.json"
          parameters:requestParameters
      withHttpMethod:GET
             success:^(AFHTTPRequestOperation *operation, id jsonObject) {
                 if(success){                     
                     //NSMutableDictionary *names = [NSMutableDictionary dictionaryWithDictionary:[jsonObject valueForKeyPath:@"apiresponse.data"]];
                     //NSDictionary *meta = [jsonObject valueForKeyPath:@"meta"];                     
                     success(jsonObject);
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 //NSLog(@"Error Data New Format: %@",error);
                 if(failure){
                     failure(error);
                 }
             }
     ];
}

- (void)createOrder:(NSDictionary *)requestData
            success:(void (^)(id jsonData))success
            failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestParameters = nil;
    NSURLRequest *request = [self getUrlRequestForApiWithData:@"orders.json"
                                               withHttpMethod:POST
                                           withDataDictionary:requestData
                                                   parameters:requestParameters];
    
    [self callMethodWithUrlRequest:request
                           success:^(AFHTTPRequestOperation *operation, id jsonObject) {
                               if(success){
                                   success(jsonObject);
                               }
                           }
                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if(failure){
                                   failure(error);
                               }
                           }];
}

#pragma mark - Managing HTTP Header Values
- (NSMutableURLRequest *)getUrlRequestForApi:(NSString *)method
                            withHttpMethod:(HttpMethods)httpMethod
                                parameters:(NSDictionary *)parameters {
    NSString *p = nil;
    NSString *urlRequest = [NSString stringWithFormat:@"%@%@",[self.urlEndpoint description],method];
    
    if (parameters) {
        for (id key in parameters) {
            if(!p){
                p = [NSString stringWithFormat:@"?%@=%@",key,[parameters objectForKey:key]];
            }else{
                p = [NSString stringWithFormat:@"%@&%@=%@",p,key,[parameters objectForKey:key]];
            }
        }
        urlRequest = [NSString stringWithFormat:@"%@%@",urlRequest,p];
    }
    
    NSString *authorizationString = [NSString stringWithFormat:@"KMW_AUTH username=%@&account_sid=%@",API_ACCOUNT_USERNAME,API_ACCOUNT_SID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:[self getHttpMethod:httpMethod]];
    [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    
    return request;
}

- (NSMutableURLRequest *)getUrlRequestForApiWithData:(NSString *)method
                                      withHttpMethod:(HttpMethods)httpMethod
                                  withDataDictionary:(NSDictionary *)httpData
                                          parameters:(NSDictionary *)parameters {
    NSString *p = nil;
    NSError *error;
    NSString *urlRequest = [NSString stringWithFormat:@"%@%@",[self.urlEndpoint description],method];
    
    if (parameters) {
        for (id key in parameters) {
            if(!p){
                p = [NSString stringWithFormat:@"?%@=%@",key,[parameters objectForKey:key]];
            }else{
                p = [NSString stringWithFormat:@"%@&%@=%@",p,key,[parameters objectForKey:key]];
            }
        }
        urlRequest = [NSString stringWithFormat:@"%@%@",urlRequest,p];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:httpData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *authorizationString = [NSString stringWithFormat:@"KMW_AUTH username=%@&account_sid=%@",API_ACCOUNT_USERNAME,API_ACCOUNT_SID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:[self getHttpMethod:httpMethod]];
    [request setValue:authorizationString forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: jsonData];
    
    return request;
}

- (NSString *)getHttpMethod:(HttpMethods)httpMethod
{
    switch (httpMethod) {
        case POST:
            return @"POST";
        case PUT:
            return @"PUT";
        case DELETE:
            return @"DELETE";
        case HEADER:
            return @"HEADER";
        case GET:
        default:
            return @"GET";
    }
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
	[self.defaultHeaders setValue:value forKey:header];
}


#pragma mark - Making Api Request Requests
- (void)callMethod:(NSString *)method
        parameters:(NSDictionary *)parameters
    withHttpMethod:(HttpMethods)httpMethod
           success:(void (^)(AFHTTPRequestOperation *operation, id jsonObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self getUrlRequestForApi:method withHttpMethod:httpMethod parameters:parameters];
    AFJSONRequestOperation *operation = [self HttpRequestOperationForJson:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

- (void)callMethodWithUrlRequest:(NSURLRequest *)request
                         success:(void (^)(AFHTTPRequestOperation *operation, id jsonObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFJSONRequestOperation *operation = [self HttpRequestOperationForJson:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
}

#pragma mark - Creating HTTP Operations

- (AFJSONRequestOperation *)HttpRequestOperationForJson:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, id jsonObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFJSONRequestOperation *operationWithJson = [[AFJSONRequestOperation alloc]initWithRequest:request];
    
    void (^apiCallSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSError *err = nil;
            
            NSString *status = [responseObject valueForKeyPath:@"meta.status"];
            
            if(status){
                if([status isEqualToString:@"error"]){                    
                    NSString *description = NSLocalizedString([responseObject valueForKeyPath:@"meta.feedback.message"], @"");
                    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description };
                    err = [[NSError alloc] initWithDomain:@"REST_API_FETCHER" code:REST_API_ERROR userInfo:errorDictionary];
                }
            } else {
                NSString *description = NSLocalizedString(@"unable to parse the response", @"");
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : description };
                err = [[NSError alloc] initWithDomain:@"REST_API_FETCHER" code:REST_API_ERROR userInfo:errorDictionary];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (err) {
                    if (failure) {
                        failure(operation, err);
                    }
                } else {
                    if (success) {
                        AFJSONRequestOperation *getCurrentOperator = (AFJSONRequestOperation *)operation;
                        success(operation, getCurrentOperator.responseJSON);
                    }
                }
            });
        });
    };
    
    void (^apiCallFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    };
    
    [operationWithJson setCompletionBlockWithSuccess:apiCallSuccess failure:apiCallFailure];
    return operationWithJson;
}


@end
