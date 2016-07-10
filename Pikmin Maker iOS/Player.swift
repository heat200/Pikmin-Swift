//
//  Player.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class Player:SKSpriteNode {
    var pikminFollowing = [Pikmin]()
    var pikminToThrow:Pikmin!
    var character = "Olimar"
    var antenna = SKSpriteNode()
    var callingPikmin = false
    var playerLastDirection = ""
    var playerDirection = "Down"
    var moveTo = ""
    var cursorCircle = SKShapeNode(circleOfRadius: 10)
    let recallCircle = SKShapeNode(circleOfRadius: 3)
    var callSound = SKAudioNode(fileNamed: "call")
    var makeIdleSound = SKAudioNode(fileNamed: "call")
    var playerChars = ""
    
    var timeForSpace = false
    
    func setUp() {
        if character == "Olimar" {
            if character == "Olimar" {
                cursorCircle.strokeColor = SKColor.magenta()
                recallCircle.strokeColor = SKColor.red()
            } else if character == "Louie" {
                cursorCircle.strokeColor = SKColor.blue()
                recallCircle.strokeColor = SKColor.blue()
            }
            
            cursorCircle.glowWidth = 0.5
            cursorCircle.alpha = 1
            cursorCircle.yScale = 0.6
            recallCircle.glowWidth = 0.5
            recallCircle.alpha = 1
            recallCircle.position.y = -20
            
            callSound.autoplayLooped = false
            callSound.isPositional = true
            callSound.run(SKAction.changePlaybackRate(to: 0.85, duration: 1))
            makeIdleSound.autoplayLooped = false
            makeIdleSound.isPositional = true
            makeIdleSound.run(SKAction.changePlaybackRate(to: 1.2, duration: 1))
            makeIdleSound.run(SKAction.changeReverb(to: 0.2, duration: 1))
            
            addChild(callSound)
            addChild(makeIdleSound)
            addChild(cursorCircle)
            addChild(recallCircle)
            antenna = SKSpriteNode(imageNamed:"RedGlow")
            antenna.setScale(1)
            antenna.position = CGPoint(x: 0, y: 20)
            let glowEffect = SKAction.sequence([SKAction.scale(to: 0.7, duration: 1.3),SKAction.scale(to: 0.9, duration: 0.7)])
            antenna.run(SKAction.repeatForever(glowEffect))
            self.addChild(antenna)
        }
    }
    
    func move() {
        if moveTo != "" {
            playerDirection = moveTo
            self.zPosition = (self.position.y - self.size.height/2) * -1
        }
        
        let graphic = character + "_" + playerDirection + "_"
        
        if moveTo != "" && playerLastDirection != playerDirection {
            playerLastDirection = playerDirection
            self.removeAllActions()
            self.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed:graphic + "Run1"),SKTexture(imageNamed:graphic + "Run2"),SKTexture(imageNamed:graphic + "Run3"),SKTexture(imageNamed:graphic + "Run4")], timePerFrame: 0.12)))
        } else if moveTo == "" {
            if self.parent is MultiGameScene && playerLastDirection != "" {
                let parent = self.parent as! MultiGameScene
                if parent.ThePlayer == self {
                    parent.sendCorrectedPos(self)
                }
            }
            
            playerLastDirection = ""
            self.removeAllActions()
            self.run(SKAction.setTexture(SKTexture(imageNamed:graphic + "Stand")))
        }
        
        if moveTo == "Down" {
            self.run(SKAction.move(by: CGVector(dx: 0, dy: -2), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = -1
            cursorCircle.run(SKAction.move(to: CGPoint(x: 0, y: -80), duration: 0.5))
        } else if moveTo == "Up" {
            self.run(SKAction.move(by: CGVector(dx: 0, dy: 2), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = 1
            cursorCircle.run(SKAction.move(to: CGPoint(x: 0, y: 40), duration: 0.5))
        } else if moveTo == "Left" {
            self.run(SKAction.move(by: CGVector(dx: -2.5, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: 9, y: 15)
            antenna.zPosition = 1
            cursorCircle.run(SKAction.move(to: CGPoint(x: -100, y: -20), duration: 0.5))
        } else if moveTo == "Right" {
            self.run(SKAction.move(by: CGVector(dx: 2.5, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: -9, y: 15)
            antenna.zPosition = 1
            cursorCircle.run(SKAction.move(to: CGPoint(x: 100, y: -20), duration: 0.5))
        }
        
        if self.parent is MultiGameScene {
            let parent = self.parent as! MultiGameScene
            parent.sendPlayerInfo()
        }
    }
    
    func makePikminIdle() {
        var index = -1
        if pikminFollowing.count > 0 {
            makeIdleSound.run(SKAction.play())
            while index < pikminFollowing.count - 1 {
                index += 1
                pikminFollowing[index].idle = true
                pikminFollowing[index].returning = false
                pikminFollowing[index].run(SKAction.sequence([SKAction.wait(forDuration: Double(index)/100),pikminFollowing[index].pikminLeft]))
            }
            pikminFollowing.removeAll()
            pikminFollowing = [Pikmin]()
        }
    }
    
    func grabPikmin() {
        if pikminFollowing.count > 0 {
            var index = -1
            var found = false
            while index < pikminFollowing.count - 1 && !found {
                index += 1
                let distance = sqrt(pow(Double(self.position.x - pikminFollowing[index].position.x),2) + pow(Double(self.position.y - pikminFollowing[index].position.y),2))
                
                if !pikminFollowing[index].busy && !pikminFollowing[index].returning && distance <= 75 {
                    pikminToThrow = pikminFollowing[index]
                    found = true
                }
            }
        }
    }
    
    func throwPikmin() {
        if pikminToThrow != nil {
            let pikminChosen = pikminToThrow
            pikminChosen?.removeAllActions()
            pikminToThrow = Pikmin()
            let throwPosition = cursorCircle.position
            pikminChosen?.busy = true
            pikminChosen?.returning = true
            pikminChosen?.run((pikminChosen?.pikminThrow)!)
            
            func checkIfPikminIsFine() {
                let objectsPikminOn = self.parent!.nodes(at: (pikminChosen?.position)!)
                var attempts = 1
                var objectPikminOn = SKNode()
                
                if !objectsPikminOn.isEmpty {
                    objectPikminOn = objectsPikminOn[objectsPikminOn.count - attempts]
                }
                
                func checkPikminOn() {
                    if objectsPikminOn.count - attempts > 0 && !(objectPikminOn is Flower) && !(objectPikminOn is Nutrient) {
                        attempts += 1
                        objectPikminOn = objectsPikminOn[objectsPikminOn.count - attempts]
                        if !(objectPikminOn is Flower) && !(objectPikminOn is Nutrient) && objectsPikminOn.count - attempts > 0 {
                            checkPikminOn()
                        }
                    }
                }
                
                checkPikminOn()
                
                if objectPikminOn is Flower {
                    let flower = objectPikminOn as! Flower
                    flower.toggleOpen()
                    flower.pikminTaken += 1
                    var index = 0
                    var pikminFound = false
                    while index < pikminFollowing.count - 1 && !pikminFound {
                        if pikminChosen == pikminFollowing[index] {
                            pikminFound = true
                        } else {
                            index += 1
                        }
                    }
                    
                    pikminFollowing.remove(at: index)
                    pikminChosen?.removeFromParent()
                    pikminChosen?.removeAllActions()
                    pikminChosen?.removeAllChildren()
                } else if objectPikminOn is Nutrient {
                    pikminChosen?.run((pikminChosen?.pikminLand)!)
                    let nutrient = objectPikminOn as! Nutrient
                    pikminChosen?.carryNutrient(nutrient)
                } else {
                    pikminChosen?.run((pikminChosen?.pikminLand)!)
                    pikminChosen?.busy = false
                }
            }
            
            if self.playerDirection == "Left" {
                pikminChosen?.run(SKAction.rotate(byAngle: CGFloat(M_PI * 10), duration: 1),completion:{
                    pikminChosen?.run(SKAction.rotate(toAngle: CGFloat(M_PI * 2), duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + (pikminChosen?.throwHeight)!), duration: 0.5), completion:{
                    pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
                })
            } else if self.playerDirection == "Right" {
                pikminChosen?.run(SKAction.rotate(byAngle: CGFloat(-M_PI * 10), duration: 1),completion:{
                    pikminChosen?.run(SKAction.rotate(toAngle: CGFloat(-M_PI * 2), duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + (pikminChosen?.throwHeight)!), duration: 0.5), completion:{
                    pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
                })
            } else if self.playerDirection == "Up" {
                pikminChosen?.zRotation = CGFloat(M_PI)
                pikminChosen?.zPosition = self.zPosition - 1
                pikminChosen?.yScale = -1
                pikminChosen?.run(SKAction.repeat(SKAction.sequence([SKAction.scaleY(to: 1, duration: 1/10),SKAction.scaleY(to: -1, duration: 1/10)]),count: 5),completion:{
                    pikminChosen?.zRotation = 0
                    pikminChosen?.run(SKAction.scaleY(to: 1, duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x, y: self.position.y + throwPosition.y), duration: 1))
            } else if self.playerDirection == "Down" {
                pikminChosen?.zRotation = CGFloat(M_PI)
                pikminChosen?.zPosition = self.zPosition + 1
                pikminChosen?.yScale = -1
                pikminChosen?.run(SKAction.repeat(SKAction.sequence([SKAction.scaleY(to: 1, duration: 1/10),SKAction.scaleY(to: -1, duration: 1/10)]),count: 5),completion:{
                    pikminChosen?.zRotation = 0
                    pikminChosen?.run(SKAction.scaleY(to: 1, duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen?.run(SKAction.move(to: CGPoint(x: self.position.x + throwPosition.x, y: self.position.y + throwPosition.y), duration: 1))
            }
        }
    }
    
    func recallPikmin() {
        if !callingPikmin {
            callingPikmin = true
            callSound.run(SKAction.play())
            recallCircle.run(SKAction.scaleX(to: 25, y: 15, duration: 0.3),completion:{
                self.recallCircle.run(SKAction.scale(to: 1, duration: 0.6),completion:{
                    self.callingPikmin = false
                })
            })
        }
    }
}
