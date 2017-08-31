//
//  PostViewController.h
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AreasViewController.h"
#import "CategoriesViewController.h"
#import "ImagesViewController.h"
#import "RPFloatingPlaceholderTextField.h"
#import "RPFloatingPlaceholderTextView.h"
#import "BlurryModalSegue.h"

#import "AreaRepository.h"
#import "TypeRepository.h"
#import "CategoryRepository.h"

@interface PostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, AreasViewControllerDelegate, CategoriesViewControllerDelegate, ImagesViewControllerDelegate, ALAssetsRepositoryDelegate>

@property RPFloatingPlaceholderTextField *postTitle;
@property RPFloatingPlaceholderTextField *postPrice;
@property RPFloatingPlaceholderTextField *postSpecificLocation;
@property RPFloatingPlaceholderTextField *postEmail;
@property RPFloatingPlaceholderTextView *postDescription;

@property AreasViewController *areasViewController;
@property CategoriesViewController *categoriesViewController;
@property ImagesViewController *imagesViewController;
@property UIImagePickerController *imagePickerController;


@property (strong, nonatomic) ALAssetsRepository * alAssetsRepository;
@property (strong, nonatomic) PostRepository *postRepository;
@property (strong, nonatomic) AreaRepository *areaRepository;
@property (strong, nonatomic) TypeRepository *typeRepository;
@property (strong, nonatomic) CategoryRepository *categoryRepository;


@property BOOL hiddenStatusBar;
@property BOOL arePhotosHidden;
@property BOOL areToolsDown;
@property BOOL didShowAnotherViewController;
@property BOOL isKeyboardVisible;
@property float photosViewInitialHeight;

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIView *photosView;

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *imagesButton;

@property (weak, nonatomic) IBOutlet UILabel *imageCount;
@property (weak, nonatomic) IBOutlet UIButton *areaButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;


@end
