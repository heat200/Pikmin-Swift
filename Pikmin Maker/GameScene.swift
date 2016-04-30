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
    
    override func keyDown(theEvent: NSEvent) {
        let objectTouched = self.nodeAtPoint(ThePlayer.position)
        let chars = theEvent.characters!
        if chars.containsString("w") {
            ThePlayer.move("Up")
        } else if chars.containsString("d") {
            ThePlayer.move("Right")
        } else if chars.containsString("a") {
            ThePlayer.move("Left")
        } else if chars.containsString("s") {
            ThePlayer.move("Down")
        } else if chars.containsString(" ") {
            if objectTouched is Onion {
                let onion = objectTouched as! Onion
                onion.wake()
            } else if objectTouched is Seed {
                let seed = objectTouched as! Seed
                seed.unrootPikmin(ThePlayer)
            } else if objectTouched is Flower {
                let flower = objectTouched as! Flower
                flower.toggleOpen()
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
            ThePlayer.move("")
        } else if chars.containsString(" ") {
            if ThePlayer.pikminToThrow != nil {
                ThePlayer.throwPikmin()
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        self.camera!.position = ThePlayer.position
    }
}