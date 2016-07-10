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
    var callSound = SKAction()
    var makeIdleSound = SKAction()
    var playerChars = ""
    
    var timeForSpace = false
    
    func setUp() {
        if character == "Olimar" {
            if character == "Olimar" {
                cursorCircle.strokeColor = SKColor.magentaColor()
                recallCircle.strokeColor = SKColor.redColor()
            } else if character == "Louie" {
                cursorCircle.strokeColor = SKColor.blueColor()
                recallCircle.strokeColor = SKColor.blueColor()
            }
            
            cursorCircle.glowWidth = 0.5
            cursorCircle.alpha = 1
            cursorCircle.yScale = 0.6
            recallCircle.glowWidth = 0.1
            recallCircle.alpha = 1
            recallCircle.position.y = -20
            
            callSound = SKAction.playSoundFileNamed("call", waitForCompletion: false)
            makeIdleSound = SKAction.playSoundFileNamed("call", waitForCompletion: false)

            addChild(cursorCircle)
            addChild(recallCircle)
            antenna = SKSpriteNode(imageNamed:"RedGlow")
            antenna.setScale(1)
            antenna.position = CGPoint(x: 0, y: 20)
            let glowEffect = SKAction.sequence([SKAction.scaleTo(0.7, duration: 1.3),SKAction.scaleTo(0.9, duration: 0.7)])
            antenna.runAction(SKAction.repeatActionForever(glowEffect))
            self.addChild(antenna)
        }
    }
    
    func move() {
        if moveTo != "" {
            playerDirection = moveTo
        }
        
        let graphic = character + "_" + playerDirection + "_"
        
        if moveTo != "" && playerLastDirection != playerDirection {
            playerLastDirection = playerDirection
            self.removeAllActions()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:graphic + "Run1"),SKTexture(imageNamed:graphic + "Run2"),SKTexture(imageNamed:graphic + "Run3"),SKTexture(imageNamed:graphic + "Run4")], timePerFrame: 0.12)))
        } else if moveTo == "" {
            /*
            if self.parent is MultiGameScene && playerLastDirection != "" {
                let parent = self.parent as! MultiGameScene
                if parent.ThePlayer == self {
                    parent.sendCorrectedPos(self)
                }
            }
            */
            playerLastDirection = ""
            self.removeAllActions()
            self.runAction(SKAction.setTexture(SKTexture(imageNamed:graphic + "Stand")))
        }
        
        if moveTo == "Down" {
            self.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -2), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = -1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 0, y: -80), duration: 0.5))
        } else if moveTo == "Up" {
            self.runAction(SKAction.moveBy(CGVector(dx: 0, dy: 2), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 0, y: 40), duration: 0.5))
        } else if moveTo == "Left" {
            self.runAction(SKAction.moveBy(CGVector(dx: -2.5, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: 9, y: 15)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: -100, y: -20), duration: 0.5))
        } else if moveTo == "Right" {
            self.runAction(SKAction.moveBy(CGVector(dx: 2.5, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: -9, y: 15)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 100, y: -20), duration: 0.5))
        }
        /*
        if self.parent is MultiGameScene {
            let parent = self.parent as! MultiGameScene
            parent.sendPlayerInfo()
        }
        */
    }
    
    func makePikminIdle() {
        var index = -1
        if pikminFollowing.count > 0 {
            self.parent!.runAction(makeIdleSound)
            while index < pikminFollowing.count - 1 {
                index += 1
                pikminFollowing[index].idle = true
                pikminFollowing[index].returning = false
                pikminFollowing[index].runAction(SKAction.sequence([SKAction.waitForDuration(Double(index)/100),pikminFollowing[index].pikminLeft]))
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
            pikminChosen.removeAllActions()
            pikminToThrow = Pikmin()
            let throwPosition = cursorCircle.position
            pikminChosen.busy = true
            pikminChosen.returning = true
            pikminChosen.runAction(pikminChosen.pikminThrow)
            
            func checkIfPikminIsFine() {
                let objectsPikminOn = self.parent!.nodesAtPoint(pikminChosen.position)
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
                    
                    pikminFollowing.removeAtIndex(index)
                    pikminChosen.removeFromParent()
                    pikminChosen.removeAllActions()
                    pikminChosen.removeAllChildren()
                } else if objectPikminOn is Nutrient {
                    pikminChosen.runAction(pikminChosen.pikminLand)
                    let nutrient = objectPikminOn as! Nutrient
                    pikminChosen.carryNutrient(nutrient)
                } else {
                    pikminChosen.runAction(pikminChosen.pikminLand)
                    pikminChosen.busy = false
                }
            }
            
            if self.playerDirection == "Left" {
                pikminChosen.runAction(SKAction.rotateByAngle(CGFloat(M_PI * 10), duration: 1),completion:{
                    pikminChosen.runAction(SKAction.rotateToAngle(CGFloat(M_PI * 2), duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + pikminChosen.throwHeight), duration: 0.5), completion:{
                    pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
                })
            } else if self.playerDirection == "Right" {
                pikminChosen.runAction(SKAction.rotateByAngle(CGFloat(-M_PI * 10), duration: 1),completion:{
                    pikminChosen.runAction(SKAction.rotateToAngle(CGFloat(-M_PI * 2), duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + pikminChosen.throwHeight), duration: 0.5), completion:{
                    pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
                })
            } else if self.playerDirection == "Up" {
                pikminChosen.zRotation = CGFloat(M_PI)
                pikminChosen.zPosition = self.zPosition - 1
                pikminChosen.yScale = -1
                pikminChosen.runAction(SKAction.repeatAction(SKAction.sequence([SKAction.scaleYTo(1, duration: 1/10),SKAction.scaleYTo(-1, duration: 1/10)]),count: 5),completion:{
                    pikminChosen.zRotation = 0
                    pikminChosen.runAction(SKAction.scaleYTo(1, duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y + throwPosition.y), duration: 1))
            } else if self.playerDirection == "Down" {
                pikminChosen.zRotation = CGFloat(M_PI)
                pikminChosen.zPosition = self.zPosition + 1
                pikminChosen.yScale = -1
                pikminChosen.runAction(SKAction.repeatAction(SKAction.sequence([SKAction.scaleYTo(1, duration: 1/10),SKAction.scaleYTo(-1, duration: 1/10)]),count: 5),completion:{
                    pikminChosen.zRotation = 0
                    pikminChosen.runAction(SKAction.scaleYTo(1, duration: 0.05),completion:{
                        checkIfPikminIsFine()
                    })
                })
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y + throwPosition.y), duration: 1))
            }
        }
    }
    
    func recallPikmin() {
        if !callingPikmin {
            callingPikmin = true
            self.parent!.runAction(callSound)
            recallCircle.runAction(SKAction.scaleXTo(25, y: 15, duration: 0.3),completion:{
                self.recallCircle.runAction(SKAction.scaleTo(1, duration: 0.6),completion:{
                    self.callingPikmin = false
                })
            })
        }
    }
}