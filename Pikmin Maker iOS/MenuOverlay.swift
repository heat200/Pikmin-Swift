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
    var menuColor = ""
    var morePikmin = SKShapeNode(circleOfRadius: 20)
    var lessPikmin = SKShapeNode(circleOfRadius: 20)
    
    
    func setUp(_ onion:Onion) {
        isHidden = true
        zPosition = UILayer
        position.x = onion.position.x
        position.y = onion.position.y + 225
        alpha = 0.65
        if onion.onionColor == "Red" {
            self.fillColor = SKColor.red()
        } else if onion.onionColor == "Blue" {
            self.fillColor = SKColor.blue()
        } else if onion.onionColor == "Yellow" {
            self.fillColor = SKColor.yellow()
        }
        menuColor = onion.onionColor
        
        title.text = onion.onionColor + " Onion"
        title.position.y = 70
        title.fontColor = SKColor.black()
        
        if menuColor == "Yellow" {
            pikminOut.fontColor = SKColor.black()
        }
        
        morePikmin.fillColor = SKColor.gray()
        morePikmin.position.y = 25
        morePikmin.position.x = -100
        
        lessPikmin.fillColor = SKColor.gray()
        lessPikmin.position.y = -25
        lessPikmin.position.x = -100
        
        self.addChild(title)
        self.addChild(pikminOut)
        self.addChild(morePikmin)
        self.addChild(lessPikmin)
        onion.parent!.addChild(self)
    }
}
