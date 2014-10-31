//
//  GameViewController.swift
//  PusheenCommand
//
//  Created by alex molinaro on 10/26/14.
//  Copyright (c) 2014 alex molinaro. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)//set our window size 
        let skView = view as SKView
        skView.showsPhysics = true // Shows our physics objects for debugging purposes
        skView.showsFPS = true//frames per second
        skView.showsNodeCount = true//shows the curren amount of nodes in our game
        skView.ignoresSiblingOrder = true//optimizations for swift
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}