//
//  CoreDataHandler.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/9/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CoreDataHandler.h"
#import <CoreData/CoreData.h>
#import "Collection+Rest.h"
#import "Order+Rest.h"

#define NAME_TITLE @"Collection.title"
#define NAME_SUBTITLE @"Collection.subtitle"
#define NAME_DESCRIPTION @"Collection.description"
#define NAME_BODY @"Collection.body"
#define NAME_CREATED @"Collection.created"
#define NAME_MODIFIED @"Collection.modified"
#define NAME_ID @"Collection.id"

@interface CoreDataHandler()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSURL *url;
@end

@implementation CoreDataHandler
@synthesize managedObjectContext;
@synthesize url;
@synthesize isOpen;

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.isOpen = NO;
    return self;
}

- (void)useDocumentWithName:(NSString *)name completionHandler:(void (^)(BOOL success))completionHandler
{
    url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                  inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MainDocument"];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
              self.isOpen = success;
              if(completionHandler){
                  completionHandler(success);
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
            self.isOpen = success;
            if(completionHandler){
                completionHandler(success);
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        self.isOpen = YES;
        if(completionHandler){
            completionHandler(YES);
        }
    }
}

- (id)getListOfCollection
{
    NSFetchedResultsController *dataList = nil;
    
    if(self.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil;
        dataList = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:managedObjectContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
    }
    return dataList;
}

- (id)getCollectionListByName:(NSString *)searchText
{
    NSFetchedResultsController *dataList = nil;
    
    if(self.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchText];
        [request setPredicate:predicate];
        
        dataList = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:self.managedObjectContext
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    }
    return dataList;
}

- (id)getCollectionListByFavorite
{
    NSFetchedResultsController *dataList = nil;
    
    if(self.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite = TRUE"];
        [request setPredicate:predicate];
        dataList = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:managedObjectContext
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    }
    return dataList;

}

- (id)getCollectionFromDictionary:(NSDictionary *)collectionDictionary {
    Collection *collection = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@",
                         [collectionDictionary valueForKeyPath:NAME_ID]];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request
                                              error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                   inManagedObjectContext:self.managedObjectContext];
        collection.collectionId = [collectionDictionary valueForKeyPath:NAME_ID];
        collection.title = [collectionDictionary valueForKeyPath:NAME_TITLE];
        collection.subtitle = [collectionDictionary valueForKeyPath:NAME_SUBTITLE];
        collection.extraTitle = [collectionDictionary valueForKeyPath:NAME_DESCRIPTION];
        collection.body = [collectionDictionary valueForKeyPath:NAME_BODY];
        collection.created = [collectionDictionary valueForKeyPath:NAME_CREATED];
        collection.modified = [collectionDictionary valueForKeyPath:NAME_MODIFIED];
        
    } else {
        collection = [matches lastObject];
    }
    return collection;
}

- (id)getOrderFromParameters:(NSString *)name
                          withEmail:(NSString *)email
                         withTattoo:(NSString *)tattoo
                       withComments:(NSString *)comments
                    withPaymentInfo:(NSDictionary *)paypalPaymentInfo
{
    Order *order = [NSEntityDescription insertNewObjectForEntityForName:@"Order"
                                                 inManagedObjectContext:self.managedObjectContext];
    
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


@end
