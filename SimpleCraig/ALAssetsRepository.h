//
//  ALAssetsRepository.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/27/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol ALAssetsRepositoryDelegate;

@interface ALAssetsRepository : NSObject

@property ALAssetsLibrary *alAssetslibrary;
@property (nonatomic, weak) id <ALAssetsRepositoryDelegate> delegate;

- (id)initWithALAssetsLibrary: (ALAssetsLibrary *) library;
- (void) findAllImages;
- (void) findImageThumb: (NSURL *)url forImageView: (UIImageView *)imageView;
- (void) findAllImagesForUrls: (NSArray *) urls;
- (void) saveImage: (UIImage *) image;

@end

@protocol ALAssetsRepositoryDelegate

@optional

- (void) didFinishFindingAllImagesALAssetsRepositoryDelegate: (NSMutableArray *) images;
- (void) didfinishFinishFindingImagesForUrls: (NSMutableArray *) images;
- (void) didFinishSavingImageALAssetsRepositoryDelegate: (NSURL *) url;

@end