//
//  UITableViewController+ThemeSearchUITableViewController.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/22/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier @"Cell"

@interface AreasTypesHelpersUITableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property NSMutableDictionary *sections;
@property NSMutableArray *filteredResult;

- (void) loadSections: (NSArray *) items;
- (void) themeTableAnd: (UISearchBar *) searchBar;
- (void) setCell: (UITableViewCell *) cell withName: (NSString *) name;
- (void) setCell: (UITableViewCell *) cell withCheckmark: (BOOL) exists;

@end
