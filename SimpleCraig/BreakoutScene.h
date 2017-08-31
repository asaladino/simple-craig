//
//  MyScene.h
//  sample1
//

//  Copyright (c) 2013 ellucian. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BreakoutScene : SKScene <SKPhysicsContactDelegate>

@property SKSpriteNode *paddle;
@property SKShapeNode *ball;
@property SKLabelNode *scoreBoard;
@property SKColor *blockColor;
@property BOOL playing;
@property float screanHeight;

@property int score;
@property int blocks;

@end
