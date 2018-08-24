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
        let textures = [ghostAtlas.textureNamed("Ghost_" + ghostColor + "1"),ghostAtlas.textureNamed("Ghost_" + ghostColor + "2"),ghostAtlas.textureNamed("Ghost_" + ghostColor + "3"),ghostAtlas.textureNamed("Ghost_" + ghostColor + "4")]
        let action1 = SKAction.animate(with: textures, timePerFrame: 0.3, resize: true, restore: true)
        let action2 = SKAction.sequence([SKAction.move(by: CGVector(dx: 20, dy: 25), duration: 0.59),SKAction.move(by: CGVector(dx: -20, dy: 25), duration: 0.59)])
        let action3 = SKAction.fadeOut(withDuration: 3)
        
        run(SKAction.playSoundFileNamed("pikminGhost", waitForCompletion: false))
        run(SKAction.repeatForever(action1))
        run(SKAction.repeatForever(action2))
        run(action3, completion:{
            self.removeAllActions()
            self.removeAllChildren()
            self.removeFromParent()
        })
    }
}
