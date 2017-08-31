//
//  MyScene.m
//  sample1
//
//  Created by Adam Saladino on 11/26/13.
//  Copyright (c) 2013 ellucian. All rights reserved.
//

#import "BreakoutScene.h"

#define kBlockBreakPoints 20
#define kHitBottomPoints -10

@implementation BreakoutScene

static const uint32_t blockCategory =  0x1 << 0;
static const uint32_t ballCategory =  0x1 << 1;
static const uint32_t wallCategory =  0x1 << 2;

- (id) initWithSize: (CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:1.f green:1.f blue:1.f alpha:0.1f];
        //self.physicsWorld.gravity = CGVectorMake(10.f, 10.f);
        self.scaleMode = SKSceneScaleModeAspectFill;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = wallCategory; // 3
        self.physicsBody.contactTestBitMask = ballCategory; // 4
        self.physicsBody.dynamic = YES;
        self.physicsBody.angularDamping = 0.f;
        self.physicsBody.friction = 0.f;
        self.physicsBody.linearDamping = 0.f;
        self.physicsBody.restitution = 1.f;
        self.physicsWorld.contactDelegate = self;
        
        self.score = 0;
        self.blocks = 0;
        self.playing = NO;
        
        self.blockColor = [[SKColor alloc] initWithRed:(0 /255.0) green:(192 /255.0) blue:(255 /255.0) alpha:1.f];
    }
    return self;
}

- (void) didMoveToView: (SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
    self.screanHeight = self.view.frame.size.height;
    [self createGrid];
    [self createPaddle];
    [self createBall];
    [self createScoreBoard];
    [self updateScore];
}

- (void) handlePanFrom: (UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self.paddle setPosition:CGPointMake([self.paddle position].x + translation.x, 24)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.playing) {
        [self start];
        self.playing = YES;
    }
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == ballCategory) {
        //CGVector going = CGVectorMake(1.f, 1.f);
        //[self.ball.physicsBody applyImpulse:going];
    }
    
    if (contact.bodyA.categoryBitMask == wallCategory) {
        if (self.ball.position.y < (self.paddle.position.y - self.paddle.frame.size.height)) {
            self.score += kHitBottomPoints;
            [self.ball removeFromParent];
            self.ball = nil;
            self.playing = NO;
            [self createBall];
            [self updateScore];
        }
    }
    
    if (contact.bodyA.categoryBitMask == blockCategory) {
        [contact.bodyA.node removeFromParent];
        self.score += kBlockBreakPoints;
        self.blocks--;
        NSLog(@"blocks remaining: %i", self.blocks);
        [self updateScore];
        if (self.blocks == 0) {
            [self.ball removeFromParent];
            self.ball = nil;
            self.playing = NO;
            [self createGrid];
            [self createBall];
        }
    }
}

- (void) createScoreBoard {
    self.scoreBoard = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext"];
    self.scoreBoard.fontSize = 18;
    self.scoreBoard.position = CGPointMake((self.size.width / 2), 1);
    self.scoreBoard.fontColor = [SKColor blackColor];
    [self addChild:self.scoreBoard];
}

- (void) updateScore {
    self.scoreBoard.text = [[NSString alloc] initWithFormat:@"Score: %i", self.score];
}


- (void) createGrid {
    int rows = 4;
    int columns = 5;
    for (int row = 0; row < rows; row++) {
        for (int column = 0; column < columns; column++) {
            [self createBlock:(((column * 64) * 1.f) + 32) withRow:(_screanHeight - 70 - (row * 20) - 9)];
        }
    }
}

- (void) createBlock: (int) column withRow: (int) row {
    SKSpriteNode *block = [SKSpriteNode spriteNodeWithColor:self.blockColor size:CGSizeMake(62, 18)];
    block.position = CGPointMake(column, row);
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.categoryBitMask = blockCategory; // 3
    block.physicsBody.contactTestBitMask = ballCategory; // 4
    block.physicsBody.affectedByGravity = NO;
    block.physicsBody.dynamic = NO; // 2
    block.physicsBody.angularDamping = 0.f;
    block.physicsBody.linearDamping = 0.f;
    block.physicsBody.friction = 0.f;
    block.physicsBody.restitution = 1.f;//1.f;
    self.blocks++;
    [self addChild:block];
}

- (void) createPaddle {
    self.paddle = [SKSpriteNode spriteNodeWithColor:self.blockColor size:CGSizeMake(62, 8)];
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.size];
    self.paddle.position = CGPointMake((self.size.width / 2), 24);
    self.paddle.physicsBody.categoryBitMask = wallCategory; // 3
    self.paddle.physicsBody.contactTestBitMask = ballCategory; // 4
    self.paddle.physicsBody.affectedByGravity = NO;
    self.paddle.physicsBody.dynamic = NO; // 2
    self.paddle.physicsBody.linearDamping = 0.f;
    self.paddle.physicsBody.angularDamping = 0.f;
    self.paddle.physicsBody.restitution = 1.f;
    [self addChild:self.paddle];
}


- (void) createBall {
    self.ball = [[SKShapeNode alloc] init];
    self.ball.position = CGPointMake((self.size.width / 2), 100);
    CGMutablePathRef myPath = CGPathCreateMutable();
    CGPathAddArc(myPath, NULL, 0,0, 8, 0, M_PI*2, YES);
    self.ball.path = myPath;
    self.ball.fillColor = self.blockColor;
    
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:8.f];
    self.ball.physicsBody.restitution = 0.f;
    self.ball.physicsBody.affectedByGravity = NO;
    self.ball.physicsBody.dynamic = YES; // 2
    self.ball.physicsBody.angularDamping = 0.f;
    self.ball.physicsBody.linearDamping = 0.f;
    self.ball.physicsBody.friction = 0.f;
    self.ball.physicsBody.categoryBitMask = ballCategory; // 3
    
    [self addChild:self.ball];
}

- (void) start {
    [self.ball.physicsBody applyForce:CGVectorMake(200.f, 200.f)];
}

@end
