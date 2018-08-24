//
//  GameScene.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 4/19/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class GameScene:MainGameLogic {
    
    override func keyDown(with theEvent: NSEvent) {
        let location = theEvent.location(in: self)
        let objectTouched = self.atPoint(location)
        let objectsPlayerOn = self.nodes(at: ThePlayer.position)
        let chars = theEvent.characters!
        if chars.contains("w") {
            receiveDownPressData(inputReceived: "Up", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        } else if chars.contains("d") {
            receiveDownPressData(inputReceived: "Right", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        } else if chars.contains("a") {
            receiveDownPressData(inputReceived: "Left", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        } else if chars.contains("s") {
            receiveDownPressData(inputReceived: "Down", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        }
        
        if chars.contains(" ") {
            receiveDownPressData(inputReceived: "Action", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        } else if chars.contains("q") {
            receiveDownPressData(inputReceived: "Idle", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        } else if chars.contains("b") {
            receiveDownPressData(inputReceived: "Recall", objectsPlayerOn: objectsPlayerOn, pikColor: "")
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let objectsPlayerOn = self.nodes(at: ThePlayer.position)
        
        if self.atPoint(location).parent is MenuOverlay {
            let menu = self.atPoint(location).parent as! MenuOverlay
            let menuButton = self.atPoint(location)
            if menuButton == menu.lessPikmin {
                receiveDownPressData(inputReceived: "Withdraw", objectsPlayerOn: objectsPlayerOn, pikColor: "\(menu.menuColor)")
            } else if menuButton == menu.morePikmin {
                receiveDownPressData(inputReceived: "Deposit", objectsPlayerOn: objectsPlayerOn, pikColor: "\(menu.menuColor)")
            } else if menuButton == menu.lessPikmin2 {
                receiveDownPressData(inputReceived: "Withdraw", objectsPlayerOn: objectsPlayerOn, pikColor: "\(menu.menuColor2)")
            } else if menuButton == menu.morePikmin2 {
                receiveDownPressData(inputReceived: "Deposit", objectsPlayerOn: objectsPlayerOn, pikColor: "\(menu.menuColor2)")
            } else if menuButton == menu.takeFlightButton {
                receiveDownPressData(inputReceived: "EndDay", objectsPlayerOn: objectsPlayerOn, pikColor: "")
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        let chars = event.characters!
        if chars.contains("w") {
            receiveDePressData(inputReceived: "Up")
        } else if chars.contains("a") {
            receiveDePressData(inputReceived: "Left")
        } else if chars.contains("s") {
            receiveDePressData(inputReceived: "Down")
        } else if chars.contains("d") {
            receiveDePressData(inputReceived: "Right")
        }
        
        if chars.contains(" ") {
            receiveDePressData(inputReceived: "Action")
        } else if chars.contains("b") {
            receiveDePressData(inputReceived: "Recall")
        } else if chars.contains("q") {
            receiveDePressData(inputReceived: "Idle")
        }
    }
    
    override func runAppDelegateSetUpCode() {
        appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(NSUserName())
    }
}
