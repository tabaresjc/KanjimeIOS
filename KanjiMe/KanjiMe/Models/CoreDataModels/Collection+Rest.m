//
//  Collection+Rest.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Collection+Rest.h"

@implementation Collection (Rest)
+ (Collection *)syncCollectionWithCD:(NSDictionary *)collectionDictionary
              inManagedObjectContext:(NSManagedObjectContext *)context{
    Collection *collection = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"collectionId = %@",
                         [collectionDictionary valueForKeyPath:NAME_ID]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request
                                              error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                              inManagedObjectContext:context];
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

+ (NSDate *)getDateTimeFromString:(NSString *)rawDateString
{
    return [self dateStringFromString:rawDateString
                         sourceFormat:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSDate *)dateStringFromString:(NSString *)sourceString
                      sourceFormat:(NSString *)sourceFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:sourceFormat];
    return [dateFormatter dateFromString:sourceString];
}


@end
