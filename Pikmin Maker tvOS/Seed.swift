//
//  Seed.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Seed:SKSpriteNode {
    var seedColor = "Red"
    var seedTier = "Leaf"
    var rooted = false
    var pikminIdleLook = SKSpriteNode()
    var pikminPluck = SKAction.playSoundFileNamed("pikminPluck", waitForCompletion: false)
    
    func unrootPikmin(player:Player) {
        if rooted {
            self.runAction(self.pikminPluck,completion: {
                let NewPikmin = Pikmin(imageNamed: "Pikmin_" + self.seedColor + "_Down_Stand")
                NewPikmin.direction = "Down"
                NewPikmin.position = self.position
                NewPikmin.pikminColor = self.seedColor
                self.parent!.addChild(NewPikmin)
                NewPikmin.pikminTier = self.seedTier
                NewPikmin.setUp()
                NewPikmin.leader = player
                let rand = CGFloat(arc4random_uniform(2) + 1)
                NewPikmin.zPosition = BackLayer + rand
                player.pikminFollowing.append(NewPikmin)
                if self.parent is GameScene {
                    let parent = self.parent as! GameScene
                    parent.existingPikmin.append(NewPikmin)
                }
                self.removeFromParent()
            })
        }
    }
}