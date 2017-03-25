//
//  AppDelegate.swift
//  Haunter
//
//  Created by Bryan Mazariegos on 4/28/16.
//  Copyright (c) 2016 Bryan Mazariegos. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    var mpcHandler:MPCHandler = MPCHandler()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* Pick a size for the scene */
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        if let scene = GameScene(fileNamed:"GameScene") {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            self.skView!.presentScene(scene)
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            self.skView!.ignoresSiblingOrder = true
            
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
