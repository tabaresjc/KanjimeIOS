//
//  NamesTableViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "NamesTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MainAppDelegate.h"
#import "RestApiFetcher.h"
#import "StylishCellViewCell.h"
#import "Collection+Rest.h"
#import "SearchCollectionTableViewController.h"
#import "MBProgressHUD.h"

static NSString *cellIdentifier = @"NameRow";
static NSString *searchCellIdentifier = @"SearchNameRow";

@interface NamesTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *filteredNames;


@end

@implementation NamesTableViewController
@synthesize filteredNames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setStyle];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self useDocument];
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setStyle
{
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    //UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    //self.tableView.contentInset = inset;

}

- (IBAction)refresh
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    
    RestApiFetcher *apiFetcher = [[RestApiFetcher alloc] init];
    [apiFetcher getNames:10000
                startingPoint:1
                      success:^(id jsonData) {
                          hud.labelText = @"Updating...";
                          NSArray *collections = [jsonData valueForKeyPath:@"apiresponse.data.collections"];
                          for (NSDictionary *collection in collections) {
                              [Collection syncCollectionWithCD:collection inManagedObjectContext:self.managedObjectContext];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{                              
                              [hud hide:YES];
                              [self.refreshControl endRefreshing];
                          });
                      }
                      failure:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [hud hide:YES];
                              [self.refreshControl endRefreshing];
                          });
                      }
     ];
}

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MainDocument"];
    
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
              [self refresh];
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
            [self refresh];
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
    } else {
        self.fetchedResultsController = nil;
    }
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.managedObjectContext = _managedObjectContext;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setDetail:withCell:)]){
            Collection *object = nil;
            if([self.searchDisplayController isActive]){
                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                object = [self.filteredNames objectAtIndexPath:indexPath];
                
            } else {
                if ([sender isKindOfClass:[UITableViewCell class]]) {
                    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
                    object = [self.fetchedResultsController objectAtIndexPath:indexPath];
                }
            }
            if(object){
                [segue.destinationViewController performSelector:@selector(setDetail:withCell:) withObject:object withObject:Nil];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[[self.filteredNames sections] objectAtIndex:section] name];
    } else {
        return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredNames sectionForSectionIndexTitle:title atIndex:index];
    } else {
        return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
    }
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredNames sectionIndexTitles];
    } else {
        return [self.fetchedResultsController sectionIndexTitles];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[self.filteredNames sections] count];
    } else {
        return [[self.fetchedResultsController sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [[[self.filteredNames sections] objectAtIndex:section] numberOfObjects];
    } else {
        return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: @"showDetail" sender: self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        Collection *collection = [self.filteredNames objectAtIndexPath:indexPath];
        
        cell.textLabel.text = collection.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        
        return cell;
        
    } else {
        StylishCellViewCell *cell = (StylishCellViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.titleLabel.text = collection.title;
        cell.subTitleLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        cell.like = collection.favorite;
        
        return cell;
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Collection"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchText];
    [request setPredicate:predicate];
    
    self.filteredNames = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                             managedObjectContext:self.managedObjectContext
                                                               sectionNameKeyPath:nil
                                                                        cacheName:nil];
    NSError *error;
    [self.filteredNames performFetch:&error];
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


- (IBAction)shareToFacebook:(id)sender {
    NSURL* url = [NSURL URLWithString:@"http://kanjime.learnjapanese123.com/"];
    [FBDialogs presentShareDialogWithLink:url
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
}



@end
