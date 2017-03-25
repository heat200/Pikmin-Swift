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
    
    var randXMultiplayer:CGFloat = 0
    var receivedMsg = false
    
    func randomizePosition() {
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)

        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
    
    func wake() {
        if !awake {
            awake = true
            run(SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 2), completion:{
                self.run(SKAction.setTexture(SKTexture(imageNamed:"Onion_" + self.onionColor), resize: true),completion:{
                    self.position.y -= 40
                    self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_" + self.onionColor),SKTexture(imageNamed:"Onion_" + self.onionColor + "2")], timePerFrame: 0.9, resize: true, restore: true)))
                    self.awakened = true
                    self.dispelSeed()
                })
            })
        }
    }
    
    func dispelSeed() {
        if awakened {
            var allowed = true
            var randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
            
            if self.parent is MultiGameScene {
                let parent = self.parent as! MultiGameScene
                if parent.currentPlayer == "2" {
                    randX = randXMultiplayer
                    if !receivedMsg {
                        allowed = false
                    }
                } else {
                    parent.sendOnionNum(self, randX: randX)
                }
            }
            
            if allowed {
                receivedMsg = false
                let seed = Seed(imageNamed:"Seed_" + onionColor + "_Falling2")
                seed.zPosition = FrontLayer
                seed.seedColor = onionColor
                let original = CGFloat(seed.zRotation)
                seed.zRotation = CGFloat(M_PI * 3)
                seed.position.x = self.position.x
                seed.position.y = self.position.y + 50
                seed.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Seed_" + onionColor + "_Falling1"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling2"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling3"),SKTexture(imageNamed:"Seed_" + onionColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                
                if randX > 0 {
                    seed.run(SKAction.rotate(toAngle: original, duration: 0.8,shortestUnitArc:true))
                } else {
                    seed.run((SKAction.rotate(byAngle: CGFloat(M_PI), duration: 0.8)))
                }
                
                seed.pikminIdleLook.run(SKAction.setTexture(SKTexture(imageNamed:seed.seedColor + "Glow"), resize: true))
                seed.pikminIdleLook.setScale(1)
                seed.pikminIdleLook.zPosition = -1
                seed.pikminIdleLook.isHidden = true
                let group = SKAction.sequence([SKAction.scale(to: 1.9, duration: 0.75),SKAction.scale(to: 2.4, duration: 0.75)])
                seed.pikminIdleLook.run(SKAction.repeatForever(group))
                seed.pikminPluck.isPositional = true
                seed.pikminPluck.autoplayLooped = false
                seed.addChild(seed.pikminIdleLook)
                seed.addChild(seed.pikminPluck)
                seed.run(SKAction.move(by: CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                    seed.run(SKAction.move(by: CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                        seed.removeAllActions()
                        seed.rooted = true
                        seed.pikminIdleLook.isHidden = false
                        seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                        seed.run(SKAction.setTexture(SKTexture(imageNamed:"Seed_" + self.onionColor + "_Falling2"), resize: true))
                    })
                })
                self.parent!.addChild(seed)
            }
        }
    }
    
    func absorbNutrient(_ nutrient:Nutrient) {
        if !nutrient.beingAbsorbed {
            nutrient.beingAbsorbed = true
            nutrient.run(SKAction.move(by: CGVector(dx: 0, dy: 60), duration: 2),completion:{
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
