//
//  UrlShare.h
//  No More Paywall
//
//  Created by Matthias Vermeulen on 8/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

@interface UrlShare : NSObject

@property (nonatomic, retain) NSMutableArray *urlArray;
+ (id)UrlShareManager;

- (NSMutableArray *)loadURLS;
- (void)saveURLS;
- (void)addURL:(NSString *)url andTitle:(NSString *)title;
- (void)removeURL:(NSMutableArray *)deleteList;

@end
