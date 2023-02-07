//
//  UrlShare.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 8/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import "UrlShare.h"

@implementation UrlShare
{
    NSString *path;
}

+ (id)UrlShareManager
{
    static UrlShare *urlShareManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        urlShareManager = [[self alloc] init];
    });
    
    return urlShareManager;
}

- (id)init
{
    if (self = [super init])
    {
         path = [self getFileURL];
        self.urlArray = [[NSMutableArray alloc]init];
       
    }
    
    return self;
    
}


- (NSString *)getFileURL
{
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.net.noizystudios.urlGroup"];
    NSURL *jsonURL = [NSURL URLWithString:[containerURL.path stringByAppendingString:@"/urlData.dat"]];
    NSString *filePath = [jsonURL absoluteString];
    NSLog(@"Filepath: %@", filePath );
    return filePath;
}

- (void)removeURL:(NSMutableArray *)deleteList
{
    self.urlArray = [NSMutableArray new];
    if ([self loadURLS])
    {
        self.urlArray = [self loadURLS];
    }
    [self.urlArray removeObjectsInArray:deleteList];
    NSLog(@"Hoi");
    [self saveURLS];
}


- (void)addURL:(NSString *)url andTitle:(NSString *)title
{
    self.urlArray = [NSMutableArray new];
    if ([self loadURLS])
    {
         self.urlArray = [self loadURLS];
    }
   
    NSLog(@"URL STRING: %@", url);
    Bookmark *urlBookmark = [[Bookmark alloc]init];
    urlBookmark.urlString = url;
    urlBookmark.title = title;
    [self.urlArray addObject:urlBookmark];
    [self saveURLS];
}

- (NSMutableArray *)loadURLS
{
    
    NSMutableArray *url = [[NSMutableArray alloc]init];
    @try {
        url = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch ( NSException *e ) {
        NSLog(@"LoadURLS gefaald.");
    }
    
    NSLog(@"URL array inhoud: %@", url);
    return url;
}

- (void)saveURLS
{
  
    BOOL isSaved = [NSKeyedArchiver archiveRootObject:self.urlArray toFile:path];
    NSLog (isSaved ? @"saved" : @"niet gesaved");
    
}



@end
