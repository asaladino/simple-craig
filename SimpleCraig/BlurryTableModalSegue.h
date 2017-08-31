//
//  BlurryTableModalSegue.h
//  SimpleCraig
//
//  Created by Adam Saladino on 12/30/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BlurryTableModalSegue;

typedef UIImage*(^ProcessBackgroundImage)(BlurryTableModalSegue* blurryModalSegue, UIImage* rawImage);

@interface BlurryTableModalSegue : UIStoryboardSegue

@property (nonatomic, copy) ProcessBackgroundImage processBackgroundImage;

@property (nonatomic) NSNumber* backingImageBlurRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSNumber* backingImageSaturationDeltaFactor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor* backingImageTintColor UI_APPEARANCE_SELECTOR;

+ (id)appearance;


@end
