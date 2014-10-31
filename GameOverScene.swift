//
//  GameOverScene.swift
//  PusheenCommand
//
//  Created by alex molinaro on 10/26/14.
//  Copyright (c) 2014 alex molinaro. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // Sets our background color to white
        backgroundColor = SKColor.whiteColor()
        
        // Based upon our won parameter to set the message to either win or lose
        var message = won ? "You Won!" : "You Lose :["
        
        // this is how to display a label
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // Inline function handy no? First it waits for 3 seconds
        //then uses runBlcok to execute a block of code
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // This is how you transition into a new scene. There are a variety of didfferent animated transitions for how
                //your scene can display. You create the scene you want to display, use the self.view property
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // If we override an initializer on a scene, you have to implement this code below, however
    //this initializer is never called so we just add dummy fatal error code for now
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}