//
//  SearchCollectionTableViewController.h
//  KanjiMe
//
//  Created by Lion User on 8/17/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface SearchCollectionTableViewController : CoreDataTableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
