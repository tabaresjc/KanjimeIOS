//
//  Collection.h
//  KanjiMe
//
//  Created by Lion User on 1/26/14.
//  Copyright (c) 2014 LearnJapanese123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * collectionId;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * extraTitle;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSString * modified;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * hash_value;
@property (nonatomic, retain) NSString * url_video;

@end
