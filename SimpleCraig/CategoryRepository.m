//
//  CategoryRepository.m
//  SimpleCraig
//
//  Created by Adam Saladino on 12/20/13.
//  Copyright (c) 2013 StudioMDS. All rights reserved.
//

#import "CategoryRepository.h"

@implementation CategoryRepository

- (NSArray *) findAll {
    return @[
             [[Category alloc] initWithValue:@"150" andName:@"antiques"],
             [[Category alloc] initWithValue:@"149" andName:@"appliances"],
             [[Category alloc] initWithValue:@"135" andName:@"arts & crafts"],
             [[Category alloc] initWithValue:@"191" andName:@"atvs, utvs, snowmobiles"],
             [[Category alloc] initWithValue:@"122" andName:@"auto parts"],
             [[Category alloc] initWithValue:@"107" andName:@"baby & kid stuff"],
             [[Category alloc] initWithValue:@"42" andName:@"barter"],
             [[Category alloc] initWithValue:@"68" andName:@"bicycles"],
             [[Category alloc] initWithValue:@"119" andName:@"boats"],
             [[Category alloc] initWithValue:@"92" andName:@"books & magazines"],
             [[Category alloc] initWithValue:@"134" andName:@"business/commercial"],
             [[Category alloc] initWithValue:@"145" andName:@"cars & trucks"],
             [[Category alloc] initWithValue:@"117" andName:@"cds / dvds / vhs"],
             [[Category alloc] initWithValue:@"153" andName:@"cell phones"],
             [[Category alloc] initWithValue:@"94" andName:@"clothing & accessories"],
             [[Category alloc] initWithValue:@"95" andName:@"collectibles"],
             [[Category alloc] initWithValue:@"7" andName:@"computers"],
             [[Category alloc] initWithValue:@"96" andName:@"electronics"],
             [[Category alloc] initWithValue:@"133" andName:@"farm & garden"],
             [[Category alloc] initWithValue:@"101" andName:@"free stuff"],
             [[Category alloc] initWithValue:@"141" andName:@"furniture"],
             [[Category alloc] initWithValue:@"73" andName:@"garage & moving sales"],
             [[Category alloc] initWithValue:@"5" andName:@"general for sale"],
             [[Category alloc] initWithValue:@"152" andName:@"health and beauty"],
             [[Category alloc] initWithValue:@"193" andName:@"heavy equipment"],
             [[Category alloc] initWithValue:@"97" andName:@"household items"],
             [[Category alloc] initWithValue:@"120" andName:@"jewelry"],
             [[Category alloc] initWithValue:@"136" andName:@"materials"],
             [[Category alloc] initWithValue:@"195" andName:@"motorcycle parts & accessories"],
             [[Category alloc] initWithValue:@"69" andName:@"motorcycles/scooters"],
             [[Category alloc] initWithValue:@"98" andName:@"musical instruments"],
             [[Category alloc] initWithValue:@"137" andName:@"photo/video"],
             [[Category alloc] initWithValue:@"124" andName:@"rvs"],
             [[Category alloc] initWithValue:@"93" andName:@"sporting goods"],
             [[Category alloc] initWithValue:@"44" andName:@"tickets"],
             [[Category alloc] initWithValue:@"118" andName:@"tools"],
             [[Category alloc] initWithValue:@"132" andName:@"toys & games"],
             [[Category alloc] initWithValue:@"151" andName:@"video gaming"],
             [[Category alloc] initWithValue:@"20" andName:@"wanted"]];
}

- (Category *) findDefault {
    NSArray *categories = [self findAll];
    for (Category * category in categories) {
        if ([category.value isEqualToString:kCategoryRepositoryDefault]) {
            return category;
        }
    }
    return [categories firstObject];
}

@end
