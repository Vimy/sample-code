//
//  Bookmark.h
//  No More Paywall
//
//  Created by Matthias Vermeulen on 8/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject <NSCoding>

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic , copy) NSString *title;
@end
