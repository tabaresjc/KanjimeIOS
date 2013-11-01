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
#import <Social/Social.h>
#import "MainAppDelegate.h"
#import "RestApiFetcher.h"
#import "StylishCellViewCell.h"
#import "Collection+Rest.h"
#import "SearchCollectionTableViewController.h"
#import "MBProgressHUD.h"
#import "UtilHelper.h"


static NSString *cellIdentifier = @"NameRow";
static NSString *searchCellIdentifier = @"SearchNameRow";

@interface NamesTableViewController ()
@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@property (strong, nonatomic) NSFetchedResultsController *filteredNames;
@property (nonatomic) BOOL setView;


@end

@implementation NamesTableViewController
@synthesize filteredNames, setView;
@synthesize lastNotification = _lastNotification;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CoreDataHandler *)coreDataRep
{
    if(!_coreDataRep){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _coreDataRep = appDelegate.coreDataHandler;
    }
    return _coreDataRep;
}

- (Notification *)lastNotification
{
    if(!_lastNotification){
        _lastNotification = [self.coreDataRep getLastNotification];
    }
    return _lastNotification;
}

- (void)setLastNotification:(Notification *)lastNotification
{
    _lastNotification = lastNotification;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.coreDataRep.isOpen) {
        [self setupDocument];
    }
    
    NSMutableArray *tabControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    if([tabControllers count] > 0 ) {
        [tabControllers removeObjectAtIndex:1];
        self.tabBarController.viewControllers = tabControllers;
    }
    
    
    
    self.tabBarController.delegate = self;
    [self setStyle];
#if !TARGET_IPHONE_SIMULATOR
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [AdMobLoader getNewBannerView:self];
    [bannerView_ setDelegate:self];
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[AdMobLoader getNewRequest]];
#endif
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.coreDataRep.isOpen) {
        if(self.coreDataRep.managedObjectContext.hasChanges){
            [self.coreDataRep saveDocument];
            [self.tableView reloadData];
        }
    }
    
    //if(self.coreDataRep.receivedNotification){
    //    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:@"!"];
    //}
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [UIView beginAnimations:@"BannerSlide" context:nil];
    UIEdgeInsets inset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0.0f, -50.0f);
    [self.view addSubview:bannerView_];
    
    CGRect banFrame = bannerView_.frame;
    banFrame.origin.y = -50;
    [bannerView_ setFrame:banFrame];
    [UIView commitAnimations];
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
}


- (IBAction)refreshNames:(id)sender {
    [self refresh];
}

- (void)refresh
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.fetchedResultsController = [self.coreDataRep getListOfCollection];
    
    NSUInteger startingPoint = 1;
    Collection *lastCollection = [self.coreDataRep getLastCollection];
    
    if(lastCollection){
        startingPoint = [lastCollection.collectionId integerValue];
        startingPoint ++;
    }
    
    RestApiFetcher *apiFetcher = [[RestApiFetcher alloc] init];
    [apiFetcher getNames:10000
                startingPoint:startingPoint
                      success:^(id jsonData) {
                          NSArray *collections = [jsonData valueForKeyPath:@"apiresponse.data.collections"];
                          for (NSDictionary *collection in collections) {
                              [self.coreDataRep getCollectionFromDictionary:collection];
                          }
                          
                          if([collections count]>0) {
                              if(startingPoint == 1){
                                  [self.coreDataRep getNewNotification:[NSNumber numberWithInteger:startingPoint] withDate:[NSDate date]];
                              } else {
                                  [self.coreDataRep getNewNotification:[NSNumber numberWithInteger:startingPoint] withDate:nil];
                              }
                          }
                          
                          [self.coreDataRep saveDocument];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                              [self.refreshControl endRefreshing];
                              [self.tableView reloadData];
                          });
                          
                      }
                      failure:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                              [self.refreshControl endRefreshing];
                              [self.tableView reloadData];                              
                          });
                      }
     ];
}

