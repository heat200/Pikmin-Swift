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
    
    func getIn(_ player:Player) {
        if !allowedToLeave {
            followShip = true
            allowedToLeave = false
            player.makePikminIdle()
            (player.parent as! GameScene).camera?.run(SKAction.scale(to: 2, duration: 5))
            player.run(SKAction.move(to: self.position, duration: 1),completion:{
                player.isHidden = true
                self.run(SKAction.setTexture(SKTexture(imageNamed: "Ship_" + player.character)),completion:{
                    self.flyAwayWithOnions()
                })
            })
        }
    }
    
    func flyAwayWithOnions() {
        if parent is GameScene {
            let parent = self.parent as! GameScene
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
            self.allowedToLeave = false
            self.returning = true
            
            self.run(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 2),completion:{
                self.run(SKAction.sequence([SKAction.wait(forDuration: 6.5),SKAction.rotate(byAngle: CGFloat(-M_PI), duration: 3.5)]))
                self.run(SKAction.moveBy(x: 0, y: -2800, duration: 10),completion:{
                    parent.ThePlayer.isHidden = false
                    self.returning = false
                    self.followShip = false
                    parent.movingSpace = false
                    parent.ThePlayer.run(SKAction.move(to: CGPoint(x: self.position.x, y: self.position.y - 80), duration: 1))
                    self.run(SKAction.setTexture(SKTexture(imageNamed: "Ship_Empty")))
                })
                
                if parent.RedOnion.awakened {
                    parent.RedOnion.removeAllActions()
                    parent.RedOnion.run(SKAction.move(to: CGPoint(x: self.position.x - 200,y: self.position.y - 2700), duration: 15))
                    parent.RedOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Red"),SKTexture(imageNamed:"Onion_Red2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.BlueOnion.awakened {
                    parent.BlueOnion.removeAllActions()
                    parent.BlueOnion.zPosition = self.zPosition + 1
                    parent.BlueOnion.run(SKAction.move(to: CGPoint(x: self.position.x,y: self.position.y - 2625), duration: 15))
                    parent.BlueOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Blue"),SKTexture(imageNamed:"Onion_Blue2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
                
                if parent.YellowOnion.awakened {
                    parent.YellowOnion.removeAllActions()
                    parent.YellowOnion.run(SKAction.move(to: CGPoint(x: self.position.x + 200,y: self.position.y - 2700), duration: 15))
                    parent.YellowOnion.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Onion_Yellow"),SKTexture(imageNamed:"Onion_Yellow2")], timePerFrame: 0.8, resize: true, restore: true)))
                }
            })
        }
    }
    
    func toMultiplayer() {
        if parent is GameScene && allowedToLeave {
            let parent = self.parent as! GameScene
            let scene = MultiGameScene(fileNamed:"MultiGameScene")
            scene?.scaleMode = .aspectFill
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
