//
//  Flower.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Flower:SKSpriteNode {
    var flowerColor = "White"
    var open = true
    var pikminTaken = 0
    var busy = false
    
    var randXMultiplayer:CGFloat = 0
    var receivedMsg = false
    
    func toggleOpen() {
        if open && !busy {
            busy = true
            runAction(SKAction.scaleTo(1.5, duration: 1),completion:{
                self.runAction(SKAction.scaleTo(1, duration: 0.01),completion:{
                    self.runAction(SKAction.setTexture(SKTexture(imageNamed: "Flower_" + self.flowerColor + "_Closed"), resize: true))
                })
                self.open = false
                self.dispelSeed()
            })
        } else if !open && !busy {
            open = true
            runAction(SKAction.setTexture(SKTexture(imageNamed: "Flower_" + flowerColor + "_Open"), resize: true))
        }
    }
    
    func dispelSeed() {
        if self.parent is GameScene {
            while pikminTaken > 0 {
                pikminTaken -= 1
                let randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
                
                let seed = Seed(imageNamed:"Seed_" + flowerColor + "_Falling2")
                seed.zPosition = FrontLayer
                seed.seedColor = flowerColor
                let original = CGFloat(seed.zRotation)
                seed.zRotation = CGFloat(M_PI * 3)
                seed.position.x = self.position.x
                seed.position.y = self.position.y + 50
                seed.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling1"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling2"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling3"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                
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
                seed.addChild(seed.pikminIdleLook)
                seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                    seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                        seed.removeAllActions()
                        seed.rooted = true
                        seed.pikminIdleLook.hidden = false
                        seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                        seed.runAction(SKAction.setTexture(SKTexture(imageNamed:"Seed_" + self.flowerColor + "_Falling2"), resize: true))
                    })
                })
                self.parent!.addChild(seed)
            }
            busy = false
            runAction(SKAction.waitForDuration(1.5),completion:{
                self.toggleOpen()
            })
        } /* else if self.parent is MultiGameScene {
            let parent = self.parent as! MultiGameScene
            if parent.currentPlayer == "1" {
                while pikminTaken > 0 {
                    pikminTaken -= 1
                    let randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
                    
                    parent.sendFlowerNum(self, randX: randX)
                    
                    let seed = Seed(imageNamed:"Seed_" + flowerColor + "_Falling2")
                    seed.zPosition = FrontLayer
                    seed.seedColor = flowerColor
                    let original = CGFloat(seed.zRotation)
                    seed.zRotation = CGFloat(M_PI * 3)
                    seed.position.x = self.position.x
                    seed.position.y = self.position.y + 50
                    seed.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling1"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling2"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling3"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                    
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
                    seed.addChild(seed.pikminIdleLook)
                    seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                        seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                            seed.removeAllActions()
                            seed.rooted = true
                            seed.pikminIdleLook.hidden = false
                            seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                            seed.runAction(SKAction.setTexture(SKTexture(imageNamed:"Seed_" + self.flowerColor + "_Falling2"), resize: true))
                        })
                    })
                    self.parent!.addChild(seed)
                    
                }
                busy = false
                runAction(SKAction.waitForDuration(1.5),completion:{
                    self.toggleOpen()
                })
            } else {
                let randX = randXMultiplayer
                if receivedMsg {
                    print("Still attempting")
                    let seed = Seed(imageNamed:"Seed_" + flowerColor + "_Falling2")
                    seed.zPosition = FrontLayer
                    seed.seedColor = flowerColor
                    let original = CGFloat(seed.zRotation)
                    seed.zRotation = CGFloat(M_PI * 3)
                    seed.position.x = self.position.x
                    seed.position.y = self.position.y + 50
                    seed.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling1"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling2"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling3"),SKTexture(imageNamed:"Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                    
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
                    seed.addChild(seed.pikminIdleLook)
                    seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                        seed.runAction(SKAction.moveBy(CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                            seed.removeAllActions()
                            seed.rooted = true
                            seed.pikminIdleLook.hidden = false
                            seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                            seed.runAction(SKAction.setTexture(SKTexture(imageNamed:"Seed_" + self.flowerColor + "_Falling2"), resize: true))
                        })
                    })
                    self.parent!.addChild(seed)
                }
                busy = false
                self.receivedMsg = false
                runAction(SKAction.waitForDuration(1.5),completion:{
                    self.toggleOpen()
                })
            }
        }
        */
    }

    func randomizePosition() {
        zPosition = MidLayer - 1
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        
        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
}