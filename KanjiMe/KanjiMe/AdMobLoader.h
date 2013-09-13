//
//  AdMobLoader.h
//  KanjiMe
//
//  Created by Lion User on 9/13/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"

#define ADMOB_ID @"ca-app-pub-9096893656708907/5942382873"
@interface AdMobLoader : NSObject
+ (GADBannerView *)getNewBannerView:(UIViewController *)mainView;
+ (GADRequest *)getNewRequest:(BOOL)testMode;

@end
