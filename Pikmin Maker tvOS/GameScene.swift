//
//  GameScene.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

let BackmostLayer:CGFloat = 0
let BackLayer:CGFloat = 10
let MidLayer:CGFloat = 20
let FrontLayer:CGFloat = 30
let UILayer:CGFloat = 40

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone
    case Pad
}

class GameScene:SKScene {
    var ThePlayer = Player(imageNamed:"Olimar_Down_Stand")
    var TheShip = Ship(imageNamed:"Ship_Empty")
    let RedOnion = Onion(imageNamed:"Onion_Inactive")
    let BlueOnion = Onion(imageNamed:"Onion_Inactive")
    let YellowOnion = Onion(imageNamed:"Onion_Inactive")
    
    let Space = SKSpriteNode(imageNamed:"space")
    
    var sundial = SKShapeNode(circleOfRadius: 20)
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    var nightOverlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 10, height: 10)))
    
    var existingPikmin = [Pikmin]()
    var population = 0
    
    var movingSpace = false
    
    var previousTouch = CGPoint(x: 0, y: 0)
    
    var lastTime = 0.0
    var day = true
    var gameTime = 12
    
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
        TheShip.zPosition = BackLayer - 2
        TheShip.setUp()
        
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
        
        sundial.zPosition = 1
        sundial.position = CGPoint(x: 0, y: self.frame.height/2 - 20)
        sundial.fillColor = SKColor.yellowColor()
        sundial.alpha = 1
        self.camera!.addChild(sundial)
        
        self.camera?.zPosition = UILayer
        
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
            nutrient.zPosition = BackLayer - 3
            self.addChild(nutrient)
        }
        
        var timeBubblesAdded = 0
        while timeBubblesAdded < 13 {
            var radius:CGFloat = 5
            if timeBubblesAdded == 0 || timeBubblesAdded == 6 || timeBubblesAdded == 12 {
                radius = 10
            }
            let timeBubble = SKShapeNode(circleOfRadius: radius)
            timeBubble.position = CGPoint(x: -self.frame.width/2 + 25 + (43 * CGFloat(timeBubblesAdded)), y: self.frame.height/2 - 20)
            timeBubblesAdded += 1
            timeBubble.name = "TimeBubble" + String(timeBubblesAdded)
            timeBubble.fillColor = SKColor.grayColor()
            timeBubble.alpha = 0.65
            self.camera?.addChild(timeBubble)
        }
        
        self.addChild(ThePlayer)
        self.addChild(MAP)
        self.addChild(RedOnion)
        self.addChild(BlueOnion)
        self.addChild(YellowOnion)
        self.addChild(TheShip)
        self.addChild(PurpleFlower)
        self.addChild(WhiteFlower)
        self.addChild(Space)
        self.addChild(backgroundMusic)
        
        
        
        RedOnion.randomizePosition()
        YellowOnion.randomizePosition()
        BlueOnion.randomizePosition()
        WhiteFlower.randomizePosition()
        PurpleFlower.randomizePosition()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if abs(location.y - previousTouch.y) > abs(location.x - previousTouch.x) && location.y - previousTouch.y > 0 {
                previousTouch = location
                if TheShip.followShip {
                    TheShip.toMultiplayer()
                } else {
                    ThePlayer.moveTo = "Up"
                }
            } else if abs(location.y - previousTouch.y) < abs(location.x - previousTouch.x) && location.x - previousTouch.x > 0 {
                previousTouch = location
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
            } else if abs(location.y - previousTouch.y) < abs(location.x - previousTouch.x) && location.y - previousTouch.y < 0 {
                previousTouch = location
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
            } else if abs(location.y - previousTouch.y) > abs(location.x - previousTouch.x) && location.y - previousTouch.y < 0 {
                previousTouch = location
                if TheShip.followShip {
                    TheShip.backToEarth()
                } else {
                    ThePlayer.moveTo = "Down"
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if ThePlayer.moveTo != "" {
                ThePlayer.moveTo = ""
                previousTouch.x = 0
                previousTouch.y = 0
            }
        }
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIEvent?) {
        print("Pressed")
        for press in presses {
            let button = press.type
            let objectsPlayerOn = self.nodesAtPoint(ThePlayer.position)
            var attempts = 1
            var objectPlayerOn = objectsPlayerOn[objectsPlayerOn.count - attempts]
            
            func checkPlayerOn() {
                if objectsPlayerOn.count - attempts > 0 && !(objectPlayerOn is Onion) && !(objectPlayerOn is Ship) && !(objectPlayerOn is Seed) {
                    attempts += 1
                    objectPlayerOn = objectsPlayerOn[objectsPlayerOn.count - attempts]
                    if !(objectPlayerOn is Onion) && !(objectPlayerOn is Ship) && !(objectPlayerOn is Seed) && objectsPlayerOn.count - attempts > 0 {
                        checkPlayerOn()
                    } else if (objectPlayerOn is Onion) {
                        if (objectPlayerOn as! Onion).awakened {
                            checkPlayerOn()
                        }
                    }
                }
            }
            
            checkPlayerOn()
            print("Button Type: " + String(button))
            if button == .UpArrow {
                print("Pressed Up")
                if TheShip.followShip {
                    TheShip.toMultiplayer()
                } else {
                    ThePlayer.moveTo = "Up"
                }
            } else if button == .RightArrow {
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
            } else if button == .LeftArrow {
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
            } else if button == .DownArrow {
                if TheShip.followShip {
                    TheShip.backToEarth()
                } else {
                    ThePlayer.moveTo = "Down"
                }
            }
            
            if button == .Select {
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
            } else if button == .Menu {
                print("Pressed Menu")
                ThePlayer.makePikminIdle()
            } else if button == .PlayPause {
                print("Pressed PlayPause")
                ThePlayer.recallPikmin()
            }
        }
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIEvent?) {
        for press in presses {
            let button = press.type
            if button == .UpArrow || button == .DownArrow || button == .LeftArrow || button == .RightArrow {
                ThePlayer.moveTo = ""
            }
            
            if button == .Select {
                print("Let Go Of Select")
                if ThePlayer.pikminToThrow != nil {
                    ThePlayer.throwPikmin()
                }
            } else if button == .PlayPause {
                print("Let Go Of Play/Pause")
                ThePlayer.recallCircle.removeAllActions()
                ThePlayer.recallCircle.runAction(SKAction.scaleTo(1, duration: 0.15),completion:{
                    self.ThePlayer.callingPikmin = false
                })
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        let timeFrame:Double = 30
        if currentTime - lastTime >= timeFrame {
            lastTime = currentTime
            if gameTime == 23 {
                gameTime = 0
            } else {
                gameTime += 1
            }
            
            if gameTime == 7 {
                sundial.fillColor = SKColor.yellowColor()
                let marker1 = self.camera!.childNodeWithName("TimeBubble1")!
                let marker2 = self.camera!.childNodeWithName("TimeBubble2")!
                sundial.position = marker1.position
                sundial.runAction(SKAction.moveTo(marker2.position, duration: timeFrame - 0.5))
            } else if gameTime == 8 {
                let marker3 = self.camera!.childNodeWithName("TimeBubble3")!
                sundial.runAction(SKAction.moveTo(marker3.position, duration: timeFrame - 0.5))
            } else if gameTime == 9 {
                let marker4 = self.camera!.childNodeWithName("TimeBubble4")!
                sundial.runAction(SKAction.moveTo(marker4.position, duration: timeFrame - 0.5))
            } else if gameTime == 10 {
                let marker5 = self.camera!.childNodeWithName("TimeBubble5")!
                sundial.runAction(SKAction.moveTo(marker5.position, duration: timeFrame - 0.5))
            } else if gameTime == 11 {
                let marker6 = self.camera!.childNodeWithName("TimeBubble6")!
                sundial.runAction(SKAction.moveTo(marker6.position, duration: timeFrame - 0.5))
            } else if gameTime == 12 {
                let marker6 = self.camera!.childNodeWithName("TimeBubble6")!
                let marker7 = self.camera!.childNodeWithName("TimeBubble7")!
                sundial.position = marker6.position
                sundial.runAction(SKAction.moveTo(marker7.position, duration: timeFrame - 0.5))
            } else if gameTime == 13 {
                let marker7 = self.camera!.childNodeWithName("TimeBubble7")!
                let marker8 = self.camera!.childNodeWithName("TimeBubble8")!
                sundial.position = marker7.position
                sundial.runAction(SKAction.moveTo(marker8.position, duration: timeFrame - 0.5))
            } else if gameTime == 14 {
                let marker9 = self.camera!.childNodeWithName("TimeBubble9")!
                sundial.runAction(SKAction.moveTo(marker9.position, duration: timeFrame - 0.5))
            } else if gameTime == 15 {
                let marker10 = self.camera!.childNodeWithName("TimeBubble10")!
                sundial.runAction(SKAction.moveTo(marker10.position, duration: timeFrame - 0.5))
            } else if gameTime == 16 {
                let marker11 = self.camera!.childNodeWithName("TimeBubble11")!
                sundial.runAction(SKAction.moveTo(marker11.position, duration: timeFrame - 0.5))
            } else if gameTime == 17 {
                let marker12 = self.camera!.childNodeWithName("TimeBubble12")!
                sundial.runAction(SKAction.moveTo(marker12.position, duration: timeFrame - 0.5))
            } else if gameTime == 18 {
                let marker13 = self.camera!.childNodeWithName("TimeBubble13")!
                sundial.runAction(SKAction.moveTo(marker13.position, duration: timeFrame - 0.5))
            } else if gameTime == 19 {
                let marker1 = self.camera!.childNodeWithName("TimeBubble1")!
                sundial.runAction(SKAction.moveTo(marker1.position, duration: (timeFrame * 12) - 0.5))
                sundial.fillColor = SKColor.whiteColor()
            }
            
            if gameTime > 19 || gameTime < 7 {
                let aMonster = Monster(imageNamed:"Monster_Red_Bulborb_Down_Stand")
                aMonster.zPosition = BackLayer
                aMonster.monsterSpecies = "Red_Bulborb"
                aMonster.setUp()
                self.addChild(aMonster)
                aMonster.randomizePosition()
            }
            
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
                        self.Space.position.y = self.TheShip.position.y - 1200
                    })])
                    Space.position.y = TheShip.position.y - 1550
                    Space.runAction(SKAction.repeatActionForever(spaceZoom))
                }
            }
        }
    }
}