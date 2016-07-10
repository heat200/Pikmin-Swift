//
//  Pikmin.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Pikmin:SKSpriteNode {
    var pikminTier = "Leaf"
    var pikminColor = "Red"
    var flowerColor = "W"
    var direction = ""
    var oldDirection = ""
    var movementSpeed = 0
    var baseMoveSpeed = 100
    var pikminTierLook = SKSpriteNode(imageNamed: "Leaf")
    var pikminIdleLook = SKSpriteNode(imageNamed:"RedGlow")
    var leader = Player()
    var attackDamage = 1
    var landDamage = 1
    var attacking = false
    var followPoint = CGPoint()
    var dead = false
    var idle = false
    var moving = false
    var busy = false
    var returning = false
    var brain:NSTimer!
    var throwHeight:CGFloat = 140
    var dispX:CGFloat = 0
    var dispY:CGFloat = 0
    var pikminSqueel = SKAction.playSoundFileNamed("pikminSqueel", waitForCompletion: false)
    var pikminLand = SKAction.playSoundFileNamed("pikminLand", waitForCompletion: false)
    var pikminBumped = SKAction.playSoundFileNamed("pikminLand", waitForCompletion: false)
    var pikminLeft = SKAction.playSoundFileNamed("pikminLand", waitForCompletion: false)
    var pikminThrow = SKAction.playSoundFileNamed("throw", waitForCompletion: false)
    
    
    var movingToHome = false
    var inHome = false
    
    func setTier() {
        pikminIdleLook.runAction(SKAction.setTexture(SKTexture(imageNamed:pikminColor + "Glow"), resize: true))
        pikminIdleLook.setScale(1)
        let group = SKAction.sequence([SKAction.scaleTo(1.9, duration: 0.75),SKAction.scaleTo(2.4, duration: 0.75)])
        pikminIdleLook.runAction(SKAction.repeatActionForever(group))
        
        if pikminColor == "White" || pikminColor == "Purple" {
            flowerColor = "P"
        }
        
        if pikminColor == "Red" || pikminColor == "Blue" || pikminColor == "Yellow" {
            baseMoveSpeed = 100
            if pikminColor == "Yellow" {
                throwHeight = 180
            }
        } else if pikminColor == "White" {
            baseMoveSpeed = 115
        } else if pikminColor == "Purple" {
            baseMoveSpeed = 85
            throwHeight = 100
        }
        
        if pikminTier == "Leaf" {
            movementSpeed = baseMoveSpeed
            pikminTierLook.runAction(SKAction.setTexture(SKTexture(imageNamed:"Leaf")))
        } else if pikminTier == "Bud" {
            movementSpeed = baseMoveSpeed + 25
            pikminTierLook.runAction(SKAction.setTexture(SKTexture(imageNamed:"Bud" + flowerColor)))
        } else if pikminTier == "Flower" {
            movementSpeed = baseMoveSpeed + 50
            pikminTierLook.runAction(SKAction.setTexture(SKTexture(imageNamed:"Flower" + flowerColor)))
        }
        pikminIdleLook.hidden = true
        pikminIdleLook.zPosition = -1
        self.addChild(pikminIdleLook)
        self.addChild(pikminTierLook)
    }
    
    func setUp() {
        setTier()
        let randX = CGFloat(arc4random_uniform(40)) + 10
        let randY = CGFloat(arc4random_uniform(40)) + 10
        dispX = randX
        dispY = randY
        followPoint = CGPoint(x: leader.position.x + randX, y: leader.position.y + randY)
        brain = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(Pikmin.thinking), userInfo: nil, repeats: true)
    }
    
    func move() {
        if !attacking {
            if abs(leader.position.x - position.x) > abs(leader.position.y - position.y) && !busy {
                if leader.position.x > position.x {
                    direction = "Right"
                } else if leader.position.x < position.x {
                    direction = "Left"
                }
            } else if abs(leader.position.x - position.x) < abs(leader.position.y - position.y) && !busy{
                if leader.position.y > position.y {
                    direction = "Up"
                } else if leader.position.y < position.y {
                    direction = "Down"
                }
            }
        } /*else {
            if abs(attackTarget.position.x - position.x) > abs(attackTarget.position.y - position.y) && !busy {
                if attackTarget.position.x > position.x {
                    direction = "Right"
                } else if attackTarget.position.x < position.x {
                    direction = "Left"
                }
            } else if abs(attackTarget.position.x - position.x) < abs(attackTarget.position.y - position.y) && !busy{
                if attackTarget.position.y > position.y {
                    direction = "Up"
                } else if attackTarget.position.y < position.y {
                    direction = "Down"
                }
            }
        }*/
        updateLooks()
    }
    
    func thinking() {
        if leader.playerDirection == "Left" {
            followPoint = CGPoint(x: leader.position.x + dispX, y: leader.position.y)
        } else if leader.playerDirection == "Right" {
            followPoint = CGPoint(x: leader.position.x - dispX, y: leader.position.y)
        } else if leader.playerDirection == "Up" {
            followPoint = CGPoint(x: leader.position.x, y: leader.position.y - dispY)
            zPosition = BackLayer + 1
        } else if leader.playerDirection == "Down" {
            followPoint = CGPoint(x: leader.position.x, y: leader.position.y + dispY)
            if !busy {
                zPosition = BackLayer - 1
            }
        }
        pikminIdleLook.position = pikminTierLook.position
        move()
        if position != followPoint && !idle && !busy {
            moving = true
        } else if (idle || (position.x > followPoint.x - 10 && position.x < followPoint.x + 10) && (position.y > followPoint.y - 10 && position.y < followPoint.y + 10)) && !busy && !leader.timeForSpace {
            moving = false
            returning = false
            self.removeAllActions()
            self.runAction(SKAction.setTexture(SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Stand"), resize: true))
            if idle {
                pikminIdleLook.hidden = false
            }
        }
        
        if leader.position.x - leader.recallCircle.frame.width/2 <= position.x && leader.position.x + leader.recallCircle.frame.width/2 >= position.x && leader.position.y - leader.recallCircle.frame.height/2 <= position.y && leader.position.y + leader.recallCircle.frame.height/2 >= position.y && self.idle {
            idle = false
            pikminIdleLook.hidden = true
            if !leader.pikminFollowing.contains(self) {
                leader.pikminFollowing.append(self)
            }
            runAction(pikminBumped)
        }
        
        if leader.timeForSpace && !movingToHome && !inHome {
            var onionPosition = CGPoint(x: 0, y: 0)
            movingToHome = true
            if pikminColor == "Red" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    onionPosition = parent.RedOnion.position
                }
            } else if pikminColor == "Blue" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    onionPosition = parent.BlueOnion.position
                }
            } else if pikminColor == "Yellow" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    onionPosition = parent.YellowOnion.position
                }
            } else if pikminColor == "White" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    onionPosition = parent.TheShip.position
                }
            } else if pikminColor == "Purple" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    onionPosition = parent.TheShip.position
                }
            }
            
            let pos1 = CGPoint(x: onionPosition.x, y: onionPosition.y - 50)
            let pos2 = CGPoint(x: onionPosition.x, y: onionPosition.y + 25)
            
            runAction(SKAction.moveTo(pos1, duration: sqrt(pow(Double(self.position.x - onionPosition.x),2) + pow(Double(self.position.y - onionPosition.y - 40),2))/Double(self.movementSpeed)),completion:{
                self.runAction(SKAction.moveTo(pos2, duration: sqrt(pow(Double(self.position.x - onionPosition.x),2) + pow(Double(self.position.y - onionPosition.y + 30),2))/Double(self.movementSpeed)),completion:{
                    self.movingToHome = false
                    self.inHome = true
                    self.hidden = true
                })
            })
        } else if leader.timeForSpace && inHome {
            if pikminColor == "Red" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    self.position = parent.RedOnion.position
                }
            } else if pikminColor == "Blue" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    self.position = parent.BlueOnion.position
                }
            } else if pikminColor == "Yellow" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    self.position = parent.YellowOnion.position
                }
            } else if pikminColor == "White" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    self.position = parent.TheShip.position
                }
            } else if pikminColor == "Purple" {
                if self.parent is GameScene {
                    let parent = (self.parent as! GameScene)
                    self.position = parent.TheShip.position
                }
            }
        } else if !leader.timeForSpace {
            inHome = false
            hidden = false
        }
    }
    
    func updateLooks() {
        if !busy && !leader.timeForSpace {
            if self.checkIfTooFar() {
                if !idle {
                    self.busy = false
                    self.returning = false
                    self.idle = true
                    self.runAction(SKAction.sequence([SKAction.waitForDuration(0.025),pikminLeft]))
                    var index = -1
                    var found = false
                    while index < self.leader.pikminFollowing.count - 1 && !found {
                        index += 1
                        if self == self.leader.pikminFollowing[index] {
                            found = true
                            self.leader.pikminFollowing.removeAtIndex(index)
                        }
                    }
                }
            }
            
            if direction == "Down" && (direction != oldDirection || !moving) && !busy && !leader.timeForSpace {
                oldDirection = direction
                pikminTierLook.position = CGPoint(x: 6, y: 20)
                pikminTierLook.xScale = 1
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run1"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run2"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run3"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Up" && (direction != oldDirection || !moving) && !busy && !leader.timeForSpace {
                oldDirection = direction
                pikminTierLook.position = CGPoint(x: 6, y: 20)
                pikminTierLook.xScale = 1
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run1"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run2"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run3"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Right" && (direction != oldDirection || !moving) && !busy && !leader.timeForSpace {
                oldDirection = direction
                pikminTierLook.position = CGPoint(x: -7, y: 20)
                pikminTierLook.xScale = -1
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run1"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run2"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run3"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            } else if direction == "Left" && (direction != oldDirection || !moving) && !busy && !leader.timeForSpace {
                oldDirection = direction
                pikminTierLook.position = CGPoint(x: 7, y: 20)
                pikminTierLook.xScale = 1
                self.removeAllActions()
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run1"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run2"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run3"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            }
            
            var moveSpeedPatch = 1.00
            if direction == "Up" || direction == "Down" {
                moveSpeedPatch = 0.8
            }
            
            runAction(SKAction.moveTo(followPoint, duration: sqrt(pow(Double(self.position.x - followPoint.x),2) + pow(Double(self.position.y - followPoint.y),2))/(Double(self.movementSpeed) * moveSpeedPatch)))
        }
    }
    
    func carryNutrient(nutrient:Nutrient) {
        busy = true
        if parent is GameScene {
            let parent = (self.parent as! GameScene)
            var onionToTakeTo = parent.RedOnion
            if pikminColor == "Red" {
                onionToTakeTo = parent.RedOnion
            } else if pikminColor == "Blue" {
                onionToTakeTo = parent.BlueOnion
            } else if pikminColor == "Yellow" {
                onionToTakeTo = parent.YellowOnion
            } else {
                if nutrient.nutrientColor == "Red" && parent.RedOnion.awakened {
                    onionToTakeTo = parent.RedOnion
                } else if nutrient.nutrientColor == "Blue" && parent.BlueOnion.awakened {
                    onionToTakeTo = parent.BlueOnion
                } else if nutrient.nutrientColor == "Yellow" && parent.YellowOnion.awakened {
                    onionToTakeTo = parent.YellowOnion
                } else {
                    let randOnion = Int(arc4random_uniform(3) + 1)
                    if randOnion == 1 && parent.RedOnion.awakened  {
                        onionToTakeTo = parent.RedOnion
                    } else if randOnion == 2 && parent.BlueOnion.awakened {
                        onionToTakeTo = parent.BlueOnion
                    } else if randOnion == 3 && parent.YellowOnion.awakened {
                        onionToTakeTo = parent.YellowOnion
                    } else {
                        if parent.RedOnion.awakened {
                            onionToTakeTo = parent.RedOnion
                        } else if parent.BlueOnion.awakened {
                            onionToTakeTo = parent.BlueOnion
                        } else if parent.YellowOnion.awakened {
                            onionToTakeTo = parent.YellowOnion
                        }
                    }
                }
            }
            let locationToTakeTo = CGPoint(x: onionToTakeTo.position.x, y: onionToTakeTo.position.y - 35)
            var walkSpot1 = CGPoint(x: 0, y: 0)
            var walkSpot2 = CGPoint(x: 0, y: 0)
            if direction == "Right" {
                walkSpot1 = CGPoint(x: nutrient.position.x - 17, y: nutrient.position.y + 5)
                walkSpot2 = CGPoint(x: locationToTakeTo.x - 17, y: locationToTakeTo.y + 5)
            } else if direction == "Left" {
                walkSpot1 = CGPoint(x: nutrient.position.x + 17, y: nutrient.position.y + 5)
                walkSpot2 = CGPoint(x: locationToTakeTo.x + 17, y: locationToTakeTo.y + 5)
            } else if direction == "Up" {
                walkSpot1 = CGPoint(x: nutrient.position.x, y: nutrient.position.y - 5)
                walkSpot2 = CGPoint(x: locationToTakeTo.x, y: locationToTakeTo.y - 5)
                nutrient.zPosition = self.zPosition - 2
            } else if direction == "Down" {
                walkSpot1 = CGPoint(x: nutrient.position.x, y: nutrient.position.y + 20)
                walkSpot2 = CGPoint(x: locationToTakeTo.x, y: locationToTakeTo.y + 20)
                nutrient.zPosition = self.zPosition + 2
            }
            
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run1"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run2"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run3"),SKTexture(imageNamed:"Pikmin_" + pikminColor + "_" + direction + "_Run4")], timePerFrame: 0.12)))
            self.runAction(SKAction.moveTo(walkSpot1, duration: sqrt(pow(Double(self.position.x - walkSpot1.x),2) + pow(Double(self.position.y - walkSpot1.y),2))/Double(self.movementSpeed)),completion:{
                nutrient.runAction(SKAction.moveTo(locationToTakeTo, duration: sqrt(pow(Double(self.position.x - walkSpot2.x),2) + pow(Double(self.position.y - walkSpot2.y),2))/Double(self.movementSpeed)),completion:{
                    self.busy = false
                    self.returning = true
                    onionToTakeTo.absorbNutrient(nutrient)
                })
                self.runAction(SKAction.moveTo(walkSpot2, duration: sqrt(pow(Double(self.position.x - walkSpot2.x),2) + pow(Double(self.position.y - walkSpot2.y),2))/Double(self.movementSpeed)))
            })
        }
    }
    
    func checkIfTooFar() -> Bool {
        var tooFar = false
        let distance = sqrt(pow(Double(self.position.x - leader.position.x),2) + pow(Double(self.position.y - leader.position.y),2))
        
        if distance > 275 {
            tooFar = true
        }
        
        return tooFar
    }
    
    func kill() {
        runAction(pikminSqueel,completion: {
            if self.parent is GameScene {
                let parent = self.parent as! GameScene
                parent.population -= 1
                print("New Population: " + String(parent.population))
                if parent.existingPikmin.contains(self) {
                    var index = -1
                    var found = false
                    while index < parent.existingPikmin.count - 1 && !found {
                        index += 1
                        if self == parent.existingPikmin[index] {
                            found = true
                            parent.existingPikmin.removeAtIndex(index)
                        }
                    }
                }
            }
            
            if self.leader.pikminFollowing.contains(self) {
                var index = -1
                var found = false
                while index < self.leader.pikminFollowing.count - 1 && !found {
                    index += 1
                    if self == self.leader.pikminFollowing[index] {
                        found = true
                        self.leader.pikminFollowing.removeAtIndex(index)
                    }
                }
            }
            
            let NewGhost = Ghost(imageNamed: "Ghost_" + self.pikminColor + "1")
            NewGhost.position = self.position
            NewGhost.ghostColor = self.pikminColor
            NewGhost.zPosition = FrontLayer
            self.parent!.addChild(NewGhost)
            NewGhost.setUp()
            
            self.dead = true
            self.brain.invalidate()
            self.removeAllActions()
            self.removeAllChildren()
            self.removeFromParent()
        })
    }
}