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
            run(SKAction.scale(to: 1.5, duration: 1),completion:{
                self.run(SKAction.scale(to: 1, duration: 0.01),completion:{
                    self.run(SKAction.setTexture(worldAtlas.textureNamed("Flower_" + self.flowerColor + "_Closed"), resize: true))
                })
                self.open = false
                self.dispelSeed()
            })
        } else if !open && !busy {
            open = true
            run(SKAction.setTexture(worldAtlas.textureNamed("Flower_" + flowerColor + "_Open"), resize: true))
        }
    }
    
    func dispelSeed() {
        if self.parent is GameScene {
            while pikminTaken > 0 {
                pikminTaken -= 1
                let randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
                
                let seed = Seed(texture: pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"))
                seed.zPosition = FrontLayer
                seed.seedColor = flowerColor
                let original = CGFloat(seed.zRotation)
                seed.zRotation = CGFloat(Double.pi * 3)
                seed.position.x = self.position.x
                seed.position.y = self.position.y + 50
                seed.run(SKAction.repeatForever(SKAction.animate(with: [pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling1"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling3"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                
                if randX > 0 {
                    seed.run(SKAction.rotate(toAngle: original, duration: 0.8,shortestUnitArc:true))
                } else {
                    seed.run((SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.8)))
                }
                
                seed.pikminIdleLook.run(SKAction.setTexture(pikminAtlas.textureNamed(seed.seedColor + "Glow"), resize: true))
                seed.pikminIdleLook.setScale(1)
                seed.pikminIdleLook.zPosition = -1
                seed.pikminIdleLook.isHidden = true
                let group = SKAction.sequence([SKAction.scale(to: 1.9, duration: 0.75),SKAction.scale(to: 2.4, duration: 0.75)])
                seed.pikminIdleLook.run(SKAction.repeatForever(group))
                seed.addChild(seed.pikminIdleLook)
                seed.run(SKAction.move(by: CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                    seed.run(SKAction.move(by: CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                        seed.removeAllActions()
                        seed.rooted = true
                        seed.pikminIdleLook.isHidden = false
                        seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                        seed.run(SKAction.setTexture(pikminAtlas.textureNamed("Seed_" + self.flowerColor + "_Falling2"), resize: true))
                        seed.pikminCycle()
                    })
                })
                self.parent!.addChild(seed)
            }
            busy = false
            run(SKAction.wait(forDuration: 1.5),completion:{
                self.toggleOpen()
            })
        } else if (self.parent as! GameScene).connected {
            let parent = self.parent as! GameScene
            if parent.currentPlayer == "1" {
                while pikminTaken > 0 {
                    pikminTaken -= 1
                    let randX:CGFloat = CGFloat(Int(arc4random_uniform(180)) - 90)
                    
                    parent.sendFlowerNum(self, randX: randX)
                    
                    let seed = Seed(texture: pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"))
                    seed.zPosition = FrontLayer
                    seed.seedColor = flowerColor
                    let original = CGFloat(seed.zRotation)
                    seed.zRotation = CGFloat(Double.pi * 3)
                    seed.position.x = self.position.x
                    seed.position.y = self.position.y + 50
                    seed.run(SKAction.repeatForever(SKAction.animate(with: [pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling1"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling3"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                    
                    if randX > 0 {
                        seed.run(SKAction.rotate(toAngle: original, duration: 0.8,shortestUnitArc:true))
                    } else {
                        seed.run((SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.8)))
                    }
                    
                    seed.pikminIdleLook.run(SKAction.setTexture(pikminAtlas.textureNamed(seed.seedColor + "Glow"), resize: true))
                    seed.pikminIdleLook.setScale(1)
                    seed.pikminIdleLook.zPosition = -1
                    seed.pikminIdleLook.isHidden = true
                    let group = SKAction.sequence([SKAction.scale(to: 1.9, duration: 0.75),SKAction.scale(to: 2.4, duration: 0.75)])
                    seed.pikminIdleLook.run(SKAction.repeatForever(group))
                    seed.addChild(seed.pikminIdleLook)
                    seed.run(SKAction.move(by: CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                        seed.run(SKAction.move(by: CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                            seed.removeAllActions()
                            seed.rooted = true
                            seed.pikminIdleLook.isHidden = false
                            seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                            seed.run(SKAction.setTexture(pikminAtlas.textureNamed("Seed_" + self.flowerColor + "_Falling2"), resize: true))
                        })
                    })
                    self.parent!.addChild(seed)
                    
                }
                busy = false
                run(SKAction.wait(forDuration: 1.5),completion:{
                    self.toggleOpen()
                })
            } else {
                let randX = randXMultiplayer
                if receivedMsg {
                    print("Still attempting")
                    let seed = Seed(texture: pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"))
                    seed.zPosition = FrontLayer
                    seed.seedColor = flowerColor
                    let original = CGFloat(seed.zRotation)
                    seed.zRotation = CGFloat(Double.pi * 3)
                    seed.position.x = self.position.x
                    seed.position.y = self.position.y + 50
                    seed.run(SKAction.repeatForever(SKAction.animate(with: [pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling1"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling2"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling3"),pikminAtlas.textureNamed("Seed_" + flowerColor + "_Falling4")], timePerFrame: 0.15, resize: true, restore: true)))
                    
                    if randX > 0 {
                        seed.run(SKAction.rotate(toAngle: original, duration: 0.8,shortestUnitArc:true))
                    } else {
                        seed.run((SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 0.8)))
                    }
                    
                    seed.pikminIdleLook.run(SKAction.setTexture(pikminAtlas.textureNamed(seed.seedColor + "Glow"), resize: true))
                    seed.pikminIdleLook.setScale(1)
                    seed.pikminIdleLook.zPosition = -1
                    seed.pikminIdleLook.isHidden = true
                    let group = SKAction.sequence([SKAction.scale(to: 1.9, duration: 0.75),SKAction.scale(to: 2.4, duration: 0.75)])
                    seed.pikminIdleLook.run(SKAction.repeatForever(group))
                    seed.addChild(seed.pikminIdleLook)
                    seed.run(SKAction.move(by: CGVector(dx: randX * 0.4, dy: 30), duration: 0.8),completion:{
                        seed.run(SKAction.move(by: CGVector(dx: randX * 0.6, dy: -140 + (abs(randX) * 0.5)), duration: 1.7), completion:{
                            seed.removeAllActions()
                            seed.rooted = true
                            seed.pikminIdleLook.isHidden = false
                            seed.pikminIdleLook.position = CGPoint(x: 0, y: 10)
                            seed.run(SKAction.setTexture(pikminAtlas.textureNamed("Seed_" + self.flowerColor + "_Falling2"), resize: true))
                        })
                    })
                    self.parent!.addChild(seed)
                }
                busy = false
                self.receivedMsg = false
                run(SKAction.wait(forDuration: 1.5),completion:{
                    self.toggleOpen()
                })
            }
        }
    }

    func randomizePosition() {
        zPosition = MidLayer - 1
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        
        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
}
