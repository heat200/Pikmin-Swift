//
//  GameScene.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

let BackmostLayer:CGFloat = -999999
let BackLayer:CGFloat = 10
let MidLayer:CGFloat = 20
let FrontLayer:CGFloat = 30
let UILayer:CGFloat = 999999

enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone
    case pad
}

class GameScene:SKScene {
    var ThePlayer = Player(imageNamed:"Olimar_Down_Stand")
    var TheShip = Ship(imageNamed:"Ship_Empty")
    let RedOnion = Onion(imageNamed:"Onion_Inactive")
    let BlueOnion = Onion(imageNamed:"Onion_Inactive")
    let YellowOnion = Onion(imageNamed:"Onion_Inactive")
    
    let Space = SKSpriteNode(imageNamed:"space")
    
    var UP_BTN = SKShapeNode(circleOfRadius: 35)
    var DOWN_BTN = SKShapeNode(circleOfRadius: 35)
    var LEFT_BTN = SKShapeNode(circleOfRadius: 35)
    var RIGHT_BTN = SKShapeNode(circleOfRadius: 35)
    var ACTION_BTN = SKShapeNode(circleOfRadius: 35)
    var CALL_BTN = SKShapeNode(circleOfRadius: 35)
    var IDLE_BTN = SKShapeNode(circleOfRadius: 35)
    var ZOOM_BTN = SKShapeNode(circleOfRadius: 35)
    
    var sundial = SKShapeNode(circleOfRadius: 20)
    
