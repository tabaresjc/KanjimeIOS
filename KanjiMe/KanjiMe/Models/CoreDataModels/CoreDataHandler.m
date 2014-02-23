//
//  CoreDataHandler.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/9/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CoreDataHandler.h"
#import "Collection+Rest.h"
#import "Order+Rest.h"


#define NAME_TITLE @"Collection.title"
#define NAME_SUBTITLE @"Collection.subtitle"
#define NAME_DESCRIPTION @"Collection.description"
#define NAME_BODY @"Collection.body"
#define NAME_CREATED @"Collection.created"
#define NAME_MODIFIED @"Collection.modified"
#define NAME_ID @"Collection.id"
#define NAME_URL @"Collection.url_video"
#define NAME_HASH @"Collection.hash"

@interface CoreDataHandler()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation CoreDataHandler

@synthesize isOpen;
@synthesize currentCollection;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize deviceToken;
@synthesize receivedNotification;
@synthesize remoteNotificationUserInfo;
@synthesize startingPoint;
@synthesize dateFormatter;

-(id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.isOpen = NO;
    [self removeOldVersionSqlLite];
    self.startingPoint = -1;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return self;
}

- (NSManagedObjectContext *) managedObjectContext {
    if (!_managedObjectContext) {
        if (self.persistentStoreCoordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if(!_persistentStoreCoordinator){
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"KanjiMeV3.sqlite"]];
        NSError *error = nil;
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:storeUrl
                                                            options:nil
                                                              error:&error]) {
        }
    }
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (void)startDocument:(void (^)(BOOL success))completionHandler
{
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"KanjiMeV3.sqlite"]];
    NSError *error = nil;
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeUrl
                                                        options:nil
                                                          error:&error]) {
    }
    self.isOpen = YES;
    if(completionHandler){
        completionHandler(YES);
    }
}


- (void)removeOldVersionSqlLite
{
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"KanjiMeV2.sqlite"]];
    [self removeFileAtUrl:storeUrl];
}

- (void)removeFileAtUrl:(NSURL *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if([fileManager removeItemAtURL:fileName error:&error]){
        NSLog(@"File removed, %@",fileName);
    }
}

- (void)saveDocument
{
    if (self.managedObjectContext!=nil && self.managedObjectContext.hasChanges) {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
                                                                       managedObjectContext:self.managedObjectContext
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
                                                   managedObjectContext:self.managedObjectContext
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
    
    if (matches && [matches count] > 0) {
        collection = [matches lastObject];
        if (![collection.hash_value isEqualToString:[collectionDictionary valueForKeyPath:NAME_HASH]]) {
            collection.title = [collectionDictionary valueForKeyPath:NAME_TITLE];
            collection.subtitle = [collectionDictionary valueForKeyPath:NAME_SUBTITLE];
            collection.extraTitle = [collectionDictionary valueForKeyPath:NAME_DESCRIPTION];
            collection.body = [collectionDictionary valueForKeyPath:NAME_BODY];
            collection.created = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%@",[collectionDictionary valueForKeyPath:NAME_CREATED]]];
            
            collection.url_video = [collectionDictionary valueForKeyPath:NAME_URL];
            collection.modified = [collectionDictionary valueForKeyPath:NAME_MODIFIED];
            collection.hash_value = [collectionDictionary valueForKeyPath:NAME_HASH];
        }
    } else {
        collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                   inManagedObjectContext:self.managedObjectContext];
        collection.collectionId = [NSNumber numberWithInteger:[[collectionDictionary valueForKeyPath:NAME_ID] integerValue]];
        collection.title = [collectionDictionary valueForKeyPath:NAME_TITLE];
        collection.subtitle = [collectionDictionary valueForKeyPath:NAME_SUBTITLE];
        collection.extraTitle = [collectionDictionary valueForKeyPath:NAME_DESCRIPTION];
        collection.body = [collectionDictionary valueForKeyPath:NAME_BODY];
        collection.created = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%@",[collectionDictionary valueForKeyPath:NAME_CREATED]]];
        
        collection.url_video = [collectionDictionary valueForKeyPath:NAME_URL];
        collection.modified = [collectionDictionary valueForKeyPath:NAME_MODIFIED];
        collection.favorite = [NSNumber numberWithBool:NO];
        collection.hash_value = [collectionDictionary valueForKeyPath:NAME_HASH];
    }
    return collection;
}

- (id)getCollectionFromId:(NSNumber *)idOfRecord {
    Collection *collection = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@", idOfRecord];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request
                                                                error:&error];
    
    if (!matches || ([matches count] > 1)) {
        collection = nil;
    } else {
        collection = [matches lastObject];
    }
    return collection;
}

- (id)getLastCollection
{
    Collection *collection = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"collectionId"
                                                              ascending:NO]];
    
    [request setPredicate:nil];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request
                                                                error:&error];
    if (!matches || ([matches count] != 1)) {
        collection = nil;
    } else {
        collection = [matches lastObject];
    }
    return collection;
}

- (id)getListOfOrder
{
    NSFetchedResultsController *dataList = nil;
    
    if(self.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created"
                                                                  ascending:NO]];
        request.predicate = nil;
        dataList = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:self.managedObjectContext
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
    }
    return dataList;
}


- (id)getOrderFromParameters:(NSString *)name
                   withEmail:(NSString *)email
                  withTattoo:(NSString *)tattoo
                withComments:(NSString *)comments
           withSelectedImage:(int)selection
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
    order.is_sent = NO;//[NSNumber numberWithBool:NO];
    order.option = [NSNumber numberWithInt:selection];//[NSNumber numberWithInt:selection];
    order.created = [NSDate date];
    
    return order;
}


@end
