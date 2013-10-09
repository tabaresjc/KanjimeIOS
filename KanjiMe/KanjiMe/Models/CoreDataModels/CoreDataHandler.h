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

- (void)useDocumentWithName:(NSString *)name completionHandler:(void (^)(BOOL success))completionHandler;
- (id)getListOfCollection;
- (id)getCollectionListByName:(NSString *)searchText;
- (id)getCollectionListByFavorite;
- (id)getCollectionFromDictionary:(NSDictionary *)collectionDictionary;
- (id)getListOfOrder;
- (id)getOrderFromParameters:(NSString *)name
                        withEmail:(NSString *)email
                       withTattoo:(NSString *)tattoo
                     withComments:(NSString *)comments
                  withPaymentInfo:(NSDictionary *)paypalPaymentInfo;



@end
