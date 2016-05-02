//
//  MultiGameScene.swift
//  Pikmin Maker
//
//  Created by Bryan Mazariegos on 5/1/16.
//  Copyright © 2016 Bryan Mazariegos. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class MultiGameScene:SKScene, MCBrowserViewControllerDelegate {
    var ThePlayer = Player(imageNamed:"Olimar_Down_Stand")
    var TheEnemy = Player(imageNamed:"Olimar_Down_Stand")
    var RedOnion = Onion(imageNamed:"Onion_Inactive")
    var BlueOnion = Onion(imageNamed:"Onion_Inactive")
    var YellowOnion = Onion(imageNamed:"Onion_Inactive")
    
    var lastTime:Double = 0
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestNaval")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    
    var inPlay = false
    var connected = false
    
    var currentPlayer:String = "1"
    
    var appDelegate:AppDelegate!
    
    var incMoveCount:Int = 0
    var outMoveCount:Int = 0
    
    var lastEnemyButton = ""
    
    override func didMoveToView(view: SKView) {
        MAP.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        MAP.zPosition = BackmostLayer
        
        ThePlayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ThePlayer.zPosition = BackLayer
        ThePlayer.character = "Olimar"
        ThePlayer.moveTo = ""
        ThePlayer.setUp()
        
        TheEnemy.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        TheEnemy.zPosition = BackLayer
        TheEnemy.moveTo = ""
        TheEnemy.character = "Olimar"
        TheEnemy.setUp()
        
        RedOnion.onionColor = "Red"
        RedOnion.zPosition = MidLayer
        
        BlueOnion.onionColor = "Blue"
        BlueOnion.zPosition = MidLayer
        
        YellowOnion.onionColor = "Yellow"
        YellowOnion.zPosition = MidLayer
        
        backgroundMusic.autoplayLooped = true
        
        self.camera?.zPosition = UILayer
        
        self.addChild(ThePlayer)
        self.addChild(TheEnemy)
        self.addChild(MAP)
        self.addChild(backgroundMusic)
        
        incMoveCount = 0
        outMoveCount = 0
        
        appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(NSUserName())
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MultiGameScene.peerChangedStateWithNotification), name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MultiGameScene.handleReceivedDataWithNotification), name: "MPC_DidReceiveDataNotification", object: nil)
        
        connectWithPlayer()
    }
    
    func connectWithPlayer() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.view?.window?.contentViewController?.presentViewControllerAsModalWindow(appDelegate.mpcHandler.browser)
            self.connected = true
        }
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as! Int
        
        if state == MCSessionState.Connected.rawValue {
            print("Connected")
            print(connected)
            sendPlayerNum()
        }
    }
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as! NSData
        let message = try! NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.objectForKey("player") != nil {
            let player:String? = message.objectForKey("player") as? String
            let playerID:String? = message.objectForKey("playerID") as? String
            //print("Received Player#, Going to read it")
            if player != nil {
                if player == currentPlayer {
                    let newPlayerNum = Int(arc4random_uniform(2)+1)
                    print("Testing, player now " + String(newPlayerNum))
                    currentPlayer = String(newPlayerNum)
                    sendPlayerNum()
                } else {
                    changeinPlayStatus()
                }
            }
        } else if message.objectForKey("playerName") != nil {
            if currentPlayer == "2" {
                let playerName:String? = message.objectForKey("playerName") as? String
                let playerDirection:String? = message.objectForKey("direction") as? String
                let playerChars:String? = message.objectForKey("chars") as? String
                let incCount:Int? = Int((message.objectForKey("outCount") as? String)!)
                //print("Received PlayerInfo#, Going to read and assign it")
                if playerName != nil {
                    if incCount >= incMoveCount {
                        incMoveCount = incCount!
                        TheEnemy.moveTo = playerDirection!
                        TheEnemy.playerChars = playerChars!
                    } else {
                        print("PlayerInfo#:Out of sync message was received and left unassigned")
                    }
                }
            } else if currentPlayer == "1" {
                let playerName:String? = message.objectForKey("playerName") as? String
                let playerChars:String? = message.objectForKey("chars") as? String
                let playerDirection:String? = message.objectForKey("direction") as? String
                //print("Received PlayerInfo#, Going to read and assign it")
                if playerName != nil {
                    TheEnemy.moveTo = playerDirection!
                    TheEnemy.playerChars = playerChars!
                }
            }
        } else if message.objectForKey("nutrientColor") != nil {
            if currentPlayer == "2" {
                let nutrientColor:String? = message.objectForKey("nutrientColor") as? String
                let nutrientWorth:Int? = message.objectForKey("nutrientWorth") as? Int
                let nutrientXPos:Int? = message.objectForKey("nutrientX") as? Int
                let nutrientYPos:Int? = message.objectForKey("nutrientY") as? Int
                //print("Received PlayerInfo#, Going to read and assign it")
                if nutrientColor != nil {
                    let nutrient = Nutrient(imageNamed:"Nutrient_" + nutrientColor!)
                    nutrient.nutrientColor = nutrientColor!
                    nutrient.worth = Int(nutrientWorth!)
                    nutrient.position = CGPoint(x: Int(nutrientXPos!), y: Int(nutrientYPos!))
                    nutrient.zPosition = MidLayer - 1
                    self.addChild(nutrient)
                }
            }
        } else if message.objectForKey("onionColor") != nil {
            if currentPlayer == "2" {
                let onionColor:String? = message.objectForKey("onionColor") as? String
                let onionXPos:Int? = message.objectForKey("onionX") as? Int
                let onionYPos:Int? = message.objectForKey("onionY") as? Int
                //print("Received PlayerInfo#, Going to read and assign it")
                if onionColor != nil {
                    let onion = Onion(imageNamed:"Onion_Inactive")
                    onion.onionColor = onionColor!
                    onion.position = CGPoint(x: Int(onionXPos!), y: Int(onionYPos!))
                    onion.zPosition = MidLayer
                    if onionColor == "Red" {
                        self.RedOnion = onion
                        self.addChild(self.RedOnion)
                    } else if onionColor == "Blue" {
                        self.BlueOnion = onion
                        self.addChild(self.BlueOnion)
                    } else if onionColor == "Yellow" {
                        self.YellowOnion = onion
                        self.addChild(self.YellowOnion)
                    }
                }
            }
        } else if message.objectForKey("flowerColor") != nil {
            if currentPlayer == "2" {
                let flowerColor:String? = message.objectForKey("flowerColor") as? String
                let flowerXPos:Int? = message.objectForKey("flowerX") as? Int
                let flowerYPos:Int? = message.objectForKey("flowerY") as? Int
                //print("Received PlayerInfo#, Going to read and assign it")
                if flowerColor != nil {
                    let flower = Flower(imageNamed:"Flower_" + flowerColor! + "_Open")
                    flower.flowerColor = flowerColor!
                    flower.position = CGPoint(x: Int(flowerXPos!), y: Int(flowerYPos!))
                    flower.zPosition = MidLayer
                    flower.name = "Flower_" + flowerColor!
                    self.addChild(flower)
                }
            }
        } else if message.objectForKey("correctXPos") != nil {
            let correctXPos:CGFloat? = message.objectForKey("correctXPos") as? CGFloat
            let correctYPos:CGFloat? = message.objectForKey("correctYPos") as? CGFloat
            //print("Received PlayerInfo#, Going to read and assign it")
            if correctXPos != nil {
                TheEnemy.position = CGPoint(x: correctXPos!, y: correctYPos!)
            }
        } else if message.objectForKey("forOnion") != nil {
            let randX:CGFloat? = message.objectForKey("randXSeed") as? CGFloat
            let onionColor:String? = message.objectForKey("forOnion") as? String
            //print("Received PlayerInfo#, Going to read and assign it")
            if randX != nil {
                if onionColor == "Red" {
                    RedOnion.receivedMsg = true
                    RedOnion.randXMultiplayer = randX!
                    RedOnion.dispelSeed()
                } else if onionColor == "Blue" {
                    BlueOnion.receivedMsg = true
                    BlueOnion.randXMultiplayer = randX!
                    BlueOnion.dispelSeed()
                } else if onionColor == "Yellow" {
                    YellowOnion.receivedMsg = true
                    YellowOnion.randXMultiplayer = randX!
                    YellowOnion.dispelSeed()
                }
            }
        }  else if message.objectForKey("forFlower") != nil {
            let randX:CGFloat? = message.objectForKey("randXSeed") as? CGFloat
            let flowerColor:String? = message.objectForKey("forFlower") as? String
            print("Received FlowerSeed Request")
            if randX != nil {
                let whiteFlower = self.childNodeWithName("Flower_White") as! Flower
                let purpleFlower = self.childNodeWithName("Flower_Purple") as! Flower
                if flowerColor == "White" {
                    print("Attempt to expel white")
                    whiteFlower.receivedMsg = true
                    whiteFlower.randXMultiplayer = randX!
                    whiteFlower.dispelSeed()
                } else if flowerColor == "Purple" {
                    print("Attempt to expel purple")
                    purpleFlower.receivedMsg = true
                    purpleFlower.randXMultiplayer = randX!
                    purpleFlower.dispelSeed()
                }
            }
        }
    }
    
    func sendNutrient(nutrient:Nutrient) {
        let messageDict = ["nutrientColor":nutrient.nutrientColor,"nutrientWorth":nutrient.worth, "nutrientX":Int(nutrient.position.x),"nutrientY":Int(nutrient.position.y)]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendOnion(onion:Onion) {
        let messageDict = ["onionColor":onion.onionColor,"onionX":onion.position.x,"onionY":onion.position.y]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlower(flower:Flower) {
        let messageDict = ["flowerColor":flower.flowerColor,"flowerX":flower.position.x,"flowerY":flower.position.y]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendPlayerNum() {
        let messageDict = ["player":self.currentPlayer]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendCorrectedPos(player:Player) {
        let messageDict = ["correctXPos":CGFloat(player.position.x),"correctYPos":CGFloat(player.position.y)]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendOnionNum(onion:Onion,randX:CGFloat) {
        let messageDict = ["randXSeed":randX,"forOnion":onion.onionColor]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlowerNum(flower:Flower,randX:CGFloat) {
        let messageDict = ["randXSeed":randX,"forFlower":flower.flowerColor]
        
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendPlayerInfo() {
        var messageDict = [String:String]()
        if currentPlayer == "1" {
            outMoveCount += 1
            messageDict = ["playerName":ThePlayer.character,"direction":ThePlayer.moveTo,"chars":ThePlayer.playerChars,"outCount":String(outMoveCount)]
        } else if currentPlayer == "2" {
            messageDict = ["playerName":ThePlayer.character,"direction":ThePlayer.moveTo,"chars":ThePlayer.playerChars]
        }
        let messageData = try! NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.init(rawValue: 0))
        
        do {
            try appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            //print("Sent PlayerInfo")
        } catch {
            print("Error: Couldn't send PlayerInfo")
        }
    }
    
    func changeinPlayStatus() {
        if self.currentPlayer == "1" {
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
                self.sendNutrient(nutrient)
            }
            
            self.addChild(RedOnion)
            self.addChild(BlueOnion)
            self.addChild(YellowOnion)
            RedOnion.randomizePosition()
            YellowOnion.randomizePosition()
            BlueOnion.randomizePosition()
            sendOnion(RedOnion)
            sendOnion(BlueOnion)
            sendOnion(YellowOnion)
            
            
            let PurpleFlower = Flower(imageNamed:"Flower_Purple_Open")
            PurpleFlower.zPosition = MidLayer
            PurpleFlower.flowerColor = "Purple"
            PurpleFlower.name = "Flower_Purple"
            self.addChild(PurpleFlower)
            
            let WhiteFlower = Flower(imageNamed:"Flower_White_Open")
            WhiteFlower.zPosition = MidLayer
            WhiteFlower.name = "Flower_White"
            self.addChild(WhiteFlower)
            
            PurpleFlower.randomizePosition()
            WhiteFlower.randomizePosition()
            sendFlower(PurpleFlower)
            sendFlower(WhiteFlower)
        }
        sendPlayerInfo()
        inPlay = true
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewController(appDelegate.mpcHandler.browser)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismissViewController(appDelegate.mpcHandler.browser)
    }
    
    override func keyDown(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let objectTouched = self.nodeAtPoint(location)
        let objectPlayerOn = self.nodeAtPoint(ThePlayer.position)
        let chars = theEvent.characters!
        if chars.containsString("w") {
            ThePlayer.moveTo = "Up"
        } else if chars.containsString("d") {
            ThePlayer.moveTo = "Right"
        } else if chars.containsString("a") {
            ThePlayer.moveTo = "Left"
        } else if chars.containsString("s") {
            ThePlayer.moveTo = "Down"
        } else if chars.containsString(" ") {
            ThePlayer.playerChars = chars
            if objectPlayerOn is Onion {
                let onion = objectPlayerOn as! Onion
                onion.wake()
            } else if objectPlayerOn is Seed {
                let seed = objectPlayerOn as! Seed
                seed.unrootPikmin(ThePlayer)
            } else if objectPlayerOn is Ship {
                let ship = objectPlayerOn as! Ship
                ship.getIn(ThePlayer)
            } else  {
                ThePlayer.grabPikmin()
            }
        } else if chars.containsString("q") {
            ThePlayer.playerChars = chars
            ThePlayer.makePikminIdle()
        } else if chars.containsString("b") {
            ThePlayer.playerChars = chars
            ThePlayer.recallPikmin()
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        let chars = theEvent.characters!
        if chars.containsString("w") || chars.containsString("a") || chars.containsString("s") || chars.containsString("d") {
            ThePlayer.moveTo = ""
        } else if chars.containsString(" ") {
            if ThePlayer.pikminToThrow != nil {
                ThePlayer.throwPikmin()
                ThePlayer.playerChars = ""
            }
        } else {
            ThePlayer.playerChars = ""
        }
    }
    
    func enemyExtras() {
        let objectEnemyOn = self.nodeAtPoint(TheEnemy.position)
        let chars = TheEnemy.playerChars
        if chars.containsString(" ") {
            if objectEnemyOn is Onion {
                let onion = objectEnemyOn as! Onion
                onion.wake()
            } else if objectEnemyOn is Seed {
                let seed = objectEnemyOn as! Seed
                seed.unrootPikmin(TheEnemy)
            } else if objectEnemyOn is Ship {
                let ship = objectEnemyOn as! Ship
                ship.getIn(TheEnemy)
            } else {
                TheEnemy.grabPikmin()
                lastEnemyButton = " "
            }
        } else if chars.containsString("q") {
            lastEnemyButton = "q"
            TheEnemy.makePikminIdle()
        } else if chars.containsString("b") {
            lastEnemyButton = "b"
            TheEnemy.recallPikmin()
        } else if chars == "" {
            if lastEnemyButton == " " {
                TheEnemy.throwPikmin()
            }
            lastEnemyButton = ""
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        self.camera!.position = ThePlayer.position
        ThePlayer.move()
        TheEnemy.move()
        enemyExtras()
    }
}