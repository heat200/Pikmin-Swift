//
//  Monster.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Monster:SKSpriteNode {
    var monsterSpecies = "Red_Bulborb"
    var direction = "Down"
    var oldDirection = ""
    var baseMoveSpeed = 90
    var target = Pikmin()
    var moving = false
    var busy = false
    var brain:NSTimer!
    var tickCount = 0
    
    
    func setUp() {
        zPosition = MidLayer - 2
        target.hidden = true
        brain = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(Monster.thinking), userInfo: nil, repeats: true)
    }
    
    func move() {
        if !checkIfTooFar(target) && !target.hidden && !target.dead {
            if abs(target.position.x - position.x) > abs(target.position.y - position.y) && !busy {
                if target.position.x > position.x {
                    direction = "Right"
                } else if target.position.x < position.x {
                    direction = "Left"
                }
            } else if abs(target.position.x - position.x) < abs(target.position.y - position.y) && !busy{
                if target.position.y > position.y {
                    direction = "Up"
                } else if target.position.y < position.y {
                    direction = "Down"
                }
            }
        } else {
            findNewTarget()
            if !busy {
                tickCount += 1
                if direction == "Up" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Right"
                    runAction(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Right" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Down"
                    zPosition = BackLayer - 2
                    runAction(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Down" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Left"
                    runAction(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Left" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Up"
                    zPosition = BackLayer + 2
                    runAction(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                }
            }
        }
        updateLooks()
    }
    
    func thinking() {
        move()
        
        if position != target.position && !busy && !target.dead && !target.hidden {
            moving = true
        } else if (position.x > target.position.x - 10 && position.x < target.position.x + 10) && (position.y > target.position.y - 10 && position.y < target.position.y + 10) && !busy && !target.hidden && !target.dead {
            eatTarget()
            moving = false
        } 
    }
    
    func updateLooks() {
        if !busy && !checkIfTooFar(target) && !target.hidden && !target.dead {
            if direction == "Down" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Up" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Right" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Left" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            }
            
            var moveSpeedPatch = 1.00
            if direction == "Up" || direction == "Down" {
                moveSpeedPatch = 0.8
            }
            
            runAction(SKAction.moveTo(target.position, duration: sqrt(pow(Double(self.position.x - target.position.x),2) + pow(Double(self.position.y - target.position.y),2))/(Double(self.baseMoveSpeed) * moveSpeedPatch)))
        }
    }
    
    func findNewTarget() {
        if self.parent is GameScene {
            let parent = self.parent as! GameScene
            var targetFound = false
            var index = 0
            if parent.existingPikmin.count > 0 {
                while !targetFound && index < parent.existingPikmin.count {
                    if !checkIfTooFar(parent.existingPikmin[index]) && !parent.existingPikmin[index].dead && !parent.existingPikmin[index].hidden {
                        target = parent.existingPikmin[index]
                        targetFound = true
                    } else {
                        index += 1
                    }
                }
            }
        }
    }
    
    func checkIfTooFar(pikmin:Pikmin) -> Bool {
        var tooFar = false
        let distance = sqrt(pow(Double(self.position.x - pikmin.position.x),2) + pow(Double(self.position.y - pikmin.position.y),2))
        
        if distance > 200 {
            tooFar = true
        }
        
        return tooFar
    }
    
    func kill() {
        brain.invalidate()
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
    }
    
    func eatTarget() {
        print("Eating Target")
        busy = true
        removeAllActions()
        runAction(SKAction.animateWithTextures([SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Eat"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand")], timePerFrame: 0.14, resize: true, restore: true),completion:{
            self.target.kill()
            self.busy = false
        })
    }
    
    func randomizePosition() {
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        
        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
}