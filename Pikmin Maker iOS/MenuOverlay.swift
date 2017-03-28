//
//  MenuOverlay.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 5/4/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit

class MenuOverlay:SKShapeNode {
    var title = SKLabelNode()
    var pikminOut = SKLabelNode()
    var pikminOut2 = SKLabelNode()
    var menuColor = ""
    var menuColor2 = ""
    var morePikmin = SKShapeNode(circleOfRadius: 20)
    var lessPikmin = SKShapeNode(circleOfRadius: 20)
    var morePikmin2 = SKShapeNode(circleOfRadius: 20)
    var lessPikmin2 = SKShapeNode(circleOfRadius: 20)
    var takeFlightButton = SKShapeNode(circleOfRadius: 20)
    
    
    func setUp(_ onion:Onion) {
        isHidden = true
        zPosition = UILayer
        alpha = 0.65
        updatePos(onion)
        if onion.onionColor == "Red" {
            self.fillColor = SKColor.red
        } else if onion.onionColor == "Blue" {
            self.fillColor = SKColor.blue
        } else if onion.onionColor == "Yellow" {
            self.fillColor = SKColor.yellow
        }
        
        menuColor = onion.onionColor
        
        title.text = onion.onionColor + " Onion"
        title.position.y = 70
        title.fontColor = SKColor.black
        
        if menuColor == "Yellow" {
            pikminOut.fontColor = SKColor.black
        }
        
        morePikmin.fillColor = SKColor.gray
        morePikmin.position.y = 25
        morePikmin.position.x = -100
        
        lessPikmin.fillColor = SKColor.gray
        lessPikmin.position.y = -25
        lessPikmin.position.x = -100
        
        self.addChild(title)
        self.addChild(pikminOut)
        self.addChild(morePikmin)
        self.addChild(lessPikmin)
        onion.parent!.addChild(self)
    }
    
    func setUpShip(_ ship:Ship) {
        isHidden = true
        zPosition = UILayer
        alpha = 0.65
        updatePosShip(ship)
        self.fillColor = .green
        
        menuColor = "White"
        menuColor2 = "Purple"
        
        title.text = "SS Dolphin"
        title.position.y = 70
        title.fontColor = SKColor.black
        
        pikminOut.fontColor = SKColor.black
        pikminOut.position = CGPoint(x: -40, y: 0)
        pikminOut2.fontColor = SKColor.black
        pikminOut2.position = CGPoint(x: 40, y: 0)
        
        morePikmin.fillColor = SKColor.gray
        morePikmin.position.y = 25
        morePikmin.position.x = -100
        
        lessPikmin.fillColor = SKColor.gray
        lessPikmin.position.y = -25
        lessPikmin.position.x = -100
        
        morePikmin2.fillColor = SKColor.gray
        morePikmin2.position.y = 25
        morePikmin2.position.x = 100
        
        lessPikmin2.fillColor = SKColor.gray
        lessPikmin2.position.y = -25
        lessPikmin2.position.x = 100
        
        takeFlightButton.fillColor = SKColor.gray
        takeFlightButton.position.y = -50
        takeFlightButton.position.x = 0
        
        self.addChild(title)
        self.addChild(pikminOut)
        self.addChild(pikminOut2)
        self.addChild(morePikmin)
        self.addChild(lessPikmin)
        self.addChild(morePikmin2)
        self.addChild(lessPikmin2)
        self.addChild(takeFlightButton)
        ship.parent!.addChild(self)
    }
    
    func updatePos(_ onion:Onion) {
        position = (onion.parent as! GameScene).ThePlayer.position
    }
    
    func updatePosShip(_ ship:Ship) {
        position = (ship.parent as! GameScene).ThePlayer.position
    }
}
