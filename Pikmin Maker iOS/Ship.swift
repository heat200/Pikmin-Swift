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
    
    func getIn(_ player:Player) {
        if allowedToLeave {
            followShip = true
            allowedToLeave = false
            let sequence = SKAction.sequence([SKAction.setTexture(SKTexture(imageNamed:"Olimar_Left_Stand")),SKAction.wait(forDuration: 1),SKAction.setTexture(SKTexture(imageNamed:"Olimar_Right_Stand")),SKAction.wait(forDuration: 1),SKAction.setTexture(SKTexture(imageNamed:"Olimar_Up_Stand"))])
            player.run(sequence,completion: {
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
                    
                    self.run(SKAction.wait(forDuration: waitTime),completion:{
                        parent.camera?.run(SKAction.scale(to: 2, duration: 5))
                        let group = SKAction.group([SKAction.move(to: self.position, duration: 0.75),SKAction.scale(to: 0.05, duration: 0.75)])
                        player.run(group,completion:{
                            player.isHidden = true
                            self.shipDoor.run(SKAction.move(by: CGVector(dx: 0, dy: 22), duration: 1.25))
                            self.shipDoor.run(SKAction.animate(with: [SKTexture(imageNamed:"Ship_Door1"),SKTexture(imageNamed:"Ship_Door2"),SKTexture(imageNamed:"Ship_Door3"),SKTexture(imageNamed:"Ship_Door4"),SKTexture(imageNamed:"Ship_Door5")], timePerFrame: 0.25, resize: true, restore: false),completion:{
                                self.run(SKAction.setTexture(SKTexture(imageNamed: "Ship_" + player.character)),completion:{
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
            parent.timeFrame = 5
            parent.sundialUpdate()
            run(SKAction.moveBy(x: 0, y: 2800, duration: 10),completion:{
                self.allowedToLeave = true
            })
            
            if parent.RedOnion.awakened {
                parent.RedOnion.removeAllActions()
                parent.RedOnion.run(SKAction.move(to: CGPoint(x: self.position.x - 200,y: self.position.y + 2800), duration: 15))
                parent.RedOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
            
            if parent.BlueOnion.awakened {
                parent.BlueOnion.removeAllActions()
                parent.BlueOnion.zPosition = self.zPosition + 1
                parent.BlueOnion.run(SKAction.move(to: CGPoint(x: self.position.x,y: self.position.y + 2725), duration: 15))
                parent.BlueOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
            
            if parent.YellowOnion.awakened {
                parent.YellowOnion.removeAllActions()
                parent.YellowOnion.run(SKAction.move(to: CGPoint(x: self.position.x + 200,y: self.position.y + 2800), duration: 15))
                parent.YellowOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.1, resize: true, restore: true)))
            }
        }
    }
    
    func flyBackWithOnions() {
        if parent is GameScene {
            let parent = self.parent as! GameScene
            parent.timeFrame = 30
            self.allowedToLeave = false
            self.returning = true
            
            self.run(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2),completion:{
                self.run(SKAction.sequence([SKAction.wait(forDuration: 6),SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 3)]))
                self.run(SKAction.moveBy(x: 0, y: -2800, duration: 10),completion:{
                    parent.ThePlayer.isHidden = false
                    if !parent.RedOnion.awakened && !parent.BlueOnion.awakened && !parent.YellowOnion.awakened {
                        parent.ThePlayer.timeForSpace = false
                    }
                    self.run(SKAction.setTexture(SKTexture(imageNamed: "Ship_Empty")))
                    self.shipDoor.run(SKAction.move(by: CGVector(dx: 0, dy: -22), duration: 1.25))
                    self.shipDoor.run(SKAction.animate(with: [SKTexture(imageNamed:"Ship_Door5"),SKTexture(imageNamed:"Ship_Door4"),SKTexture(imageNamed:"Ship_Door3"),SKTexture(imageNamed:"Ship_Door2"),SKTexture(imageNamed:"Ship_Door1")], timePerFrame: 0.25, resize: true, restore: false),completion:{
                        parent.ThePlayer.run(SKAction.move(to: CGPoint(x: self.position.x, y: self.position.y - 100), duration: 0.75))
                        parent.ThePlayer.run(SKAction.scale(to: 1, duration: 0.75),completion:{
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
                    
                    parent.RedOnion.run(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2),completion:{
                        parent.RedOnion.run(SKAction.sequence([SKAction.wait(forDuration: 9),SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 3)]))
                    })
                    
                    parent.RedOnion.run(SKAction.move(to: CGPoint(x: self.position.x - 200,y: self.position.y - 2700), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation || parent.redPopulation == 0 {
                            parent.RedOnion.dispelSeed()
                        }
                    })
                    parent.RedOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.BlueOnion.awakened {
                    parent.BlueOnion.removeAllActions()
                    parent.BlueOnion.zPosition = self.zPosition + 1
                    
                    parent.BlueOnion.run(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2),completion:{
                        parent.BlueOnion.run(SKAction.sequence([SKAction.wait(forDuration: 9),SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 3)]))
                    })
                    parent.BlueOnion.run(SKAction.move(to: CGPoint(x: self.position.x,y: self.position.y - 2625), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation || parent.bluePopulation == 0 {
                            parent.BlueOnion.dispelSeed()
                        }
                    })
                    parent.BlueOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.YellowOnion.awakened {
                    parent.YellowOnion.removeAllActions()
                    parent.YellowOnion.run(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2),completion:{
                        parent.YellowOnion.run(SKAction.sequence([SKAction.wait(forDuration: 9),SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 3)]))
                    })
                    parent.YellowOnion.run(SKAction.move(to: CGPoint(x: self.position.x + 200,y: self.position.y - 2700), duration: 15),completion:{
                        parent.ThePlayer.timeForSpace = false
                        if allowRepopulation || parent.yellowPopulation == 0 {
                            parent.YellowOnion.dispelSeed()
                        }
                    })
                    parent.YellowOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
            })
        }
    }
    
    func toMultiplayer() {
        if parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            let scene = MultiGameScene(fileNamed:"MultiGameScene")
            scene?.scaleMode = .resizeFill
            scene?.currentPlayer = self.player
            parent.view?.presentScene(scene)
        }
    }
    
    func backToEarth() {
        if self.parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            parent.camera?.run(SKAction.scale(to: 1, duration: 10))
            flyBackWithOnions()
        }
    }
}
