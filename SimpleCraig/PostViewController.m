//
//  PostViewController.m
//  SimpleCraig
//
//  Created by Adam Saladino on 11/24/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "PostViewController.h"

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AreaRepository.h"
#import "CraigsListRepository.h"
#import "UploadViewController.h"


@implementation PostViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initInputFields];
    [self initStatusbar];
    [self initToolbar];
    [self initPhotosView];
    [self initImagePickerController];
    [self updateImageCount];
    [self runTest];
}

- (void) runTest {
    CraigsListRepository *repo = [[CraigsListRepository alloc] init];
    [repo runTests];
}

- (void) viewWillAppear: (BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void) viewDidAppear: (BOOL)animated {
    [super viewDidAppear:animated];
    [self initToolAndPhotosViewState];
}

- (void) viewWillDisappear: (BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark - Manage Segues

- (void) prepareForSegue: (UIStoryboardSegue *)segue sender: (id)sender {
    if ([[segue identifier] isEqualToString:@"areas"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        self.areasViewController = (AreasViewController *)[navController topViewController];
        self.areasViewController.settingRepository = self.postRepository;
        self.areasViewController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"category"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
        self.categoriesViewController = (CategoriesViewController *)[navController topViewController];
        self.categoriesViewController.settingRepository = self.postRepository;
        self.categoriesViewController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"images"]) {
        self.didShowAnotherViewController = NO;
        self.imagesViewController = (ImagesViewController *)[segue destinationViewController];
        self.imagesViewController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"upload"]) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.postRepository.post.price = [f numberFromString:self.postPrice.text];
        self.postRepository.post.title = self.postTitle.text;
//        self.postRepository.post.description = self.postDescription.text;
        self.postRepository.post.email = self.postEmail.text;
        self.postRepository.post.specificLocation = self.postSpecificLocation.text;
        
        NSLog(@"preparing for segue");
        UploadViewController *uploadViewController = (UploadViewController*)[segue destinationViewController];
        uploadViewController.post = self.postRepository.post;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"upload"]) {
        [self.alAssetsRepository findAllImagesForUrls:self.postRepository.post.currentImages];
        return YES;
    }
    return YES;
}


- (void) didfinishFinishFindingImagesForUrls: (NSMutableArray *) images {
    self.postRepository.post.fullImages = images;
    [self performSegueWithIdentifier:@"upload" sender:self];
}

#pragma mark - Areas / Types / Images delegates

- (void) closeAreasViewController {
    [self.areaButton setTitle:[self.postRepository getCurrentAreaDisplayName] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self initStatusbar];
}

- (void) closeCategoriesViewController {
    [self.categoryButton setTitle:[self.postRepository getCurrentCategoryDisplayName] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self initStatusbar];
}

- (void) didChangeNumberOfSelectedImagesViewControllerDelegate {
    [self updateImageCount];
}

#pragma mark - Initialize Display Elements

- (void) initData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.postRepository = appDelegate.postRepository;
    self.typeRepository = [[TypeRepository alloc] init];
    self.categoryRepository = [[CategoryRepository alloc] init];
    self.areaRepository = [[AreaRepository alloc] init];
    self.alAssetsRepository = [[ALAssetsRepository alloc] initWithALAssetsLibrary:[[ALAssetsLibrary alloc] init]];
    self.alAssetsRepository.delegate = self;
    
    [self.postRepository setCurrentArea:[self.areaRepository findDefault]];
    [self.postRepository setCurrentCategory:[self.categoryRepository findDefault]];
    [self.postRepository setCurrentType:[self.typeRepository findDefault]];
    
    [self.areaButton setTitle:[self.postRepository getCurrentAreaDisplayName] forState:UIControlStateNormal];
    [self.categoryButton setTitle:[self.postRepository getCurrentCategoryDisplayName] forState:UIControlStateNormal];
}

- (void) initToolbar {
    self.toolView.backgroundColor = [[UIColor alloc] initWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1.0f];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.toolView.frame.size.width, 1)];
    topLine.backgroundColor = [[UIColor alloc] initWithRed:(199/255.0) green:(199/255.0) blue:(199/255.0) alpha:1.0f];
    [self.toolView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, (self.toolView.frame.size.height), self.view.frame.size.width, 1)];
    bottomLine.backgroundColor = [[UIColor alloc] initWithRed:(183/255.0) green:(183/255.0) blue:(183/255.0) alpha:1.0f];
    [self.toolView addSubview:bottomLine];
    [self.view bringSubviewToFront:self.toolView];
}

