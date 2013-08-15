//
//  Name.h
//  KanjiMe
//
//  Created by Lion User on 8/15/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WP_POST_TITLE @"Collection.title"
#define WP_POST_DESCRIPTION @"Collection.subtitle"
#define WP_POST_CONTENT @"Collection.body"
#define WP_POST_DATETIME @"Collection.created"
#define WP_POST_MARK @"Collection.favorite"
#define WP_POST_ID @"Collection.id"

@interface Name : NSObject
- (NSString *)title;
- (NSString *)subTitle;
- (NSString *)content;
- (NSString *)dateTime;
- (NSInteger)postId;

@property (nonatomic) BOOL markFavorite;
@property (nonatomic,strong) NSMutableDictionary *baseObject;
-(id)initWithBasicObject:(id)basicObject;
@end
