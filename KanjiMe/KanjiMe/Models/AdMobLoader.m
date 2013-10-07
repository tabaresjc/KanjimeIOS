//
//  AdMobLoader.m
//  KanjiMe
//
//  Created by Lion User on 9/13/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "AdMobLoader.h"
#import "GADBannerView.h"


@implementation AdMobLoader

+ (GADBannerView *)getNewBannerView:(UIViewController *)mainView
{
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    GADBannerView *bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    bannerView_.adUnitID = ADMOB_ID;
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = mainView;
    
    return bannerView_;
}

+ (GADRequest *)getNewRequest:(BOOL)testMode
{
    GADRequest *request = [GADRequest request];
    
    if(testMode) {
        request.testDevices = [NSArray arrayWithObjects:@"2be07610ffc77e998855454a203a7b3a", nil];
    }
    
    return request;
}

@end
