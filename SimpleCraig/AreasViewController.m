//
//  LocationsViewController.m
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "AreasViewController.h"
#import "Area.h"

@implementation AreasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAreas];
    [self themeTableAnd:self.searchBar];
    [self loadSections:self.areas];
}

#pragma mark - Load data

- (void) initAreas {
    self.areaRepository = [[AreaRepository alloc] init];
    self.areas = [self.areaRepository findAll];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Area *area = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self setCell:cell withName:area.name];
    [self setCell:cell withCheckmark:[self.settingRepository isCurrentArea:area]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Area *area = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self.settingRepository setCurrentArea:area];
    [self.delegate closeAreasViewController];
}

- (IBAction)closeAreasViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end