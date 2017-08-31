//
//  CraigsArea.m
//  SimpleCraig
//
//  Created by Adam Saladino on 7/16/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "CraigsPostListItem.h"

@implementation CraigsPostListItem

- (id)initWithValue:(NSString *)value andName: (NSString *) name
{
    self = [super init];
    if (self) {
        self.value = value;
        self.name = name;
    }
    return self;
}

- (NSString *)description
{
    return [self descriptionCode];
}

- (NSString *) descriptionCode
{
    return _name;
}

@end
