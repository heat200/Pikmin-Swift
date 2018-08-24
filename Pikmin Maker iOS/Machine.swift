//
//  Machine.swift
//  Pikmin
//
//  Created by Bryan Mazariegos on 3/31/17.
//  Copyright © 2017 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Machine:SKSpriteNode {
    var deviceType = "Electrode"
    var damageType = ""
    var dead = false
    var brain:Timer!
    var active = false
    var tickCount = 0
    var life_ticks = 0
    var last_attack_tick = 0
    var baseCooldown = 5
    var health:CGFloat = 160
    var maxHealth:CGFloat = 160
    var healthBar = SKShapeNode(rect: CGRect(x: 0, y: 30, width: 50, height: 5), cornerRadius: 5)
    var halfHeight:CGFloat!
    
    
    func randomizeDevice() -> String {
        let choice = Int(arc4random_uniform(4) + 1)
        var deviceString = ""
        
        if choice <= 3 {
            deviceString = "Flamer"
        } else if choice == 4 {
            deviceString = "Electrode"
        }
        
        return deviceString
    }
    
    func setUp() {
        deviceType = randomizeDevice()
        healthBar.fillColor = SKColor.green
        healthBar.strokeColor = SKColor.black
        self.addChild(healthBar)
        
        self.run(SKAction.setTexture(SKTexture(imageNamed: deviceType + "_Inactive"), resize: true))
        
        if deviceType == "Electrode" {
            damageType = "Electric"
            maxHealth = 75
            health = 75
            healthBar.position.x = -healthBar.frame.width/2
            self.zPosition = (self.position.y - self.size.height/2) * -1
        } else if deviceType == "Flamer" {
            damageType = "Fire"
            maxHealth = 80
            health = 80
            healthBar.position.x = -healthBar.frame.width/2
            healthBar.position.y = 0
            self.zPosition = (self.position.y - self.size.height/2) * -1
        }
        
        brain = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(Monster.thinking), userInfo: nil, repeats: true)
        halfHeight = self.size.height/2
    }
    
    func thinking() {
        healthBar.xScale = health/maxHealth
        life_ticks += 1
        updateLooks()
    }
    
    func updateLooks() {
        if life_ticks == 35 {
            self.run(SKAction.animate(with: [SKTexture(imageNamed: deviceType + "_Prepping1"),SKTexture(imageNamed: deviceType + "_Prepping2"),SKTexture(imageNamed: deviceType + "_Prepping3")], timePerFrame: 0.15))
        } else if life_ticks == 70 {
            self.run(SKAction.animate(with: [SKTexture(imageNamed: deviceType + "_Prepping1"),SKTexture(imageNamed: deviceType + "_Prepping2"),SKTexture(imageNamed: deviceType + "_Prepping3")], timePerFrame: 0.15))
        } else if life_ticks == 100 {
            active = true
            
            if deviceType == "Flamer" {
                self.run(SKAction.animate(with: [SKTexture(imageNamed: deviceType + "_Active1"),SKTexture(imageNamed: deviceType + "_Active2"),SKTexture(imageNamed: deviceType + "_Active3"),SKTexture(imageNamed: deviceType + "_Active4"),SKTexture(imageNamed: deviceType + "_Active5"),SKTexture(imageNamed: deviceType + "_Active6"),SKTexture(imageNamed: deviceType + "_Active3"),SKTexture(imageNamed: deviceType + "_Active4"),SKTexture(imageNamed: deviceType + "_Active5"),SKTexture(imageNamed: deviceType + "_Active6"),SKTexture(imageNamed: deviceType + "_Active3"),SKTexture(imageNamed: deviceType + "_Active4"),SKTexture(imageNamed: deviceType + "_Active5"),SKTexture(imageNamed: deviceType + "_Active6")], timePerFrame: 0.13),completion:{
                    self.active = false
                    self.life_ticks = 0
                    self.run(SKAction.setTexture(SKTexture(imageNamed: self.deviceType + "_Inactive"), resize: false))
                })
            } else {
                self.run(SKAction.animate(with: [SKTexture(imageNamed: deviceType + "_Active1"),SKTexture(imageNamed: deviceType + "_Active2"),SKTexture(imageNamed: deviceType + "_Active3"),SKTexture(imageNamed: deviceType + "_Active4"),SKTexture(imageNamed: deviceType + "_Active5"),SKTexture(imageNamed: deviceType + "_Active6")], timePerFrame: 0.15),completion:{
                    self.active = false
                    self.life_ticks = 0
                })
            }
        }
        
        checkForPikmin()
    }
    
    func checkForPikmin() {
        var listPosition = 0
        
        if self.active {
            while listPosition < (self.parent as! GameScene).existingPikmin.count {
                let pikminInQuestion = (self.parent as! GameScene).existingPikmin[listPosition]
                if self.contains(pikminInQuestion.position) && !pikminInQuestion.dead && !pikminInQuestion.isHidden {
                    if self.damageType == "Electric" && pikminInQuestion.pikminColor != "Yellow" {
                        pikminInQuestion.inDistress(self.damageType)
                    } else if self.damageType == "Fire" && pikminInQuestion.pikminColor != "Red" {
                        pikminInQuestion.inDistress(self.damageType)
                    } else if self.damageType == "Water" && pikminInQuestion.pikminColor != "Blue" {
                        pikminInQuestion.inDistress(self.damageType)
                    } else if self.damageType == "Poison" && pikminInQuestion.pikminColor != "White" {
                        pikminInQuestion.inDistress(self.damageType)
                    }
                }
                listPosition += 1
            }
        }
    }
    
    func kill() {
        self.active = false
        self.dead = true
        self.removeAllActions()
        self.removeAllChildren()
        self.run(SKAction.setTexture(SKTexture(imageNamed:deviceType + "_Inactive"), resize: false))
    }
    
    func takePikminDamage(_ damageType:String) {
        if damageType == "hitLeaf" {
            health -= 1
        } else if damageType == "hitBud" {
            health -= 2
        } else if damageType == "hitFlower" {
            health -= 3
        } else if damageType == "hitLeaf-Red" {
            health -= 2
        } else if damageType == "hitBud-Red" {
            health -= 3
        } else if damageType == "hitFlower-Red" {
            health -= 4
        } else if damageType == "hitStun" {
            health -= 10
        }
        
        if health <= 0 {
            dead = true
            brain.invalidate()
            active = false
            life_ticks = 0
            run(SKAction.wait(forDuration: 0.5),completion:{
                self.kill()
            })
        }
    }
    
    func randomizePosition() {
        let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
        
        position = CGPoint(x: self.parent!.frame.midX + randX, y: self.parent!.frame.midY + randY)
    }
}
