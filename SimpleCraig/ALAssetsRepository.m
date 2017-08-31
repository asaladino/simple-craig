//
//  ALAssetsRepository.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/27/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "ALAssetsRepository.h"

@implementation ALAssetsRepository

- (id)initWithALAssetsLibrary: (ALAssetsLibrary *) library {
    self = [super init];
    if (self) {
        self.alAssetslibrary = library;
    }
    return self;
}

- (void) findAllImages {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil && [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            NSURL *url= (NSURL*) [[result defaultRepresentation]url];
            if (url != nil) {
                [images insertObject:url atIndex:0];
            }
        }
    };
    
    void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil && [[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [self.delegate didFinishFindingAllImagesALAssetsRepositoryDelegate:images];
        }
    };
    
    void (^assetGroupFail) (NSError *) = ^(NSError *error) {NSLog(@"There is an error");};
    [self.alAssetslibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupFail];
}


- (void) findImageThumb: (NSURL *) url forImageView: (UIImageView *)imageView {
    void (^ loadAssetResult) (ALAsset *) = ^(ALAsset *asset) {
        imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    };
    void (^loadAssetFail) (NSError *) = ^(NSError *error){ NSLog(@"operation was not successfull!"); };
    [self.alAssetslibrary assetForURL:url resultBlock:loadAssetResult failureBlock:loadAssetFail];
}

- (void) findAllImagesForUrls: (NSArray *) urls {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    void (^ loadAssetResult) (ALAsset *) = ^(ALAsset *asset) {
        [images addObject: [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]]];
        if (images.count >= urls.count) {
            [self.delegate didfinishFinishFindingImagesForUrls:images];
        }
    };
    void (^loadAssetFail) (NSError *) = ^(NSError *error){ NSLog(@"operation was not successfull!"); };
    
    for (NSURL *url in urls) {
        [self.alAssetslibrary assetForURL:url resultBlock:loadAssetResult failureBlock:loadAssetFail];
    }
}


- (void) saveImage: (UIImage *) image {
    void (^doneSaving) (NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
            [self.delegate didFinishSavingImageALAssetsRepositoryDelegate: assetURL];
        }
    };
    [self.alAssetslibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:doneSaving];
}

@end
