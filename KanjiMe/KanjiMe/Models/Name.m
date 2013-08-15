//
//  Name.m
//  KanjiMe
//
//  Created by Lion User on 8/15/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "Name.h"

@implementation Name
@synthesize baseObject;
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

-(id)initWithBasicObject:(id)basicObject
{
    self = [super init];
    if(self)
    {
        self.baseObject = (NSMutableDictionary *)basicObject;
    }
    return self;
}

-(NSString *)title
{
    NSString *data = [self.baseObject valueForKeyPath:WP_POST_TITLE];
    if(!data) data = @"?";
    return data;
}

-(NSString *)subTitle
{
    NSString *data = [self.baseObject valueForKeyPath:WP_POST_DESCRIPTION];
    if(!data) data = @"?";
    
    return data;
}

- (NSDictionary *)content
{
    NSDictionary *data = [self.baseObject valueForKeyPath:WP_POST_CONTENT];
    return data;
}

- (NSString *)dateTime
{
    NSString *data = [self.baseObject valueForKeyPath:WP_POST_DATETIME];
    if(data) {
        data = [self getDateTimeFromString:data];
    }else {
        data = @"?";
    }
    return data;
}

- (NSInteger)postId
{
    NSInteger postId = -1;
    NSString *data = [self.baseObject valueForKeyPath:WP_POST_ID];
    
    if(data) {
        postId = [data integerValue];
    }
    return postId;
}

- (BOOL)markFavorite
{
    return [[self.baseObject valueForKeyPath:WP_POST_MARK] isEqual:[NSNumber numberWithBool:YES]];
}

-(void)setMarkFavorite:(BOOL)markFavorite
{
    [self.baseObject setValue:[NSNumber numberWithBool:markFavorite] forKeyPath:WP_POST_MARK];
}

- (NSString *)getDateTimeFromString:(NSString *)rawDateString
{
    return [self dateStringFromString:rawDateString
                         sourceFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"
                    destinationFormat:@"EEEE, MMMM d, yyyy h:mm a"];
}

- (NSString *)dateStringFromString:(NSString *)sourceString
                      sourceFormat:(NSString *)sourceFormat
                 destinationFormat:(NSString *)destinationFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:sourceFormat];
    NSDate *date = [dateFormatter dateFromString:sourceString];
    [dateFormatter setDateFormat:destinationFormat];
    return [dateFormatter stringFromDate:date];
}
@end
