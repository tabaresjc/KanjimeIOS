//
//  Collection.h
//  KanjiMe
//
//  Created by Juan Tabares on 10/14/13.
//  Copyright (c) 2013 LearnJapanese123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * collectionId;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSString * extraTitle;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * modified;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;

@end
