//
//  NamesTableViewController.h
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "AdMobLoader.h"
#import "GADBannerViewDelegate.h"


@interface NamesTableViewController : CoreDataTableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITabBarControllerDelegate, GADBannerViewDelegate>
{
    // Declare one as an instance variable
    GADBannerView *bannerView_;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end
