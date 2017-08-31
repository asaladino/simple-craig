//
//  Setting.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/21/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "Post.h"

@implementation Post

- (id)init {
    self = [super init];
    if (self) {
        self.currentImages = [[NSMutableArray alloc] init];
        self.fullImages = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
