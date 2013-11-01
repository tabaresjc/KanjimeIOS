//
//  Notification.h
//  KanjiMe
//
//  Created by Juan Tabares on 11/1/13.
//  Copyright (c) 2013 LearnJapanese123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * startingPoint;

@end
