//
//  SearchPostsViewController.m
//  KanjiMe
//
//  Created by Lion User on 17/06/2013.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "SearchPostsViewController.h"
#import "MainAppDelegate.h"

@interface SearchPostsViewController ()
@property (nonatomic,strong) NSMutableArray *favoritesPosts;
@property (nonatomic,strong) NSIndexPath *currentRow;
@property (weak, nonatomic) RestApiFetcher *apiFetcher;

@end

@implementation SearchPostsViewController
@synthesize filteredPosts, currentRow;

- (RestApiFetcher *)apiFetcher
{
    if(!_apiFetcher){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _apiFetcher = appDelegate.apiFetcher;
    }
    return _apiFetcher;
}

- (NSMutableArray *)favoritesPosts{
    if(!_favoritesPosts){
        _favoritesPosts = self.apiFetcher.favoritePosts;
    }
    return _favoritesPosts;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setDetail:withCell:)]){
            NSObject *object = nil;
            if(sender == self.searchDisplayController.searchResultsTableView){
                if(self.currentRow) {
                    object = self.filteredPosts[self.currentRow.row];
                }
            }else{
                if([self.tableView indexPathForSelectedRow]) {
                    object = self.favoritesPosts[[self.tableView indexPathForSelectedRow].row];
                }
            }
            if(object){
                [segue.destinationViewController performSelector:@selector(setDetail:withCell:) withObject:object withObject:Nil];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.currentRow = indexPath;
        [self performSegueWithIdentifier: @"showSearchResult" sender: tableView];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.currentRow = indexPath;
        [self performSegueWithIdentifier: @"showSearchResult" sender: tableView];
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
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self.tableView reloadData];
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
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredPosts count];
    }else{
        return [self.favoritesPosts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    Name *post = nil;
    static NSString *cellIdentifier = @"SearchResult";
    if(tableView == self.searchDisplayController.searchResultsTableView){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        post = [[Name alloc] initWithBasicObject:self.filteredPosts[indexPath.row]];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        post = [[Name alloc] initWithBasicObject:self.favoritesPosts[indexPath.row]];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",post.title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",post.subTitle];
    return cell;
}


-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {    
    [self.filteredPosts removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Collection.title contains[cd] %@",searchText];
    self.filteredPosts = [NSMutableArray arrayWithArray:[self.apiFetcher.lastPosts filteredArrayUsingPredicate:predicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