- (void) initInputFields {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    float height = 40.f;
    float heightLabel = 10.f;
    float margin = 15.f;
    float positionX = 120.f;
    float widthFull = appDelegate.window.frame.size.width - (2*margin);
    
    UIColor *grayLineColor = [[UIColor alloc] initWithRed:(200/255.0) green:(200/255.0) blue:(200/255.0) alpha:1.0f];
    UIColor *textColor = [[UIColor alloc] initWithRed:(51 /255.0) green:(51 /255.0) blue:(51 /255.0) alpha:1.f];
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:14.f];
    
    _postTitle = [[RPFloatingPlaceholderTextField alloc] initWithFrame:CGRectMake(margin, positionX, (widthFull*.7), (height-heightLabel))];
    _postTitle.floatingLabelActiveTextColor = appDelegate.window.tintColor;
    _postTitle.floatingLabelInactiveTextColor = [UIColor grayColor];
    _postTitle.placeholder = @"Title";
    _postTitle.text = @"Awesome Bed";
    _postTitle.font = textFont;
    _postTitle.floatingLabel.textColor = textColor;
    //[_postTitle becomeFirstResponder];
    [self.view addSubview:_postTitle];
    
    _postPrice = [[RPFloatingPlaceholderTextField alloc] initWithFrame:CGRectMake((margin + (widthFull*.7)), positionX, (widthFull*.3), (height-heightLabel))];
    _postPrice.floatingLabelActiveTextColor = appDelegate.window.tintColor;
    _postPrice.floatingLabelInactiveTextColor = [UIColor grayColor];
    _postPrice.placeholder = @"Price";
    _postPrice.text = @"90.00";
    _postPrice.font = textFont;
    _postPrice.floatingLabel.textColor = textColor;
    _postPrice.keyboardType = UIKeyboardTypeDecimalPad;
    [self.view addSubview:_postPrice];
    
    UIView *priceLine = [[UIView alloc] initWithFrame:CGRectMake((margin + (widthFull*.7)), (positionX - heightLabel), 1, height)];
    priceLine.backgroundColor = grayLineColor;
    [self.view addSubview:priceLine];
    
    positionX += height;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(margin, (positionX - heightLabel), widthFull, 1)];
    lineView.backgroundColor = grayLineColor;
    [self.view addSubview:lineView];
    
    _postSpecificLocation = [[RPFloatingPlaceholderTextField alloc] initWithFrame:CGRectMake((margin + (widthFull*.6)), positionX, (widthFull*.4), (height-heightLabel))];
    _postSpecificLocation.floatingLabelActiveTextColor = appDelegate.window.tintColor;
    _postSpecificLocation.floatingLabelInactiveTextColor = [UIColor grayColor];
    _postSpecificLocation.placeholder = @"Specific location (optional)";
    _postSpecificLocation.text = @"here";
    _postSpecificLocation.font = textFont;
    _postSpecificLocation.floatingLabel.textColor = textColor;
    [self.view addSubview:_postSpecificLocation];
    
    self.postEmail = [[RPFloatingPlaceholderTextField alloc] initWithFrame:CGRectMake(margin, positionX, (widthFull*.6), (height-heightLabel))];
    self.postEmail.floatingLabelActiveTextColor = appDelegate.window.tintColor;
    self.postEmail.floatingLabelInactiveTextColor = [UIColor grayColor];
    self.postEmail.placeholder = @"Email";
    self.postEmail.text = @"your.email@here.com";
    self.postEmail.font = textFont;
    self.postEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.postEmail.floatingLabel.textColor = textColor;
    self.postEmail.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.postEmail];
    
    UIView *locationLine = [[UIView alloc] initWithFrame:CGRectMake((margin + (widthFull*.6)), (positionX - heightLabel), 1, height)];
    locationLine.backgroundColor = grayLineColor;
    [self.view addSubview:locationLine];
    
    positionX += height;
    UIView *lineDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(margin, (positionX - heightLabel), widthFull, 1)];
    lineDescriptionView.backgroundColor = grayLineColor;
    [self.view addSubview:lineDescriptionView];
    
    _postDescription = [[RPFloatingPlaceholderTextView alloc] initWithFrame:CGRectMake(margin, positionX + 10, widthFull, (height + 60))];
    _postDescription.floatingLabelActiveTextColor = appDelegate.window.tintColor;
    _postDescription.floatingLabelInactiveTextColor = [UIColor grayColor];
    _postDescription.placeholder = @"Description";
    _postDescription.text = @"You will want this.";
    _postDescription.font = textFont;
    _postDescription.floatingLabel.textColor = textColor;
    [self.view addSubview:_postDescription];
}

- (void)initPhotosView {
    self.photosView.backgroundColor = [[UIColor alloc] initWithRed:(45/255.0) green:(48/255.0) blue:(53/255.0) alpha:1.0f];
    [self.view bringSubviewToFront:self.photosView];
    self.photosViewInitialHeight = self.photosView.frame.size.height;
}

- (void) initToolAndPhotosViewState {
    if (!self.didShowAnotherViewController) {
        self.arePhotosHidden = YES;
        self.areToolsDown = YES;
        self.cameraButton.hidden = NO;
        [self hideToolView];
        [self hidePhotosView];
        [UIView commitAnimations];
    }
    self.didShowAnotherViewController = NO;
}

