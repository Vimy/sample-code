//
//  Bookmark.m
//  No More Paywall
//
//  Created by Matthias Vermeulen on 8/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.urlString = [aDecoder decodeObjectForKey:@"url"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.urlString forKey:@"url"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (BOOL)isEqual:(Bookmark *)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (![self.urlString isEqual:object.urlString])
    {
        return NO;
    }
    
    if (![self.title isEqual:object.title])
    {
        return NO;
    }
    
    
    return YES;
}

- (NSUInteger)hash {

    
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.urlString hash];
    result = prime * result + [self.title hash];
    

    return result;
    //https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
}

@end
