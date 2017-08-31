//
//  LocationsViewController.h
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AreaRepository.h"
#import "PostRepository.h"
#import "AreasTypesHelpersUITableViewController.h"

@protocol AreasViewControllerDelegate;

@interface AreasViewController : AreasTypesHelpersUITableViewController

@property NSMutableArray *filteredResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) id <AreasViewControllerDelegate> delegate;
@property AreaRepository *areaRepository;
@property PostRepository *settingRepository;
@property NSArray *areas;

- (void) initAreas;

@end

@protocol AreasViewControllerDelegate

- (void) closeAreasViewController;

@end