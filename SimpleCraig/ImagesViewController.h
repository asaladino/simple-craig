//
//  Images.h
//  SimpleCraig
//
//  Created by Adam Saladino on 11/25/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsRepository.h"
#import "PostRepository.h"


@protocol ImagesViewControllerDelegate;

@interface ImagesViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, ALAssetsRepositoryDelegate>

//@property CraigsInterface *craigsInterface;

@property ALAssetsLibrary *library;
@property NSMutableArray *images;
@property (nonatomic, weak) id <ImagesViewControllerDelegate> delegate;

@property ALAssetsRepository * alAssetsRepository;
@property PostRepository *postRepository;

- (void) saveImage: (UIImage *) image;

@end


@protocol ImagesViewControllerDelegate

- (void) didChangeNumberOfSelectedImagesViewControllerDelegate;

@end