#pragma mark - Transitions

- (void)hideToolView {
    CGRect toolViewFrame = self.toolView.frame;
    toolViewFrame.origin.y += self.photosView.frame.size.height;
    [self defaultAnimation];
    self.toolView.frame = toolViewFrame;
    self.areToolsDown = YES;
}

- (void)showToolView {
    CGRect toolViewFrame = self.toolView.frame;
    toolViewFrame.origin.y -= self.photosView.frame.size.height;
    [self defaultAnimation];
    self.toolView.frame = toolViewFrame;
    self.areToolsDown = NO;
}

- (void)hidePhotosView {
    CGRect photosViewFrame = self.photosView.frame;
    photosViewFrame.origin.y += self.photosView.frame.size.height;
    [self defaultAnimation];
    self.photosView.frame = photosViewFrame;
    self.arePhotosHidden = YES;
}

- (void)showPhotosView {
    CGRect photosViewFrame = self.photosView.frame;
    photosViewFrame.origin.y -= self.photosView.frame.size.height;
    [self defaultAnimation];
    self.photosView.frame = photosViewFrame;
    self.arePhotosHidden = NO;
}

- (void) defaultAnimation {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
}

- (void) toggleToolsAndPhotos {
    if (self.arePhotosHidden) {
        [self showPhotosView];
        [self showToolView];
    } else {
        [self hidePhotosView];
        [self hideToolView];
    }
    [UIView commitAnimations];
}

- (void)dismissKeyboard {
    [self.postTitle resignFirstResponder];
    [self.postPrice resignFirstResponder];
    [self.postSpecificLocation resignFirstResponder];
    [self.postDescription resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    //_twitterButton.hidden = NO;
    //_facebookButton.hidden = NO;
    self.isKeyboardVisible = YES;
    if (self.arePhotosHidden) {
        UIViewAnimationCurve keyboardTransitionAnimationCurve;
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
        
        [self showPhotosView];
        [self showToolView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:keyboardTransitionAnimationCurve];
        
        [UIView commitAnimations];
    }
}

#pragma mark - Hiding the status bar

- (void)initStatusbar {
    self.hiddenStatusBar = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:_hiddenStatusBar withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return self.hiddenStatusBar;
}

- (void) updateImageCount {
    int count = [self.postRepository findAllImages].count;
    if ([self.postRepository findAllImages].count > 0) {
        self.imageCount.text = [[NSString alloc] initWithFormat:@"%i", count];
    } else {
        self.imageCount.text = @"Select up to 8 photos";
    }
}

#pragma mark - Actions

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    //NSLog(@"%f, %f, %f", recognizer.view.frame.origin.y + translation.y, self.view.frame.size.height, self.photosViewInitialHeight);
    if (recognizer.view.frame.origin.y + translation.y > 63 &&
        recognizer.view.frame.origin.y + translation.y < self.view.frame.size.height - recognizer.view.frame.size.height + 1) {
        
        // Move the photos view
        CGRect photosViewFrame = self.photosView.frame;
        photosViewFrame.origin.y += translation.y;
        
        CGRect collectionViewFrame = self.imagesViewController.collectionView.frame;
        // resize the photos view
        if (recognizer.view.frame.origin.y + translation.y + recognizer.view.frame.size.height <= self.view.frame.size.height - self.photosViewInitialHeight) {
            //NSLog(@"resizing photos view: %f", photosViewFrame.size.height);
            photosViewFrame.size.height -= translation.y;
            
            
            collectionViewFrame.size.height -= translation.y;
        }
        self.photosView.frame = photosViewFrame;
        self.imagesViewController.collectionView.frame = collectionViewFrame;
        [self.imagesViewController.collectionView invalidateIntrinsicContentSize];
        
        // Move the toolview
        recognizer.view.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        
    }
    
}

- (IBAction)showImages:(id)sender {
    if (self.isKeyboardVisible) {
        [self dismissKeyboard];
        self.isKeyboardVisible = NO;
    } else {
        [self toggleToolsAndPhotos];
    }
    //[[UIApplication sharedApplication] setStatusBarHidden:_hiddenStatusBar withAnimation:UIStatusBarAnimationSlide];
    //_twitterButton.hidden = YES;
    //_facebookButton.hidden = YES;
}

- (IBAction)tweetPost:(id)sender {
}

- (IBAction)facebookPost:(id)sender {
}

- (IBAction)loadCamera:(id)sender {
#if !(TARGET_IPHONE_SIMULATOR)
    self.didShowAnotherViewController = YES;
    if (self.arePhotosHidden) {
        [self showPhotosView];
        [self showToolView];
        [UIView commitAnimations];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
#endif
}

- (void) initImagePickerController {
#if !(TARGET_IPHONE_SIMULATOR)
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
#endif
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.imagesViewController saveImage: image];
    }
}


@end
