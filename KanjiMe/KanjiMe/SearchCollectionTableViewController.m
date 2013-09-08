//
//  SearchCollectionTableViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/17/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "SearchCollectionTableViewController.h"
#import "MainAppDelegate.h"
#import "NamesTableViewController.h"
#import "Collection.h"

static NSString *cellIdentifier = @"SearchResult";
@interface SearchCollectionTableViewController ()
@property (strong, nonatomic) NSFetchedResultsController *filteredNames;
@end

@implementation SearchCollectionTableViewController
@synthesize filteredNames;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh
{
    if (!self.managedObjectContext) {
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
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
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite = TRUE"];
        [request setPredicate:predicate];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
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
        [self performSegueWithIdentifier: @"showSearchResult" sender: self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.searchDisplayController.searchResultsTableView){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        Collection *collection = [self.filteredNames objectAtIndexPath:indexPath];
        
        cell.textLabel.text = collection.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = collection.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];
        collection.favorite = NO;
    }
}


- (IBAction)editButton:(UIBarButtonItem *)sender {
    if( self.tableView.editing ){
        [self.tableView setEditing:NO animated:YES];
        sender.title = @"Edit";
    }else{
        [self.tableView setEditing:YES animated:YES];
        sender.title = @"Cancel";
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

@end
