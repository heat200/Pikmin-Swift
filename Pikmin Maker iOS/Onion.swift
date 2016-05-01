//
//  Onion.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Onion:SKSpriteNode {
    var onionColor = "Red"
    var awake = false
    var awakened = false
    
    func randomizePosition() {
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)

        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
    
    func wake() {
        if !awake {
            awake = true
            runAction(SKAction.moveBy(CGVector(dx: 0, dy: 100), duration: 2), completion:{
                self.runAction(SKAction.setTexture(SKTexture(imageNamed:"Onion_" + self.onionColor), resize: true),completion:{
                    self.position.y -= 40
                    self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_" + self.onionColor),SKTexture(imageNamed:"Onion_" + self.onionColor + "2")], timePerFrame: 0.9, resize: true, restore: true)))
                    self.awakened = true
                    self.dispelSeed()
                })
            })
        }
    }
    
    func dispelSeed() {
        if awakened {
            let randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
            
            let seed = Seed(imageNamed:"Seed_" + onionColor + "_Falling2")
            seed.zPosition = FrontLayer
            seed.seedColor = onionColor
            let original = CGFloat(seed.zRotation)
            seed.zRotation = CGFloat(M_PI * 3)
            seed.position.x = self.position.x
            seed.position.y = self.position.y + 50
            seed.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Seed_" + onionColor + "_Falling1"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling2"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling3"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
            
            if randX > 0 {
                seed.runAction(SKAction.rotateToAngle(original, duration: 0.8,shortestUnitArc:true))
            } else {
                seed.runAction((SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.8)))
            }
            
            seed.pikminIdleLook.runAction(SKAction.setTexture(SKTexture(imageNamed:seed.seedColor + "Glow"), resize: true))
            seed.pikminIdleLook.setScale(1)
            seed.pikminIdleLook.zPosition = -1
            seed.pikminIdleLook.hidden = true
            let group = SKAction.sequence([SKAction.scaleTo(1.9, duration: 0.75),SKAction.scaleTo(2.4, duration: 0.75)])
            seed.pikminIdleLook.runAction(SKAction.repeatActionForever(group))
            seed.pikminPluck.positional = true
            seed.pikminPluck.autoplayLooped = false
            seed.addChild(seed.pikminIdleLook)
            seed.addChild(seed.pikminPluck)
            seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                    seed.removeAllActions()
                    seed.rooted = true
                    seed.pikminIdleLook.hidden = false
                    seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                    seed.runAction(SKAction.setTexture(SKTexture(imageNamed:"Seed_" + self.onionColor + "_Falling2"), resize: true))
                })
            })
            self.parent!.addChild(seed)
        }
    }
    
    func absorbNutrient(nutrient:Nutrient) {
        if !nutrient.beingAbsorbed {
            nutrient.beingAbsorbed = true
            nutrient.runAction(SKAction.moveBy(CGVector(dx: 0, dy: 60), duration: 2),completion:{
                if nutrient.nutrientColor == self.onionColor {
                    nutrient.worth *= 2
                }
                
                while nutrient.worth > 0 {
                    nutrient.worth -= 1
                    self.dispelSeed()
                }
                nutrient.removeAllChildren()
                nutrient.removeAllActions()
                nutrient.removeFromParent()
            })
        }
    }
}