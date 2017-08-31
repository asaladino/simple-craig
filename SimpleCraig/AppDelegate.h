//
//  AppDelegate.h
//  SimpleCraig
//
//  Created by Adam Saladino on 7/12/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostRepository.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property PostRepository *postRepository;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
