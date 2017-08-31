//
//  Images.m
//  SimpleCraig
//
//  Created by Adam Saladino on 11/25/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "ImagesViewController.h"
#import "AppDelegate.h"

@implementation ImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.postRepository = appDelegate.postRepository;
    self.images = [[NSMutableArray alloc] init];
    self.alAssetsRepository = [[ALAssetsRepository alloc] initWithALAssetsLibrary:[[ALAssetsLibrary alloc] init]];
    self.alAssetsRepository.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.alAssetsRepository findAllImages];
}

- (void) saveImage: (UIImage *) image {
    [self.alAssetsRepository saveImage:image];
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellImageThumbnail" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:10];
    UIImageView *checkmark = (UIImageView *)[cell.contentView viewWithTag:4];
    NSURL *url = [self.images objectAtIndex:indexPath.row];
    [self.alAssetsRepository findImageThumb: url forImageView: imageView];
    if ([self.postRepository doesImageExist:url]) {
        checkmark.image = [UIImage imageNamed:@"checkmark-selected.png"];
    } else {
        checkmark.image = [UIImage imageNamed:@"checkmark-gray.png"];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *checkmark = (UIImageView *)[cell.contentView viewWithTag:4];
    NSURL *url = [self.images objectAtIndex:indexPath.row];
    if ([self.postRepository doesImageExist:url]) {
        checkmark.image = [UIImage imageNamed:@"checkmark-gray.png"];
        [self.postRepository removeImage:url];
    } else {
        if ([self.postRepository canStillAddImages]) {
            checkmark.image = [UIImage imageNamed:@"checkmark-selected.png"];
            [self.postRepository addImage:url];
        }
    }
    [self.delegate didChangeNumberOfSelectedImagesViewControllerDelegate];
}

- (void) didFinishFindingAllImagesALAssetsRepositoryDelegate:(NSMutableArray *)images {
    self.images = images;
    [self.collectionView reloadData];
}

- (void) didFinishSavingImageALAssetsRepositoryDelegate:(NSURL *)url {
    [self.postRepository addImage:url];
    [self.images insertObject:url atIndex:0];
    [self.collectionView reloadData];
    [self.delegate didChangeNumberOfSelectedImagesViewControllerDelegate];
}

@end
