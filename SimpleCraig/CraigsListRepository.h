//
//  CraigsInterface.h
//  SimpleCraig
//
//  Created by Adam Saladino on 7/16/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraigsPostListItem.h"
#import "Post.h"

@protocol CraigsListRepositoryDelegate;

enum CraigsListRepositoryState {
    CraigsListRepositoryStateFindAreas,
    CraigsListRepositoryStateSetAreaAndFindTypes,
    CraigsListRepositoryStateSetTypeAndFindCategories,
    CraigsListRepositoryStateSetCategoryLoadInformationForm,
    CraigsListRepositoryStateSetPostInformationAndLoadImageForm,
    CraigsListRepositoryStateSetPostFinishedWithImages,
    CraigsListRepositoryStateSubmitFinalPost
};

@interface CraigsListRepository : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) id<CraigsListRepositoryDelegate> delegate;

/**
 * What's going on?
 */
@property enum CraigsListRepositoryState currentState;

@property (nonatomic, strong) Post *post;

- (void) save: (Post *) post;

/**
 * Area post information
 */
@property (nonatomic, strong) NSMutableArray *areas;

@property (nonatomic, strong) NSString *areaFormAction;
@property (nonatomic, strong) NSString *areaInputName;
@property (nonatomic, strong) NSString *areaInputHiddenName;
@property (nonatomic, strong) NSString *areaInputHiddenValue;

/**
 * Type form post information
 */
@property (nonatomic, strong) NSMutableArray *types;

@property (nonatomic, strong) NSString *typeFormAction;
@property (nonatomic, strong) NSString *typeInputName;
@property (nonatomic, strong) NSString *typeInputHiddenName;
@property (nonatomic, strong) NSString *typeInputHiddenValue;

/**
 * Category form post information
 */
@property (nonatomic, strong) NSMutableArray *categories;

@property (nonatomic, strong) NSString *categoryFormAction;
@property (nonatomic, strong) NSString *categoryInputName;
@property (nonatomic, strong) NSString *categoryInputHiddenName;
@property (nonatomic, strong) NSString *categoryInputHiddenValue;

/**
 * Post information form
 */
@property (nonatomic, strong) NSString *informationPostFormAction;
@property (nonatomic, strong) NSString *informationPostInputHiddenName;
@property (nonatomic, strong) NSString *informationPostInputHiddenValue;

/**
 * Image form post information
 */
@property (nonatomic, strong) NSString *imageFormAction;
@property (nonatomic, strong) NSString *imageInputHiddenName;
@property (nonatomic, strong) NSString *imageInputHiddenValue;


/**
 * Done with iamge form post information
 */
@property (nonatomic, strong) NSString *doneWithImageFormAction;
@property (nonatomic, strong) NSString *doneWithImageInputHiddenName;
@property (nonatomic, strong) NSString *doneWithImageInputHiddenValue;


/**
 * Finish with post form post information
 */

@property (nonatomic, strong) NSString *finishFormAction;
@property (nonatomic, strong) NSString *finishInputHiddenName;
@property (nonatomic, strong) NSString *finishInputHiddenValue;

/**
 * Connection stores
 */
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *conn;

/**
 * Load all the list
 */

- (void) runTests;

@end


@protocol CraigsListRepositoryDelegate

@optional

- (void) craigsListRepositoryFindAreasTypesCategoriesFinished: (NSURLConnection *)connection;
- (void) craigsListRepositoryFindAreasFinished: (NSURLConnection *)connection;
- (void) craigsListRepositorySetAreaAndFindTypesFinished: (NSURLConnection *)connection;
- (void) craigsListRepositorySetTypeAndFindCategoriesFinished: (NSURLConnection *)connection;
- (void) craigsListRepositorySetCategoryAndLoadInformationFormFinished: (NSURLConnection *)connection;
- (void) craigsListRepositorySetPostInformationAndLoadImageFormFinished: (NSURLConnection *)connection;
- (void) craigsListRepositoryAddImageFinished: (NSURLConnection *)connection;
- (void) craigsListRepositoryDoneWithImagesFinished: (NSURLConnection *)connection;
- (void) craigsListRepositorySubmitFinalPost: (NSURLConnection *)connection;


- (void) craigsListRepositoryFindAreasTypesCategoriesError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositoryFindAreasError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositorySetAreaAndFindTypesError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositorySetTypeAndFindCategoriesError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositorySetCategoryAndLoadInformationFormError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositorySetPostInformationAndLoadImageFormError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositoryAddImageError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositoryDoneWithImagesError: (NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void) craigsListRepositorySubmitFinalPost: (NSURLConnection *)connection didFailWithError:(NSError *)error;


@end



