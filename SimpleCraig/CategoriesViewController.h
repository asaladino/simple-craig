//
//  CategoriesViewController.h
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryRepository.h"
#import "PostRepository.h"
#import "AreasTypesHelpersUITableViewController.h"

@protocol CategoriesViewControllerDelegate;

@interface CategoriesViewController : AreasTypesHelpersUITableViewController

@property NSMutableArray *filteredResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) id <CategoriesViewControllerDelegate> delegate;
@property CategoryRepository *categoryRepository;
@property PostRepository *settingRepository;
@property NSArray *categories;

- (void) initCategories;

@end

@protocol CategoriesViewControllerDelegate

- (void) closeCategoriesViewController;

@end