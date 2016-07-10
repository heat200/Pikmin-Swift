//
//  Ship.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 5/1/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Ship:SKSpriteNode {
    var followShip = false
    var player = "1"
    var allowedToLeave = true
    var returning = false
    var shipDoor = SKSpriteNode(imageNamed:"Ship_Door1")
    
    func setUp() {
        shipDoor.position = CGPoint(x: 0, y: -60)
        shipDoor.zPosition = 1
        self.addChild(shipDoor)
    }
    
    func getIn(player:Player) {
        if allowedToLeave {
            followShip = true
            allowedToLeave = false
            let sequence = SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed:"Olimar_Left_Stand")),SKAction.waitForDuration(1),SKAction.setTexture(SKTexture(imageNamed:"Olimar_Right_Stand")),SKAction.waitForDuration(1),SKAction.setTexture(SKTexture(imageNamed:"Olimar_Up_Stand"))])
            player.runAction(sequence,completion: {
                player.makePikminIdle()
                player.timeForSpace = true
                var waitTime = 12.00
                if self.parent is GameScene {
                    let parent = self.parent as! GameScene
                    if (!parent.RedOnion.awakened && !parent.RedOnion.awakened && !parent.RedOnion.awakened) && parent.population > 0 {
                        waitTime = 3.00
                    } else if (parent.RedOnion.awakened || parent.RedOnion.awakened || parent.RedOnion.awakened) && parent.population > 0 {
                        waitTime = 12.00
                    } else {
                        waitTime = 0.00
                    }
                    
                    self.runAction(SKAction.waitForDuration(waitTime),completion:{
                        parent.camera?.runAction(SKAction.scaleTo(2, duration: 5))
                        let group = SKAction.group([SKAction.moveTo(self.position, duration: 0.75),SKAction.scaleTo(0.05, duration: 0.75)])
                        player.runAction(group,completion:{
                            player.hidden = true
                            self.shipDoor.runAction(SKAction.moveBy(CGVector(dx: 0, dy: 22), duration: 1.25))
                            self.shipDoor.runAction(SKAction.animateWithTextures([SKTexture(imageNamed:"Ship_Door1"),SKTexture(imageNamed:"Ship_Door2"),SKTexture(imageNamed:"Ship_Door3"),SKTexture(imageNamed:"Ship_Door4"),SKTexture(imageNamed:"Ship_Door5")], timePerFrame: 0.25, resize: true, restore: false),completion:{
                                self.runAction(SKAction.setTexture(SKTexture(imageNamed: "Ship_" + player.character)),completion:{
                                    self.flyAwayWithOnions()
                                })
                            })
                        })
                    })
                }
            })
        }
    }
    
    func flyAwayWithOnions() {
        if parent is GameScene {
            let parent = self.parent as! GameScene
            runAction(SKAction.moveByX(0, y: 2800, duration: 10),completion:{
                self.allowedToLeave = true
            })
            
            if parent.RedOnion.awakened {
                parent.RedOnion.removeAllActions()
                parent.RedOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x - 200,y: self.position.y + 2800), duration: 15))
                parent.RedOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
            
            if parent.BlueOnion.awakened {
                parent.BlueOnion.removeAllActions()
                parent.BlueOnion.zPosition = self.zPosition + 1
                parent.BlueOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x,y: self.position.y + 2725), duration: 15))
                parent.BlueOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
            
            if parent.YellowOnion.awakened {
                parent.YellowOnion.removeAllActions()
                parent.YellowOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x + 200,y: self.position.y + 2800), duration: 15))
                parent.YellowOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
        }
    }
    
    func flyBackWithOnions() {
        if parent is GameScene {
            let parent = self.parent as! GameScene
            self.allowedToLeave = false
            self.returning = true
            
            self.runAction(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),completion:{
                self.runAction(SKAction.sequence([SKAction.waitForDuration(6),SKAction.rotateByAngle(CGFloat(-M_PI), duration: 3)]))
                self.runAction(SKAction.moveByX(0, y: -2800, duration: 10),completion:{
                    parent.ThePlayer.hidden = false
                    if !parent.RedOnion.awakened && !parent.BlueOnion.awakened && !parent.YellowOnion.awakened {
                        parent.ThePlayer.timeForSpace = false
                    }
                    self.runAction(SKAction.setTexture(SKTexture(imageNamed: "Ship_Empty")))
                    self.shipDoor.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -22), duration: 1.25))
                    self.shipDoor.runAction(SKAction.animateWithTextures([SKTexture(imageNamed:"Ship_Door5"),SKTexture(imageNamed:"Ship_Door4"),SKTexture(imageNamed:"Ship_Door3"),SKTexture(imageNamed:"Ship_Door2"),SKTexture(imageNamed:"Ship_Door1")], timePerFrame: 0.25, resize: true, restore: false),completion:{
                        parent.ThePlayer.runAction(SKAction.moveTo(CGPoint(x: self.position.x, y: self.position.y - 100), duration: 0.75))
                        parent.ThePlayer.runAction(SKAction.scaleTo(1, duration: 0.75),completion:{
                            self.followShip = false
                            self.returning = false
                            parent.movingSpace = false
                            self.allowedToLeave = true
                        })
                        
                    })
                })
                
                var allowRepopulation = false
                if parent.population == 0 {
                    allowRepopulation = true
                }
                
                if parent.RedOnion.awakened {
                    parent.RedOnion.removeAllActions()
                    
                    parent.RedOnion.runAction(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),completion:{
                        parent.RedOnion.runAction(SKAction.sequence([SKAction.waitForDuration(9),SKAction.rotateByAngle(CGFloat(-M_PI), duration: 3)]))
                    })
                    
                    parent.RedOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x - 200,y: self.position.y - 2700), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation {
                            parent.RedOnion.dispelSeed()
                        }
                    })
                    parent.RedOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.BlueOnion.awakened {
                    parent.BlueOnion.removeAllActions()
                    parent.BlueOnion.zPosition = self.zPosition + 1
                    
                    parent.BlueOnion.runAction(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),completion:{
                        parent.BlueOnion.runAction(SKAction.sequence([SKAction.waitForDuration(9),SKAction.rotateByAngle(CGFloat(-M_PI), duration: 3)]))
                    })
                    parent.BlueOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x,y: self.position.y - 2625), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation {
                            parent.BlueOnion.dispelSeed()
                        }
                    })
                    parent.BlueOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.YellowOnion.awakened {
                    parent.YellowOnion.removeAllActions()
                    parent.YellowOnion.runAction(SKAction.rotateByAngle(CGFloat(M_PI), duration: 2),completion:{
                        parent.YellowOnion.runAction(SKAction.sequence([SKAction.waitForDuration(9),SKAction.rotateByAngle(CGFloat(-M_PI), duration: 3)]))
                    })
                    parent.YellowOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x + 200,y: self.position.y - 2700), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation {
                            parent.YellowOnion.dispelSeed()
                        }
                    })
                    parent.YellowOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
            })
        }
    }
    
    func toMultiplayer() {
        /*
        if parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            let scene = MultiGameScene(fileNamed:"MultiGameScene")
            scene?.scaleMode = .ResizeFill
            scene?.currentPlayer = self.player
            parent.view?.presentScene(scene)
        }
        */
    }
    
    func backToEarth() {
        if self.parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            parent.camera?.runAction(SKAction.scaleTo(1, duration: 10))
            flyBackWithOnions()
        }
    }
}