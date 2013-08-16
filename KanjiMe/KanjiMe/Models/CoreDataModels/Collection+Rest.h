//
//  Collection+Rest.h
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Collection.h"

#define NAME_TITLE @"Collection.title"
#define NAME_SUBTITLE @"Collection.subtitle"
#define NAME_DESCRIPTION @"Collection.description"
#define NAME_BODY @"Collection.body"
#define NAME_CREATED @"Collection.created"
#define NAME_MODIFIED @"Collection.modified"
#define NAME_ID @"Collection.id"

@interface Collection (Rest)

+ (Collection *)syncCollectionWithCD:(NSDictionary *)collectionDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
