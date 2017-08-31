//
//  SettingRepository.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/21/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

#define kLengthOfDisplayName 10
#define kMaxNumberOfImages 8

@interface PostRepository : NSObject

@property Post *post;

- (Type *) findCurrentType;
- (BOOL) isCurrentType: (Type *) type;
- (void) setCurrentType: (Type *) type;
- (NSString *) getCurrentTypeDisplayName;

- (Category *) findCurrentCategory;
- (BOOL) isCurrentCategory: (Category *) category;
- (void) setCurrentCategory: (Category *) category;
- (NSString *) getCurrentCategoryDisplayName;

- (Area *) findCurrentArea;
- (BOOL) isCurrentArea: (Area *) area;
- (void) setCurrentArea: (Area *) area;
- (NSString *) getCurrentAreaDisplayName;

- (void) addImage: (NSURL *) url;
- (BOOL) doesImageExist: (NSURL *) url;
- (void) removeImage: (NSURL *) url;
- (NSArray *) findAllImages;
- (BOOL) canStillAddImages;

@end
