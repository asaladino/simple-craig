//
//  TypeRepository.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/20/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category.h"

#define kCategoryRepositoryDefault @"150"

@interface CategoryRepository : NSObject

- (NSArray *) findAll;

- (Category *) findDefault;

@end
