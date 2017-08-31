//
//  TypeRepository.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/20/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "TypeRepository.h"

@implementation TypeRepository

- (NSArray *) findAll {
    return @[
             [[Type alloc] initWithValue:@"jo" andName:@"job offered"],
             [[Type alloc] initWithValue:@"go" andName:@"gig offered"],
             [[Type alloc] initWithValue:@"jw" andName:@"resume / job wanted"],
             [[Type alloc] initWithValue:@"ho" andName:@"housing offered"],
             [[Type alloc] initWithValue:@"hw" andName:@"housing wanted"],
             [[Type alloc] initWithValue:@"fso" andName:@"for sale by owner"],
             [[Type alloc] initWithValue:@"fsd" andName:@"for sale by dealer"],
             [[Type alloc] initWithValue:@"iwo" andName:@"wanted by owner"],
             [[Type alloc] initWithValue:@"iwd" andName:@"wanted by dealer"],
             [[Type alloc] initWithValue:@"so" andName:@"service offered"],
             [[Type alloc] initWithValue:@"p" andName:@"personal / romance"],
             [[Type alloc] initWithValue:@"c" andName:@"community"],
             [[Type alloc] initWithValue:@"e" andName:@"event"]];
}

- (Type *) findDefault {
    NSArray *types = [self findAll];
    for (Type * type in types) {
        if ([type.value isEqualToString:kTypeRepository]) {
            return type;
        }
    }
    return [types firstObject];
}


@end
