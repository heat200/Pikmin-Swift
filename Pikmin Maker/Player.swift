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
    var cursorCircle = SKShapeNode(circleOfRadius: 10)
    let recallCircle = SKShapeNode(circleOfRadius: 5)
    let callSound = SKAudioNode(fileNamed: "call")
    let makeIdleSound = SKAudioNode(fileNamed: "call")
    
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
            recallCircle.glowWidth = 0.5
            recallCircle.alpha = 1
            recallCircle.position.y = -20
            callSound.autoplayLooped = false
            callSound.positional = true
            callSound.runAction(SKAction.changePlaybackRateTo(0.85, duration: 1))
            makeIdleSound.autoplayLooped = false
            makeIdleSound.positional = true
            makeIdleSound.runAction(SKAction.changePlaybackRateTo(1.2, duration: 1))
            makeIdleSound.runAction(SKAction.changeReverbTo(0.2, duration: 1))
            addChild(cursorCircle)
            addChild(recallCircle)
            addChild(callSound)
            addChild(makeIdleSound)
            antenna = SKSpriteNode(imageNamed:"RedGlow")
            antenna.setScale(1)
            antenna.position = CGPoint(x: 0, y: 20)
            let glowEffect = SKAction.sequence([SKAction.scaleTo(0.7, duration: 1.3),SKAction.scaleTo(0.9, duration: 0.7)])
            antenna.runAction(SKAction.repeatActionForever(glowEffect))
            self.addChild(antenna)
        }
    }
    
    func move(direction:String) {
        if direction != "" {
            playerDirection = direction
        }
        let graphic = character + "_" + playerDirection + "_"
        
        if direction != "" && playerLastDirection != playerDirection {
            playerLastDirection = playerDirection
            self.removeAllActions()
            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([SKTexture(imageNamed:graphic + "Run1"),SKTexture(imageNamed:graphic + "Run2"),SKTexture(imageNamed:graphic + "Run3"),SKTexture(imageNamed:graphic + "Run4")], timePerFrame: 0.12)))
        } else if direction == "" {
            playerLastDirection = ""
            self.removeAllActions()
            self.runAction(SKAction.setTexture(SKTexture(imageNamed:graphic + "Stand")))
        }
        
        if direction == "Down" {
            self.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -10), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = -1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 0, y: -100), duration: 0.5))
        } else if direction == "Up" {
            self.runAction(SKAction.moveBy(CGVector(dx: 0, dy: 10), duration: 0.25))
            antenna.position = CGPoint(x: 0, y: 20)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 0, y: 100), duration: 0.5))
        } else if direction == "Left" {
            self.runAction(SKAction.moveBy(CGVector(dx: -10, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: 9, y: 15)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: -100, y: -20), duration: 0.5))
        } else if direction == "Right" {
            self.runAction(SKAction.moveBy(CGVector(dx: 10, dy: 0), duration: 0.25))
            antenna.position = CGPoint(x: -9, y: 15)
            antenna.zPosition = 1
            cursorCircle.runAction(SKAction.moveTo(CGPoint(x: 100, y: -20), duration: 0.5))
        }
    }
    
    func makePikminIdle() {
        var index = -1
        if pikminFollowing.count > 0 {
            makeIdleSound.runAction(SKAction.play())
            while index < pikminFollowing.count - 1 {
                index += 1
                pikminFollowing[index].idle = true
                pikminFollowing[index].returning = false
            }
            pikminFollowing.removeAll()
            pikminFollowing = [Pikmin]()
        }
    }
    
    func grabPikmin() {
        if pikminFollowing.count > 0 {
            var index = -1
            while index < pikminFollowing.count - 1 {
                index += 1
                if !pikminFollowing[index].busy && !pikminFollowing[index].returning {
                    pikminToThrow = pikminFollowing[index]
                }
            }
        }
    }
    
    func throwPikmin() {
        let pikminChosen = pikminToThrow
        pikminToThrow = Pikmin()
        let throwPosition = cursorCircle.position
        pikminChosen.busy = true
        pikminChosen.returning = true
        pikminChosen.pikminThrow.runAction(SKAction.play())
        
        func checkIfPikminIsFine() {
            if self.parent!.nodeAtPoint(pikminChosen.position) is Flower {
                let flower = self.parent!.nodeAtPoint(pikminChosen.position) as! Flower
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
            } else if self.parent!.nodeAtPoint(pikminChosen.position) is Nutrient {
                let nutrient = self.parent!.nodeAtPoint(pikminChosen.position) as! Nutrient
                pikminChosen.carryNutrient(nutrient)
            } else {
                pikminChosen.busy = false
            }
        }
        
        if self.playerDirection == "Left" {
            pikminChosen.runAction(SKAction.rotateByAngle(CGFloat(M_PI * 12), duration: 1),completion:{
                pikminChosen.runAction(SKAction.rotateToAngle(CGFloat(M_PI * 2), duration: 0.05),completion:{
                    checkIfPikminIsFine()
                })
            })
            pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + pikminChosen.throwHeight), duration: 0.5), completion:{
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
            })
        } else if self.playerDirection == "Right" {
            pikminChosen.runAction(SKAction.rotateByAngle(CGFloat(-M_PI * 12), duration: 1),completion:{
                pikminChosen.runAction(SKAction.rotateToAngle(CGFloat(-M_PI * 2), duration: 0.05),completion:{
                    checkIfPikminIsFine()
                })
            })
            pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x/2, y: self.position.y + pikminChosen.throwHeight), duration: 0.5), completion:{
                pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y), duration: 0.5))
            })
        } else {
            pikminChosen.runAction(SKAction.rotateByAngle(CGFloat(M_PI * 12), duration: 1),completion:{
                pikminChosen.runAction(SKAction.rotateToAngle(CGFloat(M_PI * 2), duration: 0.05),completion:{
                    checkIfPikminIsFine()
                })
            })
            pikminChosen.runAction(SKAction.moveTo(CGPoint(x: self.position.x + throwPosition.x, y: self.position.y + throwPosition.y), duration: 1))
        }
    }
    
    func recallPikmin() {
        if !callingPikmin {
            callingPikmin = true
            callSound.runAction(SKAction.play())
            recallCircle.runAction(SKAction.scaleXTo(15, y: 9, duration: 0.3),completion:{
                self.recallCircle.runAction(SKAction.scaleTo(0, duration: 0.6),completion:{
                    self.callingPikmin = false
                })
            })
        }
    }
}