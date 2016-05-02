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
    var allowedToLeave = false
    var returning = false
    
    func getIn(player:Player) {
        if !allowedToLeave {
            followShip = true
            allowedToLeave = false
            player.makePikminIdle()
            (player.parent as! GameScene).camera?.runAction(SKAction.scaleTo(2, duration: 5))
            player.runAction(SKAction.moveTo(self.position, duration: 1),completion:{
                player.hidden = true
                self.runAction(SKAction.setTexture(SKTexture(imageNamed: "Ship_" + player.character)),completion:{
                    self.flyAwayWithOnions()
                })
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
                self.runAction(SKAction.sequence([SKAction.waitForDuration(6.5),SKAction.rotateByAngle(CGFloat(-M_PI), duration: 3.5)]))
                self.runAction(SKAction.moveByX(0, y: -2800, duration: 10),completion:{
                    parent.ThePlayer.hidden = false
                    self.returning = false
                    self.followShip = false
                    parent.movingSpace = false
                    parent.ThePlayer.runAction(SKAction.moveTo(CGPoint(x: self.position.x, y: self.position.y - 80), duration: 1))
                    self.runAction(SKAction.setTexture(SKTexture(imageNamed: "Ship_Empty")))
                })
                
                if parent.RedOnion.awakened {
                    parent.RedOnion.removeAllActions()
                    parent.RedOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x - 200,y: self.position.y - 2700), duration: 15))
                    parent.RedOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.BlueOnion.awakened {
                    parent.BlueOnion.removeAllActions()
                    parent.BlueOnion.zPosition = self.zPosition + 1
                    parent.BlueOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x,y: self.position.y - 2625), duration: 15))
                    parent.BlueOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.YellowOnion.awakened {
                    parent.YellowOnion.removeAllActions()
                    parent.YellowOnion.runAction(SKAction.moveTo(CGPoint(x: self.position.x + 200,y: self.position.y - 2700), duration: 15))
                    parent.YellowOnion.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
            })
        }
    }
    
    func toMultiplayer() {
        if parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            let scene = MultiGameScene(fileNamed:"MultiGameScene")
            scene?.scaleMode = .AspectFill
            scene?.currentPlayer = self.player
            parent.view?.presentScene(scene)
        }
    }
    
    func backToEarth() {
        if self.parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            parent.camera?.runAction(SKAction.scaleTo(1, duration: 10))
            flyBackWithOnions()
        }
    }
}