//
//  SettingRepository.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/21/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "PostRepository.h"

@implementation PostRepository

- (id)init
{
    self = [super init];
    if (self) {
        self.post = [[Post alloc] init];
    }
    return self;
}

#pragma mark - Current Type
- (Type *) findCurrentType {
    return self.post.currentType;
}

- (BOOL) isCurrentType: (Type *) type {
    return [type.value isEqualToString: self.post.currentType.value];
}

- (void) setCurrentType: (Type *) type {
    self.post.currentType = type;
}

- (NSString *) getCurrentTypeDisplayName {
    if (self.post.currentType.name.length > kLengthOfDisplayName) {
        return [[NSString alloc] initWithFormat:@"%@...", [self.post.currentType.name substringToIndex:kLengthOfDisplayName]];
    }
    return self.post.currentType.name;
}

#pragma mark - Current Category


- (Category *) findCurrentCategory {
    return self.post.currentCategory;
}

- (BOOL) isCurrentCategory: (Category *) category{
    return [category.value isEqualToString: self.post.currentCategory.value];
}

- (void) setCurrentCategory: (Category *) category{
    self.post.currentCategory = category;
}

- (NSString *) getCurrentCategoryDisplayName {
    if (self.post.currentCategory.name.length > kLengthOfDisplayName) {
        return [[NSString alloc] initWithFormat:@"%@...", [self.post.currentCategory.name substringToIndex:kLengthOfDisplayName]];
    }
    return self.post.currentCategory.name;
}


#pragma mark - Current Area
- (Area *) findCurrentArea {
    return self.post.currentArea;
}

- (BOOL) isCurrentArea: (Area *) area {
    return [area.value isEqualToString: self.post.currentArea.value];
}

- (void) setCurrentArea: (Area *) area {
    self.post.currentArea = area;
}

- (NSString *) getCurrentAreaDisplayName {
    if (self.post.currentArea.name.length > kLengthOfDisplayName) {
        return [[NSString alloc] initWithFormat:@"%@...", [self.post.currentArea.name substringToIndex:kLengthOfDisplayName]];
    }
    return self.post.currentArea.name;
}


#pragma mark - Images

- (void) addImage: (NSURL *) url {
    [self.post.currentImages addObject:url];
}

- (BOOL) doesImageExist: (NSURL *) url {
    for (NSURL *image in self.post.currentImages) {
        if ([[image absoluteString] isEqual:[url absoluteString]]) {
            return YES;
        }
    }
    return NO;
}

- (void) removeImage: (NSURL *) url {
    for (NSURL *image in self.post.currentImages) {
        if ([[image absoluteString] isEqual:[url absoluteString]]) {
            [self.post.currentImages removeObject:image];
            break;
        }
    }
}

- (NSArray *) findAllImages {
    return self.post.currentImages;
}


- (BOOL) canStillAddImages {
    return self.post.currentImages.count < kMaxNumberOfImages;
}

@end
