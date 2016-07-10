//
//  Ghost.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Ghost:SKSpriteNode {
    var ghostColor = ""
    //NEED GHOST ANIMATIONS AND SOUNDS
    func setUp() {
        let textures = [SKTexture(imageNamed: "Ghost_" + ghostColor + "1"),SKTexture(imageNamed: "Ghost_" + ghostColor + "2"),SKTexture(imageNamed: "Ghost_" + ghostColor + "3"),SKTexture(imageNamed: "Ghost_" + ghostColor + "4")]
        let action1 = SKAction.animateWithTextures(textures, timePerFrame: 0.3, resize: true, restore: true)
        let action2 = SKAction.sequence([SKAction.moveBy(CGVector(dx: 20, dy: 25), duration: 0.59),SKAction.moveBy(CGVector(dx: -20, dy: 25), duration: 0.59)])
        let action3 = SKAction.fadeOutWithDuration(3)
        
        runAction(SKAction.playSoundFileNamed("pikminGhost", waitForCompletion: false))
        runAction(SKAction.repeatActionForever(action1))
        runAction(SKAction.repeatActionForever(action2))
        runAction(action3, completion:{
            self.removeAllActions()
            self.removeAllChildren()
            self.removeFromParent()
        })
    }
}