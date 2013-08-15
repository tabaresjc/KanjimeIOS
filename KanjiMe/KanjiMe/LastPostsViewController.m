//
//  LastPostsViewController.m
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "LastPostsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MainAppDelegate.h"
#import "StylishCellViewCell.h"


@interface LastPostsViewController ()
@property (strong,nonatomic) RestApiFetcher* apiFetcher;
@property (nonatomic,strong) NSArray *latestPosts;
@property (strong,nonatomic) NSIndexPath *currentSelectedRow;
@property (strong,nonatomic) NSIndexPath *lastSelectedRow;
@end

@implementation LastPostsViewController
@synthesize currentSelectedRow, lastSelectedRow;

- (RestApiFetcher *)apiFetcher
{
    if(!_apiFetcher){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _apiFetcher = appDelegate.apiFetcher;
    }
    return _apiFetcher;
}


- (void)setLatestPosts:(NSArray *)latestPosts
{
    _latestPosts = latestPosts;    
    [self.tableView reloadData];
}

- (void)fetchLatestPost
{
    [self.refreshControl beginRefreshing];
    [self.apiFetcher getNames:10000
                startingPoint:1
                      success:^(id jsonData) {
                          self.apiFetcher.lastPosts = [jsonData valueForKeyPath:@"apiresponse.data.collections"];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.latestPosts = self.apiFetcher.lastPosts;
                              [self.refreshControl endRefreshing];
                          });
                      }
                      failure:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.refreshControl endRefreshing];
                          });                          
                      }
     ];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        self.currentSelectedRow = [self.tableView indexPathForSelectedRow];
        
        if(self.currentSelectedRow) {
            if([segue.destinationViewController respondsToSelector:@selector(setDetail:withCell:)]){
                
                NSObject *object = self.latestPosts[self.currentSelectedRow.row];
                NSObject *cell = [[self tableView] cellForRowAtIndexPath:self.currentSelectedRow];
                if(self.lastSelectedRow && self.lastSelectedRow.row!=self.currentSelectedRow.row){
                    ((StylishCellViewCell *)[[self tableView] cellForRowAtIndexPath:self.lastSelectedRow]).selected = NO;
                }
                self.lastSelectedRow = [self.tableView indexPathForSelectedRow];
                
                [segue.destinationViewController performSelector:@selector(setDetail:withCell:) withObject:object withObject:cell];
            }
        }
    }    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];    
    [self fetchLatestPost];
    [self.refreshControl addTarget:self
                            action:@selector(fetchLatestPost)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.apiFetcher.refreshMain){
        self.apiFetcher.refreshMain = NO;
        [self.tableView reloadData];
    }
    
    if(self.currentSelectedRow && [self.latestPosts count]>self.currentSelectedRow.row){
        ((StylishCellViewCell *)[[self tableView] cellForRowAtIndexPath:self.currentSelectedRow]).selected = YES;
    }
}

- (void)setStyle
{
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.contentInset = inset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
   return [self.latestPosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Name *post = [[Name alloc] initWithBasicObject:self.latestPosts[indexPath.row]];
    
    StylishCellViewCell *cell = (StylishCellViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostRow" forIndexPath:indexPath];
    
    cell.titleLabel.text = post.title;
    cell.subTitleLabel.text = [NSString stringWithFormat:@"Kanji: %@",post.subTitle];
    cell.like = post.markFavorite;    
    return cell;
}

@end
