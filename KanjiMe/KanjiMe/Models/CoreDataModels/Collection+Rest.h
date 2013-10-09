//
//  Collection+Rest.h
//  KanjiMe
//
//  Created by Lion User on 8/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Collection.h"



@interface Collection (Rest)

- (void)shareToFacebook;
- (void)shareToTwitter:(UIViewController *)mainView;
- (NSString *)getCommonDescriptor;

@end
