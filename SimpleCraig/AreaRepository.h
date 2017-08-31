//
//  AreaRepository.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/20/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Area.h"

#define kAreaRepositoryDefault @"318"

@interface AreaRepository : NSObject

- (NSArray *) findAll;
- (Area *) findDefault;

@end
