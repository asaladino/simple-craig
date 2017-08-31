//
//  UITableViewController+ThemeSearchUITableViewController.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/22/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "AreasTypesHelpersUITableViewController.h"
#import "CraigsPostListItem.h"

@implementation AreasTypesHelpersUITableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.filteredResult = [[NSMutableArray alloc] init];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL) prefersStatusBarHidden {
    return NO;
}

#pragma mark - Section names
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [[self.sections allKeys] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredResult.count;
    } else {
        return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    //[_filteredResult removeAllObjects];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    //_filteredResult = [NSMutableArray arrayWithArray:[self.types filteredArrayUsingPredicate:predicate]];
}


#pragma mark - Helpers
- (void) themeTableAnd: (UISearchBar *) searchBar {
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:(45 /255.0) green:(48 /255.0) blue:(53 /255.0) alpha:1.f];
    self.tableView.separatorColor = [[UIColor alloc] initWithRed:(36 /255.0) green:(38 /255.0) blue:(42 /255.0) alpha:1.f];
    searchBar.barTintColor = [[UIColor alloc] initWithRed:(39 /255.0) green:(41 /255.0) blue:(46 /255.0) alpha:1.f];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    for (UIView *subView in searchBar.subviews){
        for (UIView *nextLevel in subView.subviews) {
            if ([nextLevel isKindOfClass:[UITextField class]]) {
                UITextField *searchField = ((UITextField *)nextLevel);
                searchField.backgroundColor = [[UIColor alloc] initWithRed:(45 /255.0) green:(48 /255.0) blue:(53 /255.0) alpha:1.f];
                searchField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                break;
            }
        }
    }
}

- (void) setCell: (UITableViewCell *) cell withName: (NSString *) name {
    ((UILabel *)[cell.contentView viewWithTag:3]).text = name;
}


- (void) setCell: (UITableViewCell *) cell withCheckmark: (BOOL) exists {
    if (exists) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void) loadSections: (NSArray *) items {
    self.sections = [[NSMutableDictionary alloc] init];
    BOOL found;
    for (CraigsPostListItem *item in items) {
        NSString *c = [item.name substringToIndex:1];
        
        found = NO;
        for (NSString *str in [self.sections allKeys]) {
            if ([str isEqualToString:c]) {
                found = YES;
            }
        }
        
        if (!found) {
            [self.sections setValue:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    for (CraigsPostListItem *item in items) {
        [[self.sections objectForKey:[item.name substringToIndex:1]] addObject:item];
    }
}

@end
