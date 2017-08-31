//
//  UploadViewController.h
//  SimpleCraig
//
//  Created by Adam Saladino on 11/26/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "LDProgressView.h"
#import "Post.h"
#import "CraigsListRepository.h"

@interface UploadViewController : UIViewController <CraigsListRepositoryDelegate>

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) CraigsListRepository *craigsListRepository;
@property (strong, nonatomic) LDProgressView *progressView;
@property (weak, nonatomic) IBOutlet SKView *gameView;

@end
