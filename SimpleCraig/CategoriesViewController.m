//
//  CategoriesViewController.m
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "CategoriesViewController.h"
#import "Category.h"

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCategories];
    [self themeTableAnd:self.searchBar];
    [self loadSections:self.categories];
}

#pragma mark - Load data

- (void) initCategories {
    self.categoryRepository = [[CategoryRepository alloc] init];
    self.categories = [self.categoryRepository findAll];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Category *category = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self setCell:cell withName:category.name];
    [self setCell:cell withCheckmark:[self.settingRepository isCurrentCategory:category]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Category *category = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self.settingRepository setCurrentCategory:category];
    [self.delegate closeCategoriesViewController];
}

- (IBAction)closeTypesViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