    var pikminCount = SKLabelNode()
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    var nightOverlay = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 10, height: 10)))
    
    var existingPikmin = [Pikmin]()
    var pikminOut = 0
    var population = 0
    
    var redPopulation = 0
    var bluePopulation = 0
    var yellowPopulation = 0
    
    var whitePopulation = 0
    var purplePopulation = 0
    
    var movingSpace = false
    
    var lastTime = 0.0
    var day = true
    var gameTime = 12
    
    var trueSemiWidth:CGFloat!
    var trueSemiHeight:CGFloat!
    
    var timeFrame:Double = 30
    
    override func didMove(to view: SKView) {
        trueSemiWidth = self.frame.width/2
        trueSemiHeight = self.frame.height/2
        MAP.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        MAP.zPosition = BackmostLayer
        
        ThePlayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ThePlayer.zPosition = (ThePlayer.position.y - ThePlayer.size.height/2) * -1
        ThePlayer.setUp()
        
        RedOnion.onionColor = "Red"
        RedOnion.zPosition = (RedOnion.position.y - RedOnion.size.height/2) * -1
        
        BlueOnion.onionColor = "Blue"
        BlueOnion.zPosition = (BlueOnion.position.y - BlueOnion.size.height/2) * -1
        
        YellowOnion.onionColor = "Yellow"
        YellowOnion.zPosition = (YellowOnion.position.y - YellowOnion.size.height/2) * -1
        
        backgroundMusic.autoplayLooped = true
        
        let PurpleFlower = Flower(imageNamed:"Flower_Purple_Open")
        PurpleFlower.zPosition = PurpleFlower.position.y - PurpleFlower.size.height/2
        PurpleFlower.flowerColor = "Purple"
        
        let WhiteFlower = Flower(imageNamed:"Flower_White_Open")
        WhiteFlower.zPosition = WhiteFlower.position.y - WhiteFlower.size.height/2
        
        TheShip.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 300)
        TheShip.zPosition = (TheShip.position.y - TheShip.size.height/2) * -1
        TheShip.setUp()
        
        Space.zPosition = BackmostLayer - 1
        Space.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.size.height/2)
        Space.setScale(4)
        
        nightOverlay = SKShapeNode(rect: self.frame)
        nightOverlay.zPosition = -1
        nightOverlay.position = CGPoint(x: -self.frame.width/2, y: -self.frame.height/2)
        nightOverlay.fillColor = SKColor.black
        nightOverlay.alpha = 0.0
        nightOverlay.strokeColor = SKColor.clear
        self.camera!.addChild(nightOverlay)
        
        sundial.zPosition = 1
        sundial.position = CGPoint(x: 0, y: self.frame.height/2 - 20)
        sundial.fillColor = SKColor.yellow
        sundial.alpha = 1
        self.camera!.addChild(sundial)
        
        pikminCount.zPosition = 1
        pikminCount.horizontalAlignmentMode = .right
        pikminCount.position = CGPoint(x: self.frame.width/2 - 50, y: self.frame.height/2 - 26)
        pikminCount.alpha = 1
        self.camera!.addChild(pikminCount)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let semiWidth = self.frame.width/2
            let semiHeight = self.frame.height/2
            UP_BTN.fillColor = SKColor.gray
            UP_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 + 50)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.gray
            DOWN_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 - 50)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.gray
            LEFT_BTN.position = CGPoint(x: -semiWidth + 100 - 50, y: -semiHeight + 100)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.gray
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 100 + 50, y: -semiHeight + 100)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.green
            ACTION_BTN.position = CGPoint(x: semiWidth - 100, y: -semiHeight + 100)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.gray
            IDLE_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 + 50)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.red
            CALL_BTN.position = CGPoint(x: semiWidth - 100 - 50, y: -semiHeight + 100 - 50)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyan
            ZOOM_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 - 50)
            ZOOM_BTN.alpha = 0.65
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            UP_BTN = SKShapeNode(circleOfRadius: 35)
            DOWN_BTN = SKShapeNode(circleOfRadius: 35)
            LEFT_BTN = SKShapeNode(circleOfRadius: 35)
            RIGHT_BTN = SKShapeNode(circleOfRadius: 35)
            ACTION_BTN = SKShapeNode(circleOfRadius: 35)
            CALL_BTN = SKShapeNode(circleOfRadius: 35)
            IDLE_BTN = SKShapeNode(circleOfRadius: 35)
            ZOOM_BTN = SKShapeNode(circleOfRadius: 25)
            
            let semiWidth = self.frame.width/3
            let semiHeight = self.frame.height/4
            
            UP_BTN.fillColor = SKColor.gray
            UP_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight + 60)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.gray
            DOWN_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight - 40)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.gray
            LEFT_BTN.position = CGPoint(x: -semiWidth - 50, y: -semiHeight + 10)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.gray
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 50, y: -semiHeight + 10)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.green
            ACTION_BTN.position = CGPoint(x: semiWidth, y: -semiHeight + 10)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.gray
            IDLE_BTN.position = CGPoint(x: semiWidth + 50, y: -semiHeight + 60)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.red
            CALL_BTN.position = CGPoint(x: semiWidth - 50, y: -semiHeight - 40)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyan
            ZOOM_BTN.position = CGPoint(x: semiWidth + 50, y: -semiHeight - 40)
            ZOOM_BTN.alpha = 0.65
        }
        
        self.camera?.zPosition = UILayer
        self.camera?.addChild(UP_BTN)
        self.camera?.addChild(DOWN_BTN)
        self.camera?.addChild(LEFT_BTN)
        self.camera?.addChild(RIGHT_BTN)
        self.camera?.addChild(ACTION_BTN)
        self.camera?.addChild(IDLE_BTN)
        self.camera?.addChild(CALL_BTN)
        self.camera?.addChild(ZOOM_BTN)
        
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
            nutrient.zPosition = (nutrient.position.y - nutrient.size.height/2) * -1
            self.addChild(nutrient)
        }
        
        var devicesAdded = 0
        while devicesAdded < 10 {
            devicesAdded += 1
            
            let device = Machine(imageNamed:"Electrode_Inactive")
            self.addChild(device)
            device.randomizePosition()
            device.setUp()
            device.zPosition = (device.position.y - device.size.height/2) * -1
        }
        
        var timeBubblesAdded = 0
        while timeBubblesAdded < 13 {
            var radius:CGFloat = 5
            if timeBubblesAdded == 0 || timeBubblesAdded == 6 || timeBubblesAdded == 12 {
                radius = 10
            }
            let timeBubble = SKShapeNode(circleOfRadius: radius)
            timeBubble.position = CGPoint(x: -trueSemiWidth + 25 + (43 * CGFloat(timeBubblesAdded)), y: trueSemiHeight - 20)
            timeBubblesAdded += 1
            timeBubble.name = "TimeBubble" + String(timeBubblesAdded)
            timeBubble.fillColor = SKColor.gray
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objectTouched = self.atPoint(location)
            let objectsPlayerOn = self.nodes(at: ThePlayer.position)
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
            if objectTouched == UP_BTN {
                if TheShip.followShip {
                    TheShip.toMultiplayer()
                } else {
                    ThePlayer.moveTo = "Up"
                }
            } else if objectTouched == RIGHT_BTN {
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
            } else if objectTouched == LEFT_BTN {
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
            } else if objectTouched == DOWN_BTN {
                if TheShip.followShip {
                    TheShip.backToEarth()
                } else {
                    ThePlayer.moveTo = "Down"
                }
            }
            
            if objectTouched == ACTION_BTN {
                if (objectPlayerOn is Onion) && !((objectPlayerOn as? Onion)?.awakened)! {
                    let onion = objectPlayerOn as! Onion
                    onion.wake()
                } else if (objectPlayerOn is Onion) && ((objectPlayerOn as? Onion)?.awakened)! {
                    let onion = objectPlayerOn as! Onion
                    onion.toggleMenuOverlay()
                } else if objectPlayerOn is Seed {
                    let seed = objectPlayerOn as! Seed
                    seed.unrootPikmin(ThePlayer)
                } else if objectPlayerOn is Ship {
                    let ship = objectPlayerOn as! Ship
                    ship.toggleMenuOverlay()
                } else {
                    ThePlayer.grabPikmin()
                }
            } else if objectTouched == IDLE_BTN {
                ThePlayer.makePikminIdle()
            } else if objectTouched == CALL_BTN {
                ThePlayer.recallPikmin()
            } else if objectTouched == ZOOM_BTN {
                if self.camera!.xScale == 1 {
                    self.camera!.run(SKAction.scale(to: 0.75, duration: 0.25))
                } else if self.camera!.xScale == 0.75 {
                    self.camera!.run(SKAction.scale(to: 0.5, duration: 0.25))
                } else if self.camera!.xScale == 0.5 {
                    self.camera!.run(SKAction.scale(to: 5, duration: 0.25))
                } else if self.camera!.xScale == 5 {
                    self.camera!.run(SKAction.scale(to: 1, duration: 0.25))
                }
            } else if (objectTouched.parent! is MenuOverlay) {
                let objectParent = objectTouched.parent as! MenuOverlay
                let pikminColor:String = objectParent.menuColor
                let pikminColor2:String = objectParent.menuColor2
                pikminOut = pikminCount3()
                print(pikminColor + " Pikmin following Player: " + String(self.pikminCount(pikminColor)))
                
                if pikminColor2 != "" {
                    print(pikminColor2 + " Pikmin following Player: " + String(self.pikminCount(pikminColor2)))
                }
                
                if objectTouched == objectParent.morePikmin {
                    print("Depositing Pikmin. Color: " + pikminColor)
                    
                    if self.pikminCount(pikminColor) > 0 {
                        var index = -1
                        var found = false
                        while index < ThePlayer.pikminFollowing.count - 1 && !found {
                            index += 1
                            
                            if !ThePlayer.pikminFollowing[index].busy && !ThePlayer.pikminFollowing[index].attacking && !ThePlayer.pikminFollowing[index].movingToHome && ThePlayer.pikminFollowing[index].pikminColor == pikminColor {
                                
                                ThePlayer.pikminFollowing[index].movingToHome = true
                                ThePlayer.pikminFollowing[index].idle = true
                                ThePlayer.pikminFollowing[index].returning = false
                                ThePlayer.pikminFollowing[index].run(SKAction.sequence([SKAction.wait(forDuration: Double(index)/100),ThePlayer.pikminFollowing[index].pikminLeft]))
                                ThePlayer.pikminFollowing.remove(at: index)
                                found = true
                            }
                        }
                    }
                } else if objectTouched == objectParent.lessPikmin {
                    print("Withdrawing Pikmin. Color: " + pikminColor)
                    
                    if self.pikminCount2(pikminColor) > 0 {
                        var index = -1
                        var found = false
                        while index < existingPikmin.count - 1 && !found {
                            index += 1
                            
                            if existingPikmin[index].inHome && existingPikmin[index].pikminColor == pikminColor {
                                existingPikmin[index].inHome = false
                                existingPikmin[index].isHidden = false
                                existingPikmin[index].becomeAwareToFollow()
                                found = true
                            }
                        }
                    }
                }
                
                if objectTouched == objectParent.morePikmin2 {
                    print("Depositing Pikmin. Color: " + pikminColor2)
                    
                    if self.pikminCount(pikminColor) > 0 {
                        var index = -1
                        var found = false
                        while index < ThePlayer.pikminFollowing.count - 1 && !found {
                            index += 1
                            
                            if !ThePlayer.pikminFollowing[index].busy && !ThePlayer.pikminFollowing[index].attacking && !ThePlayer.pikminFollowing[index].movingToHome && ThePlayer.pikminFollowing[index].pikminColor == pikminColor2 {
                                
                                ThePlayer.pikminFollowing[index].movingToHome = true
                                ThePlayer.pikminFollowing[index].idle = true
                                ThePlayer.pikminFollowing[index].returning = false
                                ThePlayer.pikminFollowing[index].run(SKAction.sequence([SKAction.wait(forDuration: Double(index)/100),ThePlayer.pikminFollowing[index].pikminLeft]))
                                ThePlayer.pikminFollowing.remove(at: index)
                                found = true
                            }
                        }
                    }
                } else if objectTouched == objectParent.lessPikmin2 {
                    print("Withdrawing Pikmin. Color: " + pikminColor2)
                    
                    if self.pikminCount2(pikminColor2) > 0 {
                        var index = -1
                        var found = false
                        while index < existingPikmin.count - 1 && !found {
                            index += 1
                            
                            if existingPikmin[index].inHome && existingPikmin[index].pikminColor == pikminColor2 {
                                existingPikmin[index].inHome = false
                                existingPikmin[index].isHidden = false
                                existingPikmin[index].becomeAwareToFollow()
                                found = true
                            }
                        }
                    }
                }
                
                if objectTouched == objectParent.takeFlightButton {
                    TheShip.getIn(ThePlayer)
                    TheShip.toggleMenuOverlay()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objectTouched = self.atPoint(location)
            if objectTouched == UP_BTN || objectTouched == DOWN_BTN || objectTouched == LEFT_BTN || objectTouched == RIGHT_BTN {
                ThePlayer.moveTo = ""
            }
            
            if objectTouched == ACTION_BTN {
                pikminOut = pikminCount3()
                if ThePlayer.pikminToThrow != nil {
                    ThePlayer.throwPikmin()
                }
            } else if objectTouched == CALL_BTN {
                pikminOut = pikminCount3()
                ThePlayer.recallCircle.removeAllActions()
                ThePlayer.recallCircle.run(SKAction.scale(to: 1, duration: 0.15),completion:{
                    self.ThePlayer.callingPikmin = false
                })
            }
        }
    }
    
    func pikminCount(_ color:String) -> Int {
        var pikminCounted = 0
        var index = -1
        if ThePlayer.pikminFollowing.count > 0 {
            while index < ThePlayer.pikminFollowing.count - 1 {
                index += 1
                if ThePlayer.pikminFollowing[index].pikminColor == color {
                    pikminCounted += 1
                }
            }
        }
        
        return pikminCounted
    }
    
    func pikminCount2(_ color:String) -> Int {
        var pikminCounted = 0
        var index = -1
        if existingPikmin.count > 0 {
            while index < existingPikmin.count - 1 {
                index += 1
                if existingPikmin[index].pikminColor == color {
                    pikminCounted += 1
                }
            }
        }
        
        return pikminCounted
    }
    
    func pikminCount3() -> Int {
        var pikminCounted = 0
        var index = -1
        if existingPikmin.count > 0 {
            while index < existingPikmin.count - 1 {
                index += 1
                if !existingPikmin[index].isHidden && !existingPikmin[index].dead {
                    pikminCounted += 1
                }
            }
        }
        print(pikminCounted)
        return pikminCounted
    }
    
    override func update(_ currentTime: TimeInterval) {
        pikminCount.text = String(ThePlayer.pikminFollowing.count) + "/" + String(pikminOut) + "/" + String(existingPikmin.count)
        
        RedOnion.updateMenuPositioning()
        BlueOnion.updateMenuPositioning()
        YellowOnion.updateMenuPositioning()
        TheShip.updateMenuPositioning()
        
        if currentTime - lastTime >= timeFrame {
            lastTime = currentTime
            sundialUpdate()
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
                    let spaceZoom = SKAction.sequence([SKAction.move(by: CGVector(dx: 0, dy: -750), duration: 9),SKAction.run({
                        self.Space.position.x = self.TheShip.position.x
                        self.Space.position.y = self.TheShip.position.y + 1100
                    })])
                    Space.position.y = TheShip.position.y + 1550
                    Space.run(SKAction.repeatForever(spaceZoom))
                } else {
                    Space.removeAllActions()
                    let spaceZoom = SKAction.sequence([SKAction.move(by: CGVector(dx: 0, dy: 500), duration: 6),SKAction.run({
                        self.Space.position.x = self.TheShip.position.x
                        self.Space.position.y = self.TheShip.position.y - 1200
                    })])
                    Space.position.y = TheShip.position.y - 1550
                    Space.run(SKAction.repeatForever(spaceZoom))
                }
            }
        }
    }
    
    func sundialUpdate() {
        sundial.removeAllActions()
        
        if gameTime == 23 {
            gameTime = 0
        } else {
            gameTime += 1
        }
        
        print("Current Time: " + String(gameTime))
        
        if gameTime == 7 {
            let marker1 = self.camera!.childNode(withName: "TimeBubble1")!
            let marker2 = self.camera!.childNode(withName: "TimeBubble2")!
            sundial.position = marker1.position
            sundial.run(SKAction.move(to: marker2.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 8 {
            let marker3 = self.camera!.childNode(withName: "TimeBubble3")!
            sundial.run(SKAction.move(to: marker3.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 9 {
            let marker4 = self.camera!.childNode(withName: "TimeBubble4")!
            sundial.run(SKAction.move(to: marker4.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 10 {
            let marker5 = self.camera!.childNode(withName: "TimeBubble5")!
            sundial.run(SKAction.move(to: marker5.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 11 {
            let marker6 = self.camera!.childNode(withName: "TimeBubble6")!
            sundial.run(SKAction.move(to: marker6.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 12 {
            let marker6 = self.camera!.childNode(withName: "TimeBubble6")!
            let marker7 = self.camera!.childNode(withName: "TimeBubble7")!
            sundial.position = marker6.position
            sundial.run(SKAction.move(to: marker7.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 13 {
            let marker7 = self.camera!.childNode(withName: "TimeBubble7")!
            let marker8 = self.camera!.childNode(withName: "TimeBubble8")!
            sundial.position = marker7.position
            sundial.run(SKAction.move(to: marker8.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 14 {
            let marker9 = self.camera!.childNode(withName: "TimeBubble9")!
            sundial.run(SKAction.move(to: marker9.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 15 {
            let marker10 = self.camera!.childNode(withName: "TimeBubble10")!
            sundial.run(SKAction.move(to: marker10.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 16 {
            let marker11 = self.camera!.childNode(withName: "TimeBubble11")!
            sundial.run(SKAction.move(to: marker11.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 17 {
            let marker12 = self.camera!.childNode(withName: "TimeBubble12")!
            sundial.run(SKAction.move(to: marker12.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime == 18 {
            let marker13 = self.camera!.childNode(withName: "TimeBubble13")!
            sundial.run(SKAction.move(to: marker13.position, duration: timeFrame - 0.5))
            day = true
        } else if gameTime >= 19 || gameTime < 7 {
            let marker1 = self.camera!.childNode(withName: "TimeBubble1")!
            var timeFrameMod:Double = 12
            
            if gameTime == 20 {
                timeFrameMod = 11
            } else if gameTime == 21 {
                timeFrameMod = 10
            } else if gameTime == 22 {
                timeFrameMod = 9
            } else if gameTime == 23 {
                timeFrameMod = 8
            } else if gameTime == 0 || gameTime == 24 {
                timeFrameMod = 7
            } else if gameTime == 1 {
                timeFrameMod = 6
            } else if gameTime == 2 {
                timeFrameMod = 5
            } else if gameTime == 3 {
                timeFrameMod = 4
            } else if gameTime == 4 {
                timeFrameMod = 3
            } else if gameTime == 5 {
                timeFrameMod = 2
            } else if gameTime == 6 {
                timeFrameMod = 1
            }
            
            sundial.run(SKAction.move(to: marker1.position, duration: (timeFrame * timeFrameMod) - (0.5 * timeFrameMod)))
            day = false
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
            sundial.fillColor = SKColor.yellow
            if nightOverlay.alpha >= 0.55 {
                nightOverlay.run(SKAction.fadeAlpha(to: nightOverlay.alpha - 0.05, duration: timeFrame - timeFrame/60))
            }
        } else {
            sundial.fillColor = SKColor.white
            if nightOverlay.alpha <= 0.0 {
                nightOverlay.run(SKAction.fadeAlpha(to: nightOverlay.alpha + 0.05, duration: timeFrame - timeFrame/60))
            }
        }
    }
}
