//
//  GameViewController.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/30/16.
//  Copyright (c) 2016 Bryan Mazariegos. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var gameScene:GameScene!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            skView.presentScene(scene)
            gameScene = scene
        }
    }

    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        gameScene.pressesBegan(presses, withEvent: event)
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        gameScene.pressesEnded(presses, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
