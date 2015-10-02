//
//  CoreDataHandler.h
//  KanjiMe
//
//  Created by Lion User on 10/9/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define MAIN_DOCUMENT_NAME @"MainDocument"

@interface CoreDataHandler : NSObject

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) id currentCollection;
@property (strong, nonatomic) NSString *deviceToken;

@property (nonatomic) BOOL receivedNotification;
@property (strong, nonatomic) NSDictionary *remoteNotificationUserInfo;
@property (nonatomic) NSInteger startingPoint;

- (void)startDocument:(void (^)(BOOL success))completionHandler;
- (void)saveDocument;
- (id)getListOfCollection;
- (id)getCollectionListByName:(NSString *)searchText;
- (id)getCollectionListByFavorite;
- (id)getCollectionFromDictionary:(NSDictionary *)collectionDictionary;
- (id)getCollectionFromId:(NSNumber *)idOfRecord;
- (id)getLastCollection;
- (id)getListOfOrder;
- (id)getOrderFromParameters:(NSString *)name
                   withEmail:(NSString *)email
                  withTattoo:(NSString *)tattoo
                withComments:(NSString *)comments
           withSelectedImage:(int)selection
             withPaymentInfo:(NSDictionary *)paypalPaymentInfo;


@end
