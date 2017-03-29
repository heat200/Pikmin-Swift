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
    var baseMoveSpeed = 0
    var target = Pikmin()
    var moving = false
    var busy = false
    var stunned = false
    var dead = false
    var brain:Timer!
    var tickCount = 0
    var life_ticks = 0
    var last_attack_tick = 0
    var health:CGFloat = 160
    var maxHealth:CGFloat = 160
    var healthBar = SKShapeNode(rect: CGRect(x: 0, y: 30, width: 50, height: 5), cornerRadius: 5)
    var halfHeight:CGFloat!
    
    
    func randomizeSpecies() -> String {
        let choice = Int(arc4random_uniform(4) + 1)
        var speciesString = ""
        
        if choice <= 3 {
            speciesString = "Red_Bulborb_Dwarf"
        } else if choice == 4 {
            speciesString = "Red_Bulborb"
        }
        
        return speciesString
    }
    
    func setUp() {
        monsterSpecies = randomizeSpecies()
        
        healthBar.fillColor = SKColor.green
        healthBar.strokeColor = SKColor.black
        self.addChild(healthBar)
        
        if monsterSpecies == "Red_Bulborb" {
            maxHealth = 2240
            health = 2240
            xScale = 1.2
            yScale = 1.2
            baseMoveSpeed = 50
            healthBar.position.x = self.position.x - self.size.width/2
            self.zPosition = (self.position.y - self.size.height/2) * -1
        } else if monsterSpecies == "Red_Bulborb_Dwarf" {
            maxHealth = 320
            health = 320
            xScale = 0.5
            yScale = 0.5
            baseMoveSpeed = 65
            healthBar.position.x = self.position.x - self.size.width/2
            healthBar.position.y = 50
            self.zPosition = (self.position.y - self.size.height/2) * -1
        }
        
        target.isHidden = true
        brain = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(Monster.thinking), userInfo: nil, repeats: true)
        halfHeight = self.size.height/2
    }
    
    func move() {
        if !checkIfTooFar(target) && !target.isHidden && !target.dead {
            self.zPosition = (self.position.y - halfHeight) * -1
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
                    run(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Right" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Down"
                    zPosition = BackLayer - 2
                    run(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Down" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Left"
                    run(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                } else if direction == "Left" && tickCount >= 30 {
                    removeAllActions()
                    tickCount = 0
                    direction = "Up"
                    zPosition = BackLayer + 2
                    run(SKAction.setTexture(SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand"), resize: true))
                }
            }
        }
        updateLooks()
    }
    
    func thinking() {
        move()
        healthBar.xScale = health/maxHealth
        life_ticks += 1
        if position != target.position && !busy && !target.dead && !target.isHidden {
            moving = true
        } else if (position.x > target.position.x - 10 && position.x < target.position.x + 10) && (position.y > target.position.y - 10 && position.y < target.position.y + 10) && !busy && !target.isHidden && !target.dead {
            eatTarget()
            moving = false
        } 
    }
    
    func updateLooks() {
        if !busy && !checkIfTooFar(target) && !target.isHidden && !target.dead {
            if direction == "Down" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Up" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Right" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Left" && (direction != oldDirection || !moving) && !busy {
                oldDirection = direction
                self.removeAllActions()
                self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run1"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run2"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run3"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            }
            
            var moveSpeedPatch = 1.00
            if direction == "Up" || direction == "Down" {
                moveSpeedPatch = 0.8
            }
            
            run(SKAction.move(to: target.position, duration: sqrt(pow(Double(self.position.x - target.position.x),2) + pow(Double(self.position.y - target.position.y),2))/(Double(self.baseMoveSpeed) * moveSpeedPatch)))
        }
    }
    
    func findNewTarget() {
        if self.parent is GameScene && !stunned {
            let parent = self.parent as! GameScene
            var targetFound = false
            var index = 0
            if parent.existingPikmin.count > 0 {
                while !targetFound && index < parent.existingPikmin.count {
                    if !checkIfTooFar(parent.existingPikmin[index]) && !parent.existingPikmin[index].dead && !parent.existingPikmin[index].isHidden {
                        target = parent.existingPikmin[index]
                        targetFound = true
                    } else {
                        index += 1
                    }
                }
            }
        }
    }
    
    func checkIfTooFar(_ pikmin:Pikmin) -> Bool {
        var tooFar = false
        let distance = sqrt(pow(Double(self.position.x - pikmin.position.x),2) + pow(Double(self.position.y - pikmin.position.y),2))
        
        if distance > 200 {
            tooFar = true
        }
        
        return tooFar
    }
    
    func kill() {
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
    }
    
    func eatTarget() {
        if life_ticks - last_attack_tick >= 40 {
            print("Eating Target")
            busy = true
            last_attack_tick = life_ticks
            removeAllActions()
            run(SKAction.animate(with: [SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Eat"),SKTexture(imageNamed:"Monster_" + monsterSpecies + "_" + direction + "_Stand")], timePerFrame: 0.14, resize: true, restore: false),completion:{
                if self.target.pikminColor == "White" {
                    self.takePikminDamage("hitPoison")
                }
                self.target.kill(false)
                self.busy = false
            })
        }
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
        } else if damageType == "hitPoison" {
            health -= 25
        } else if damageType == "hitStun" {
            health -= 10
            stunned = true
            target = Pikmin()
            run(SKAction.wait(forDuration: 1.5),completion:{
                self.stunned = false
            })
        }
        
        if health <= 0 {
            dead = true
            isHidden = true
            brain.invalidate()
            
            var nutrientsAdded = 0
            while nutrientsAdded < 5 {
                nutrientsAdded += 1
                var color = "Red"
                let rand = Int(arc4random_uniform(3) + 1)
                let randX:CGFloat = CGFloat(Int(arc4random_uniform(120)) - 60)
                let randY:CGFloat = CGFloat(Int(arc4random_uniform(120)) - 60)
                
                if rand == 1 {
                    color = "Red"
                } else if rand == 2 {
                    color = "Blue"
                } else {
                    color = "Yellow"
                }
                
                let nutrient = Nutrient(imageNamed:"Nutrient_" + color)
                nutrient.nutrientColor = color
                nutrient.position = CGPoint(x: self.frame.midX + randX, y: self.frame.midY + randY)
                nutrient.zPosition = (nutrient.position.y - nutrient.size.height/2) * -1
                self.parent!.addChild(nutrient)
            }
            
            run(SKAction.wait(forDuration: 1.5),completion:{
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
