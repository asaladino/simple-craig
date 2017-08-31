//
//  CategoryRepository.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/20/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Type.h"

#define kTypeRepository @"fso"

@interface TypeRepository : NSObject

- (NSArray *) findAll;
- (Type *) findDefault;

@end
