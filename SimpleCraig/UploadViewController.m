//
//  UploadViewController.m
//  SimpleCraig
//
//  Created by Adam Saladino on 11/26/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "UploadViewController.h"
#import "BreakoutScene.h"
#import "AppDelegate.h"

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBreakout];
    [self initProgressView];
    [self initData];
}

- (void) initBreakout {
    _gameView.showsFPS = YES;
    _gameView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [BreakoutScene sceneWithSize:self.gameView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    //Present the scene.
    [self.gameView presentScene:scene];
}

- (void) initProgressView {
    self.progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(15, 44, self.view.frame.size.width-30, 10)];
    self.progressView.progress = 0.40;
    self.progressView.borderRadius = @0;
    self.progressView.showText = @NO;
    self.progressView.flat = @YES;
    self.progressView.type = LDProgressSolid;
    self.progressView.color = [[UIColor alloc] initWithRed:(45/255.0) green:(48/255.0) blue:(53/255.0) alpha:1.0f];
    [self.view addSubview:self.progressView];
}

- (void) initData {
    self.craigsListRepository = [[CraigsListRepository alloc] init];
    // [self.craigsListRepository save:self.post];
}

- (IBAction)closeAndCancelUpload:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark - Craigslist Repository upload progress delegation.
- (void) craigsListRepositoryFindAreasTypesCategoriesFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositoryFindAreasFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositorySetAreaAndFindTypesFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositorySetTypeAndFindCategoriesFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositorySetCategoryAndLoadInformationFormFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositorySetPostInformationAndLoadImageFormFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositoryAddImageFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositoryDoneWithImagesFinished: (NSURLConnection *)connection {
    
}
- (void) craigsListRepositorySubmitFinalPost: (NSURLConnection *)connection {
    
}

- (void) craigsListRepositoryFindAreasTypesCategoriesError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositoryFindAreasError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositorySetAreaAndFindTypesError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositorySetTypeAndFindCategoriesError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositorySetCategoryAndLoadInformationFormError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositorySetPostInformationAndLoadImageFormError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositoryAddImageError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositoryDoneWithImagesError: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}
- (void) craigsListRepositorySubmitFinalPost: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}


@end
