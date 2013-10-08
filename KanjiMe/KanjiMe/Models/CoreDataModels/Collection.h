//
//  Collection.h
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSString * extraTitle;
@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSString * modified;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * collectionId;

@end
