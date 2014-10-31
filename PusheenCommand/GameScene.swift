//
//  GameScene.swift
//  PusheenCommand
//
//  Created by alex molinaro on 10/26/14.
//  Copyright (c) 2014 alex molinaro. All rights reserved.
//

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

import SpriteKit
/* Operator Overloading*/
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
/*
Note: You may be wondering what the fancy syntax is here. Note that the category on Sprite Kit is just a single 32-bit integer, and acts as a bitmask. This is a fancy way of saying each of the 32-bits in the integer represents a single category (and hence you can have 32 categories max). Here you’re setting the first bit to indicate a monster, the next bit over to represent a projectile, and so on.*/
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Pusheen   : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let turret = SKSpriteNode(imageNamed: "turret1")
    var pusheensKilled = 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //set our background music to play
        playBackgroundMusic("background-music-aac.caf")
        
        //set our background
        let bkgrnd = SKSpriteNode(imageNamed: "background")
        bkgrnd.setScale(0.5)//scale it down
        //set the position to the middle so it shows the whole image
        bkgrnd.position = CGPointMake(self.size.width/2, self.size.height/2)
        //add out background image to the scene
        addChild(bkgrnd);
        
        //set our player(turrret) position
        turret.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        //turret is kinda big so lets scale it down
        turret.setScale(0.3);
        //add turret to our scene
        addChild(turret)
        
        //Set up our physics world
        physicsWorld.gravity = CGVectorMake(0,0)//makes it so there is no gravity
        physicsWorld.contactDelegate = self // sets the scene to notify when two physics bodies collide
        
        //Interesting piece of code:
        //This effectively creates an SKACtion which will repeat forever
        //Inside we create a sequence which has 2 SKActions within
        //1) SKAction.runBlock runs a block of code (special to swift! we can run a function from a function)
        //2) sets the duration the sequence should wait before running the code again
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addPusheen),SKAction.waitForDuration(1.0)])))
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //play a sound when they touch
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
       //Choose the touch to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        //Set up the initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "desserts")
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Pusheen
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true//Important for fast moving bodies, can sometimes miss
        
        projectile.position = turret.position
        projectile.setScale(0.12)
        //Determine the offset of the touch to the projectile
        let offset = touchLocation - projectile.position
        
        //Bounds checking = Dont shoot if we are shoot behind us or straight up or down
        if(offset.y < 0){return}
        
        //ok we checked position so lets add it
        addChild(projectile)
        
        //get the normalized vector of the direction to shoot
        let direction = offset.normalized()
        
        //make it shoot far enough it goes off screen
        let shootAmount = direction * 1000
        
        //add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        //Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 3.0)
        let actionMoveDone = SKAction.removeFromParent() //IMPORTANT
        projectile.runAction(SKAction.sequence([actionMove,actionMoveDone]))
        
    }
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(#min: CGFloat, max:CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func addPusheen(){
        //create the ugly guy
        let pusheen = SKSpriteNode(imageNamed: "PusheenKitty")
        //Physics properties
        pusheen.physicsBody = SKPhysicsBody(rectangleOfSize: pusheen.size)//Create a physics body for the sprite (depends on your sprite)
        pusheen.physicsBody?.dynamic = true// Set the sprite to be dynamic means we will control the pusheen ourselves with our move actions
        pusheen.physicsBody?.categoryBitMask = PhysicsCategory.Pusheen //Set to the category we defined earlier
        pusheen.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile//Set teh category to which objects notify the contact listener
        pusheen.physicsBody?.collisionBitMask = PhysicsCategory.None //Handles the set of objects which would bounce or collide with  (none in this case)
        
        //Determine where to spawn him along the X axis
        let actualX = random(min: pusheen.size.width/2, max: size.width - pusheen.size.width/2)
        
        //Position him slightly off-screen along the top
        //and using the random position along the X as calculated above
        pusheen.position = CGPoint(x:actualX, y: size.height + pusheen.size.height/2)
        pusheen.setScale(0.25);
        //add him to the scene
        addChild(pusheen)
        
        //Determine how fast he will fall
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        //Create the action
        let actionMove = SKAction.moveTo(CGPoint(x:actualX,y:-pusheen.size.height/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()//MEMORY LEAK LOCATION COULD HAPPEN
        //Create our lose game if a monster goes off screen
        let loseAction = SKAction.runBlock(){
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won:false)
            self.view?.presentScene(gameOverScene,transition:reveal)
        }
        pusheen.runAction(SKAction.sequence([actionMove,loseAction,actionMoveDone]))//Notice LoseAction is before actionMoveDone, This is bc
        //in the scene heirarchy once a sprite is removed from the parent it is no longer in the heriarchy so no longer can have actions done. So 
        //we ont want to remove the sprite until after we displayed the lose scene. REally we dont even need the move done anymore
    }
    
    func projectileDidCollideWithPusheen(projectile:SKSpriteNode, pusheen:SKSpriteNode){
        println("hit")
        projectile.removeFromParent()
        pusheen.removeFromParent()
        
        //win scenario
        pusheensKilled++
        if(pusheensKilled > 30){
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        //We pass in two bodies that collide but they arent guaranteed to be in any particular order
        //so we first check to see what they are and which is which so we can make assumptions  later
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //finally we check to see if the two bodies that collided are the projectile and pusheen . and if so we call the method we jsut wrote
        if((firstBody.categoryBitMask & PhysicsCategory.Pusheen != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)){
            projectileDidCollideWithPusheen(firstBody.node as SKSpriteNode, pusheen: secondBody.node as SKSpriteNode)
        }
    }
}
