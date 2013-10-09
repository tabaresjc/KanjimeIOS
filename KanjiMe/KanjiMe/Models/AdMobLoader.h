//
//  AdMobLoader.h
//  KanjiMe
//
//  Created by Lion User on 9/13/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"


@interface AdMobLoader : NSObject
+ (GADBannerView *)getNewBannerView:(UIViewController *)mainView;
+ (GADRequest *)getNewRequest;

@end
