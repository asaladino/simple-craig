//
//  CraigsArea.h
//  SimpleCraig
//
//  Created by Adam Saladino on 7/16/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CraigsPostListItem : NSObject

- (id)initWithValue:(NSString *)value andName: (NSString *) name;
- (NSString *) descriptionCode;

@property NSString *value;
@property NSString *name;

@end
