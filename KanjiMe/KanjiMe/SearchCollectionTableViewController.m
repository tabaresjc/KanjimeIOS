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

@interface SearchCollectionTableViewController ()
@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@property (strong, nonatomic) NSFetchedResultsController *filteredNames;
@end

@implementation SearchCollectionTableViewController
@synthesize filteredNames;

- (CoreDataHandler *)coreDataRep
{
    if(!_coreDataRep){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _coreDataRep = appDelegate.coreDataHandler;
    }
    return _coreDataRep;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh
{
    self.fetchedResultsController = [self.coreDataRep getCollectionListByFavorite];
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
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchResult"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        Collection *collection = [self.filteredNames objectAtIndexPath:indexPath];
        
        cell.textLabel.text = collection.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResult"];
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



@end
