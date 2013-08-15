//
//  SearchPostsViewController.h
//  KanjiMe
//
//  Created by Lion User on 17/06/2013.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPostsViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong,nonatomic) NSMutableArray *filteredPosts;
@property (weak, nonatomic) IBOutlet UISearchBar *postSearchBar;


@end
