//
//  GameViewController.swift
//  Pikmin Maker iOS
//
//  Created by Bryan Mazariegos on 4/30/16.
//  Copyright (c) 2016 Bryan Mazariegos. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ghostAtlas.preload(completionHandler: {
            print("Ghost Atlas Loaded!")
        })
        machineAtlas.preload(completionHandler: {
            print("Machine Atlas Loaded!")
        })
        monsterAtlas.preload(completionHandler: {
            print("Monster Atlas Loaded!")
        })
        pikminAtlas.preload(completionHandler: {
            print("Pikmin Atlas Loaded!")
        })
        playerAtlas.preload(completionHandler: {
            print("Player Atlas Loaded!")
        })
        worldAtlas.preload(completionHandler: {
            print("World Atlas Loaded!")
        })
        
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .resizeFill
            
            skView.presentScene(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
