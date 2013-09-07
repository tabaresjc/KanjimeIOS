//
//  NamesTableViewController.h
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface NamesTableViewController : CoreDataTableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
