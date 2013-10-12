//
//  CoreDataHandler.h
//  KanjiMe
//
//  Created by Juan Tabares on 10/9/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAIN_DOCUMENT_NAME @"MainDocument"

@interface CoreDataHandler : NSObject
@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) id currentCollection;

- (void)useDocumentWithName:(NSString *)name completionHandler:(void (^)(BOOL success))completionHandler;
- (BOOL)saveDocument;
- (id)getListOfCollection;
- (id)getCollectionListByName:(NSString *)searchText;
- (id)getCollectionListByFavorite;
- (id)getCollectionFromDictionary:(NSDictionary *)collectionDictionary;
- (id)getCollectionFromId:(NSNumber *)idOfRecord;
- (id)getListOfOrder;
- (id)getOrderFromParameters:(NSString *)name
                   withEmail:(NSString *)email
                  withTattoo:(NSString *)tattoo
                withComments:(NSString *)comments
           withSelectedImage:(int)selection
             withPaymentInfo:(NSDictionary *)paypalPaymentInfo;



@end
