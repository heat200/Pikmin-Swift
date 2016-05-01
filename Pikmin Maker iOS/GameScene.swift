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

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone
    case Pad
}

class GameScene:SKScene {
    var ThePlayer = Player(imageNamed:"Olimar_Down_Stand")
    let RedOnion = Onion(imageNamed:"Onion_Inactive")
    let BlueOnion = Onion(imageNamed:"Onion_Inactive")
    let YellowOnion = Onion(imageNamed:"Onion_Inactive")
    
    var UP_BTN = SKShapeNode(circleOfRadius: 30)
    var DOWN_BTN = SKShapeNode(circleOfRadius: 30)
    var LEFT_BTN = SKShapeNode(circleOfRadius: 30)
    var RIGHT_BTN = SKShapeNode(circleOfRadius: 30)
    var ACTION_BTN = SKShapeNode(circleOfRadius: 30)
    var CALL_BTN = SKShapeNode(circleOfRadius: 30)
    var IDLE_BTN = SKShapeNode(circleOfRadius: 30)
    var ZOOM_BTN = SKShapeNode(circleOfRadius: 30)
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    
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
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let semiWidth = self.frame.width/2
            let semiHeight = self.frame.height/2
            UP_BTN.fillColor = SKColor.grayColor()
            UP_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 + 50)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.grayColor()
            DOWN_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 - 50)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.grayColor()
            LEFT_BTN.position = CGPoint(x: -semiWidth + 100 - 50, y: -semiHeight + 100)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.grayColor()
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 100 + 50, y: -semiHeight + 100)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.greenColor()
            ACTION_BTN.position = CGPoint(x: semiWidth - 100, y: -semiHeight + 100)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.grayColor()
            IDLE_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 + 50)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.redColor()
            CALL_BTN.position = CGPoint(x: semiWidth - 100 - 50, y: -semiHeight + 100 - 50)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyanColor()
            ZOOM_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 - 50)
            ZOOM_BTN.alpha = 0.65
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            UP_BTN = SKShapeNode(circleOfRadius: 45)
            DOWN_BTN = SKShapeNode(circleOfRadius: 45)
            LEFT_BTN = SKShapeNode(circleOfRadius: 45)
            RIGHT_BTN = SKShapeNode(circleOfRadius: 45)
            ACTION_BTN = SKShapeNode(circleOfRadius: 45)
            CALL_BTN = SKShapeNode(circleOfRadius: 45)
            IDLE_BTN = SKShapeNode(circleOfRadius: 45)
            ZOOM_BTN = SKShapeNode(circleOfRadius: 35)
            
            let semiWidth = self.frame.width/3
            let semiHeight = self.frame.height/4
            
            UP_BTN.fillColor = SKColor.grayColor()
            UP_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight + 120 + 65)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.grayColor()
            DOWN_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight + 120 - 65)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.grayColor()
            LEFT_BTN.position = CGPoint(x: -semiWidth - 65, y: -semiHeight + 120)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.grayColor()
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 65, y: -semiHeight + 120)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.greenColor()
            ACTION_BTN.position = CGPoint(x: semiWidth, y: -semiHeight + 120)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.grayColor()
            IDLE_BTN.position = CGPoint(x: semiWidth + 65, y: -semiHeight + 120 + 65)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.redColor()
            CALL_BTN.position = CGPoint(x: semiWidth - 65, y: -semiHeight + 120 - 65)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyanColor()
            ZOOM_BTN.position = CGPoint(x: semiWidth + 65, y: -semiHeight + 120 - 65)
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
        self.addChild(backgroundMusic)
        
        
        
        RedOnion.randomizePosition()
        YellowOnion.randomizePosition()
        BlueOnion.randomizePosition()
        WhiteFlower.randomizePosition()
        PurpleFlower.randomizePosition()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let objectTouched = self.nodeAtPoint(location)
            let objectPlayerOn = self.nodeAtPoint(ThePlayer.position)
            if objectTouched == UP_BTN {
                ThePlayer.moveTo = "Up"
            } else if objectTouched == RIGHT_BTN {
                ThePlayer.moveTo = "Right"
            } else if objectTouched == LEFT_BTN {
                ThePlayer.moveTo = "Left"
            } else if objectTouched == DOWN_BTN {
                ThePlayer.moveTo = "Down"
            } else if objectTouched == ACTION_BTN {
                if (objectPlayerOn is Onion) && !((objectPlayerOn as? Onion)?.awakened)! {
                    let onion = objectPlayerOn as! Onion
                    onion.wake()
                } else if objectPlayerOn is Seed {
                    let seed = objectPlayerOn as! Seed
                    seed.unrootPikmin(ThePlayer)
                } else if objectPlayerOn is Flower {
                    let flower = objectPlayerOn as! Flower
                    flower.toggleOpen()
                } else {
                    ThePlayer.grabPikmin()
                }
            } else if objectTouched == IDLE_BTN {
                ThePlayer.makePikminIdle()
            } else if objectTouched == CALL_BTN {
                ThePlayer.recallPikmin()
            } else if objectTouched == ZOOM_BTN {
                if self.camera!.xScale == 1 {
                    self.camera!.setScale(0.75)
                } else if self.camera!.xScale == 0.75 {
                    self.camera!.setScale(0.5)
                } else if self.camera!.xScale == 0.5 {
                    self.camera!.setScale(1)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let objectTouched = self.nodeAtPoint(location)
            if objectTouched == UP_BTN || objectTouched == DOWN_BTN || objectTouched == LEFT_BTN || objectTouched == RIGHT_BTN {
                ThePlayer.moveTo = ""
            } else if objectTouched == ACTION_BTN {
                if ThePlayer.pikminToThrow != nil {
                    ThePlayer.throwPikmin()
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        self.camera!.position = ThePlayer.position
        ThePlayer.move()
    }
}