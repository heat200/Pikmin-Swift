//
//  GameScene.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

let BackmostLayer:CGFloat = 0
let BackLayer:CGFloat = 5
let MidLayer:CGFloat = 10
let FrontLayer:CGFloat = 15
let UILayer:CGFloat = 20

class GameScene:SKScene {
    var ThePlayer = Player(imageNamed:"Olimar_Down_Stand")
    let RedOnion = Onion(imageNamed:"Onion_Inactive")
    let BlueOnion = Onion(imageNamed:"Onion_Inactive")
    let YellowOnion = Onion(imageNamed:"Onion_Inactive")
    
    let TheShip = Ship(imageNamed:"Ship_Empty")
    
    let Space = SKSpriteNode(imageNamed:"space")
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    
    var nightOverlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 10, height: 10)))
    
    var movingSpace = false
    
    var lastTime:Double = 0
    var day = true
    
    override func didMoveToView(view: SKView) {
        MAP.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        MAP.zPosition = BackmostLayer
        
        ThePlayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ThePlayer.zPosition = BackLayer
        ThePlayer.setUp()
        
        RedOnion.onionColor = "Red"
        RedOnion.zPosition = MidLayer
        
        BlueOnion.onionColor = "Blue"
        BlueOnion.zPosition = MidLayer
        
        YellowOnion.onionColor = "Yellow"
        YellowOnion.zPosition = MidLayer
        
        backgroundMusic.autoplayLooped = true
        
        let PurpleFlower = Flower(imageNamed:"Flower_Purple_Open")
        PurpleFlower.zPosition = MidLayer
        PurpleFlower.flowerColor = "Purple"
        
        let WhiteFlower = Flower(imageNamed:"Flower_White_Open")
        WhiteFlower.zPosition = MidLayer
        
        TheShip.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 300)
        TheShip.zPosition = FrontLayer
        
        Space.zPosition = BackmostLayer - 1
        Space.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.size.height/2)
        Space.setScale(4)
        
        nightOverlay = SKShapeNode(rect: self.frame)
        nightOverlay.zPosition = -1
        nightOverlay.position = CGPoint(x: -self.frame.width/2, y: -self.frame.height/2)
        nightOverlay.fillColor = SKColor.blackColor()
        nightOverlay.alpha = 0.0
        nightOverlay.strokeColor = SKColor.clearColor()
        self.camera!.addChild(nightOverlay)
        
        var nutrientsAdded = 0
        while nutrientsAdded < 75 {
            nutrientsAdded += 1
            var color = "Red"
            let rand = Int(arc4random_uniform(3) + 1)
            let randX:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
            let randY:CGFloat = CGFloat(Int(arc4random_uniform(1500)) - 750)
            
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
            nutrient.zPosition = MidLayer - 1
            self.addChild(nutrient)
        }
        
        self.addChild(ThePlayer)
        self.addChild(MAP)
        self.addChild(RedOnion)
        self.addChild(BlueOnion)
        self.addChild(YellowOnion)
        self.addChild(PurpleFlower)
        self.addChild(WhiteFlower)
        self.addChild(TheShip)
        self.addChild(Space)
        self.addChild(backgroundMusic)
        
        RedOnion.randomizePosition()
        YellowOnion.randomizePosition()
        BlueOnion.randomizePosition()
        WhiteFlower.randomizePosition()
        PurpleFlower.randomizePosition()
    }
    
    override func keyDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let objectTouched = self.nodeAtPoint(location)
        let objectPlayerOn = self.nodeAtPoint(ThePlayer.position)
        let chars = theEvent.characters!
        if chars.containsString("w") {
            if TheShip.followShip {
                TheShip.toMultiplayer()
            } else {
                ThePlayer.moveTo = "Up"
            }
        } else if chars.containsString("d") {
            if TheShip.followShip {
                if TheShip.player == "1" {
                    TheShip.player = "2"
                } else {
                    TheShip.player = "1"
                }
                print(TheShip.player)
            } else {
                ThePlayer.moveTo = "Right"
            }
        } else if chars.containsString("a") {
            if TheShip.followShip {
                if TheShip.player == "1" {
                    TheShip.player = "2"
                } else {
                    TheShip.player = "1"
                }
                print(TheShip.player)
            } else {
                ThePlayer.moveTo = "Left"
            }
        } else if chars.containsString("s") {
            if TheShip.followShip {
                TheShip.backToEarth()
            } else {
                ThePlayer.moveTo = "Down"
            }
        }
        
        if chars.containsString(" ") {
            if (objectPlayerOn is Onion) && !((objectPlayerOn as? Onion)?.awakened)! {
                let onion = objectPlayerOn as! Onion
                onion.wake()
            } else if objectPlayerOn is Seed {
                let seed = objectPlayerOn as! Seed
                seed.unrootPikmin(ThePlayer)
            } else if objectPlayerOn is Ship {
                let ship = objectPlayerOn as! Ship
                ship.getIn(ThePlayer)
            } else {
                ThePlayer.grabPikmin()
            }
        } else if chars.containsString("q") {
            ThePlayer.makePikminIdle()
        } else if chars.containsString("b") {
            ThePlayer.recallPikmin()
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        let chars = theEvent.characters!
        if chars.containsString("w") || chars.containsString("a") || chars.containsString("s") || chars.containsString("d") {
            ThePlayer.moveTo = ""
        }
        
        if chars.containsString(" ") {
            if ThePlayer.pikminToThrow != nil {
                ThePlayer.throwPikmin()
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        let timeFrame:Double = 2
        if currentTime - lastTime >= timeFrame {
            lastTime = currentTime
            if day {
                nightOverlay.runAction(SKAction.fadeAlphaTo(nightOverlay.alpha + 0.05, duration: timeFrame - timeFrame/60))
                if nightOverlay.alpha >= 0.7 {
                    nightOverlay.alpha = 0.7
                    day = false
                }
            } else {
                nightOverlay.runAction(SKAction.fadeAlphaTo(nightOverlay.alpha - 0.05, duration: timeFrame - timeFrame/60))
                if nightOverlay.alpha <= 0.0 {
                    nightOverlay.alpha = 0.0
                    day = true
                }
            }
        }
        
        if !TheShip.followShip {
            self.camera!.position = ThePlayer.position
            ThePlayer.move()
        } else {
            self.camera!.position = TheShip.position
            if !movingSpace {
                movingSpace = true
                if !TheShip.returning {
                    Space.removeAllActions()
                    let spaceZoom = SKAction.sequence([SKAction.moveBy(CGVector(dx: 0, dy: -750), duration: 9),SKAction.runBlock({
                        self.Space.position.x = self.TheShip.position.x
                        self.Space.position.y = self.TheShip.position.y + 1100
                    })])
                    Space.position.y = TheShip.position.y + 1550
                    Space.runAction(SKAction.repeatActionForever(spaceZoom))
                } else {
                    Space.removeAllActions()
                    let spaceZoom = SKAction.sequence([SKAction.moveBy(CGVector(dx: 0, dy: 500), duration: 6),SKAction.runBlock({
                        self.Space.position.x = self.TheShip.position.x
                        self.Space.position.y = self.TheShip.position.y - 900
                    })])
                    Space.position.y = TheShip.position.y - 1550
                    Space.runAction(SKAction.repeatActionForever(spaceZoom))
                }
            }
        }
    }
}