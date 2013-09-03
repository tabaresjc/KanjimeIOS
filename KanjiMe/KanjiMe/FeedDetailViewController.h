//
//  FeedDetailViewController.h
//  KanjiMe
//
//  Created by Lion User on 8/29/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedDetailViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* feedTableView;
- (void)setDetail:(id)newDetailItem withCell:(id)cell;

@end