- (void)setupDocument
{
    [self.coreDataRep startDocument:^(BOOL success) {
        [self refresh];
    }];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setDetail:)]){
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
                [segue.destinationViewController performSelector:@selector(setDetail:) withObject:object];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section==0 && tableView != self.searchDisplayController.searchResultsTableView ? 0.0f : 0.0f;
}

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
        
        if((indexPath.row%2)==0){
            cell.contentView.backgroundColor = UIColorFromRGBWithAlpha(0xf0f0f0, 1);
        }
        
        return cell;
        
    } else {
        StylishCellViewCell *cell = (StylishCellViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        Collection *collection = [self.fetchedResultsController objectAtIndexPath:indexPath];

        cell.titleLabel.text = collection.title;
        cell.subTitleLabel.text = [NSString stringWithFormat:@"Kanji: %@",collection.subtitle];
        cell.like = [collection.favorite boolValue];
        cell.newItem = NO;
        if(self.lastNotification) {
            if([collection.collectionId integerValue] >= [self.lastNotification.startingPoint integerValue]) {
                if([[NSDate date] compare:self.lastNotification.created]!=NSOrderedDescending){
                    cell.newItem = YES;
                }
            }
        }
        return cell;
    }
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSError *error;
    self.filteredNames = [self.coreDataRep getCollectionListByName:searchText];
    [self.filteredNames performFetch:&error];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)callShareActionSheet
{
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
    [shareActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [shareActionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Collection *currentCollection = nil;
    if(self.coreDataRep.currentCollection && [self.coreDataRep.currentCollection isKindOfClass:[Collection class]]){
        currentCollection = (Collection *)currentCollection;
    }
    switch (buttonIndex) {
        case 0:
        {
            if(currentCollection){
                [currentCollection shareToFacebook];
            } else {
                [self shareToFacebook];
            }
        }
            break;
        case 1:
        {
            if(currentCollection){
                [currentCollection shareToTwitter:self];
            } else {
                [self shareToTwitter];
            }
        }
            break;
        case 2:
        {
            if(currentCollection){
                [self shareByEmail:[currentCollection getCommonDescriptor]];
            } else {
                [self shareByEmail:[self getCommonDescriptor]];
            }
            
        }
            break;
        default:
            break;
    }
}

- (NSString *)getCommonDescriptor
{
    return [NSString stringWithFormat:@"KanjiMe: Find your Japanese name at %@", WEB_ENDPOINT_URL];
    
}

- (void)shareToFacebook
{
    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:WEB_ENDPOINT_URL]
                                     name:@"KanjiMe! iOS"
                                  caption:@"KanjiMe!"
                              description:[self getCommonDescriptor]
                                  picture:[NSURL URLWithString:@"http://kanjime.learnjapanese123.com/img/iTunesArtwork.png"]
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
    
}

- (void)shareToTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[self getCommonDescriptor]];
        [tweetSheet addImage:[UIImage imageNamed:@"iTunesArtwork.png"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure"
                                  "your device has an internet connection and you have"
                                  "at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareByEmail:(NSString *)descriptor
{
    
    // Email Subject
    NSString *emailTitle = @"KanjiMe! iOS";
    // Email Content
    NSString *messageBody = descriptor;
    // To address
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    [mc setNavigationBarHidden:YES];
    
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    MBProgressHUD *emailMessageWindow = [MBProgressHUD showHUDAddedTo:self.view
                                                             animated:YES];
    emailMessageWindow.mode = MBProgressHUDModeIndeterminate;
    emailMessageWindow.labelText = @"Sending message...";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            emailMessageWindow.labelText = @"Cancelled";
            break;
        case MFMailComposeResultSaved:
            emailMessageWindow.labelText = @"Saved";
            break;
        case MFMailComposeResultSent:
            emailMessageWindow.labelText = @"Sent";
            break;
        case MFMailComposeResultFailed:
            emailMessageWindow.labelText = @"Fail";
            break;
        default:
            break;
    }
    // Close the Mail Interface
    
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSThread sleepForTimeInterval:0.5];
            [emailMessageWindow hide:YES];
        });
    }];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    switch (viewController.tabBarItem.tag) {
        case 3:
        {
            [self callShareActionSheet];
            return NO;
        }
        default:
            return YES;
    }
}



@end
