//
//  MainAppDelegate.m
//  KanjiMe
//
//  Created by Lion User on 5/25/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "MainAppDelegate.h"


@implementation MainAppDelegate
@synthesize apiFetcher;

-(void)customizeiPhoneTheme
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    UIImage *navBarImage = [UIImage imageNamed:@"menubar"];
    navBarImage = [navBarImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20.0, 0, 20.0)];
    
    UIImage *navBarLandscapeImage = [UIImage imageNamed:@"menubar-landscape"];
    navBarLandscapeImage = [navBarLandscapeImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20.0, 0, 20.0)];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBackgroundImage:navBarLandscapeImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    [searchBarAppearance setBackgroundImage:navBarImage];
    [searchBarAppearance setBackgroundColor:[UIColor blackColor]];
    
    [[UIBarButtonItem appearance] setTintColor:UIColorFromRGB(0x333333)];    
    UIImage *minImage = [UIImage tallImageNamed:@"ipad-slider-fill"];
    UIImage *maxImage = [UIImage tallImageNamed:@"ipad-slider-track.png"];
    UIImage *thumbImage = [UIImage tallImageNamed:@"ipad-slider-handle.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    UIImage* tabBarBackground = [UIImage tallImageNamed:@"tabbar.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor lightGrayColor]];
    
    [navigationBarAppearance setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                      UIColorFromRGB(0xf5f5f5), UITextAttributeTextColor,
                                                      UIColorFromRGBWithAlpha(0x000000, 0.8),
                                                      UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                      UITextAttributeTextShadowOffset,
                                                      [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], UITextAttributeFont, nil]];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.apiFetcher = [[RestApiFetcher alloc] init];
    [self customizeiPhoneTheme];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
