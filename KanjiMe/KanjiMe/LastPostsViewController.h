//
//  LastPostsViewController.h
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPostsViewController.h"

@interface LastPostsViewController : UITableViewController
@property (strong,nonatomic) SearchPostsViewController *searchPostController;
@end
