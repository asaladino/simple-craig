//
//  Setting.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/21/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Type.h"
#import "Area.h"
#import "Category.h"

@interface Post : NSObject

@property Type *currentType;
@property Category *currentCategory;
@property Area *currentArea;
@property NSString *title;
@property NSNumber *price;
@property NSString *specificLocation;
@property NSString *description;
@property NSString *email;
@property NSMutableArray *currentImages;
@property NSMutableArray *fullImages;

@end
