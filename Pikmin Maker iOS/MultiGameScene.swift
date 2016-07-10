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
    
    var UP_BTN = SKShapeNode(circleOfRadius: 30)
    var DOWN_BTN = SKShapeNode(circleOfRadius: 30)
    var LEFT_BTN = SKShapeNode(circleOfRadius: 30)
    var RIGHT_BTN = SKShapeNode(circleOfRadius: 30)
    var ACTION_BTN = SKShapeNode(circleOfRadius: 30)
    var CALL_BTN = SKShapeNode(circleOfRadius: 30)
    var IDLE_BTN = SKShapeNode(circleOfRadius: 30)
    var ZOOM_BTN = SKShapeNode(circleOfRadius: 30)
    
    let backgroundMusic = SKAudioNode(fileNamed: "forestNaval")
    
    let MAP = SKSpriteNode(imageNamed:"map1")
    
    var inPlay = false
    var connected = false
    
    var currentPlayer:String = "1"
    
    var appDelegate:AppDelegate!
    
    var incMoveCount:Int = 0
    var outMoveCount:Int = 0
    
    var lastEnemyButton = ""
    
    override func didMove(to view: SKView) {
        MAP.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        MAP.zPosition = BackmostLayer
        
        ThePlayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ThePlayer.zPosition = BackLayer
        ThePlayer.setUp()
        
        TheEnemy.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        TheEnemy.zPosition = BackLayer + 1
        TheEnemy.character = "Olimar"
        TheEnemy.moveTo = ""
        TheEnemy.setUp()
        
        RedOnion.onionColor = "Red"
        RedOnion.zPosition = MidLayer
        
        BlueOnion.onionColor = "Blue"
        BlueOnion.zPosition = MidLayer
        
        YellowOnion.onionColor = "Yellow"
        YellowOnion.zPosition = MidLayer
        
        backgroundMusic.autoplayLooped = true
        
        if UIDevice.current().userInterfaceIdiom == .pad {
            let semiWidth = self.frame.width/2
            let semiHeight = self.frame.height/2
            UP_BTN.fillColor = SKColor.gray()
            UP_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 + 50)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.gray()
            DOWN_BTN.position = CGPoint(x: -semiWidth + 100, y: -semiHeight + 100 - 50)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.gray()
            LEFT_BTN.position = CGPoint(x: -semiWidth + 100 - 50, y: -semiHeight + 100)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.gray()
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 100 + 50, y: -semiHeight + 100)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.green()
            ACTION_BTN.position = CGPoint(x: semiWidth - 100, y: -semiHeight + 100)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.gray()
            IDLE_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 + 50)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.red()
            CALL_BTN.position = CGPoint(x: semiWidth - 100 - 50, y: -semiHeight + 100 - 50)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyan()
            ZOOM_BTN.position = CGPoint(x: semiWidth - 100 + 50, y: -semiHeight + 100 - 50)
            ZOOM_BTN.alpha = 0.65
        } else if UIDevice.current().userInterfaceIdiom == .phone {
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
            
            UP_BTN.fillColor = SKColor.gray()
            UP_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight + 120 + 65)
            UP_BTN.alpha = 0.65
            
            DOWN_BTN.fillColor = SKColor.gray()
            DOWN_BTN.position = CGPoint(x: -semiWidth, y: -semiHeight + 120 - 65)
            DOWN_BTN.alpha = 0.65
            
            LEFT_BTN.fillColor = SKColor.gray()
            LEFT_BTN.position = CGPoint(x: -semiWidth - 65, y: -semiHeight + 120)
            LEFT_BTN.alpha = 0.65
            
            RIGHT_BTN.fillColor = SKColor.gray()
            RIGHT_BTN.position = CGPoint(x: -semiWidth + 65, y: -semiHeight + 120)
            RIGHT_BTN.alpha = 0.65
            
            ACTION_BTN.fillColor = SKColor.green()
            ACTION_BTN.position = CGPoint(x: semiWidth, y: -semiHeight + 120)
            ACTION_BTN.alpha = 0.65
            
            IDLE_BTN.fillColor = SKColor.gray()
            IDLE_BTN.position = CGPoint(x: semiWidth + 65, y: -semiHeight + 120 + 65)
            IDLE_BTN.alpha = 0.65
            
            CALL_BTN.fillColor = SKColor.red()
            CALL_BTN.position = CGPoint(x: semiWidth - 65, y: -semiHeight + 120 - 65)
            CALL_BTN.alpha = 0.65
            
            ZOOM_BTN.fillColor = SKColor.cyan()
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
        
        self.addChild(ThePlayer)
        self.addChild(TheEnemy)
        self.addChild(MAP)
        self.addChild(backgroundMusic)
        
        incMoveCount = 0
        outMoveCount = 0
        
        appDelegate = UIApplication.shared().delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.current().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MultiGameScene.peerChangedStateWithNotification), name: "MPC_DidChangeStateNotification" as NSNotification.Name, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MultiGameScene.handleReceivedDataWithNotification), name: "MPC_DidReceiveDataNotification" as NSNotification.Name, object: nil)
        
        connectWithPlayer()
    }
    
    func connectWithPlayer() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            self.view?.window?.rootViewController!.present(appDelegate.mpcHandler.browser, animated: true,completion:{
                self.connected = true
            })
        }
    }
    
    func peerChangedStateWithNotification(_ notification:Notification){
        let userInfo = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let state = userInfo.object(forKey: "state") as! Int
        
        if state == MCSessionState.connected.rawValue {
            self.view?.window?.rootViewController!.navigationItem.title = "Connected"
            print(connected)
            sendPlayerNum()
        }
    }
    
    func handleReceivedDataWithNotification(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo! as Dictionary
        let receivedData:Data = userInfo["data"] as! Data
        let message = try! JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as! MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.object(forKey: "player") != nil {
            let player:String? = message.object(forKey: "player") as? String
            let playerID:String? = message.object(forKey: "playerID") as? String
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
        } else if message.object(forKey: "playerName") != nil {
            if currentPlayer == "2" {
                let playerName:String? = message.object(forKey: "playerName") as? String
                let playerDirection:String? = message.object(forKey: "direction") as? String
                let playerChars:String? = message.object(forKey: "chars") as? String
                let incCount:Int? = Int((message.object(forKey: "outCount") as? String)!)
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
                let playerName:String? = message.object(forKey: "playerName") as? String
                let playerChars:String? = message.object(forKey: "chars") as? String
                let playerDirection:String? = message.object(forKey: "direction") as? String
                //print("Received PlayerInfo#, Going to read and assign it")
                if playerName != nil {
                    TheEnemy.moveTo = playerDirection!
                    TheEnemy.playerChars = playerChars!
                }
            }
        } else if message.object(forKey: "nutrientColor") != nil {
            if currentPlayer == "2" {
                let nutrientColor:String? = message.object(forKey: "nutrientColor") as? String
                let nutrientWorth:Int? = message.object(forKey: "nutrientWorth") as? Int
                let nutrientXPos:Int? = message.object(forKey: "nutrientX") as? Int
                let nutrientYPos:Int? = message.object(forKey: "nutrientY") as? Int
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
        } else if message.object(forKey: "onionColor") != nil {
            if currentPlayer == "2" {
                let onionColor:String? = message.object(forKey: "onionColor") as? String
                let onionXPos:Int? = message.object(forKey: "onionX") as? Int
                let onionYPos:Int? = message.object(forKey: "onionY") as? Int
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
        } else if message.object(forKey: "flowerColor") != nil {
            if currentPlayer == "2" {
                let flowerColor:String? = message.object(forKey: "flowerColor") as? String
                let flowerXPos:Int? = message.object(forKey: "flowerX") as? Int
                let flowerYPos:Int? = message.object(forKey: "flowerY") as? Int
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
        } else if message.object(forKey: "correctXPos") != nil {
            let correctXPos:CGFloat? = message.object(forKey: "correctXPos") as? CGFloat
            let correctYPos:CGFloat? = message.object(forKey: "correctYPos") as? CGFloat
            //print("Received PlayerInfo#, Going to read and assign it")
            if correctXPos != nil {
                TheEnemy.position = CGPoint(x: correctXPos!, y: correctYPos!)
            }
        } else if message.object(forKey: "forOnion") != nil {
            let randX:CGFloat? = message.object(forKey: "randXSeed") as? CGFloat
            let onionColor:String? = message.object(forKey: "forOnion") as? String
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
        }  else if message.object(forKey: "forFlower") != nil {
            let randX:CGFloat? = message.object(forKey: "randXSeed") as? CGFloat
            let flowerColor:String? = message.object(forKey: "forFlower") as? String
            print("Received FlowerSeed Request")
            if randX != nil {
                let whiteFlower = self.childNode(withName: "Flower_White") as! Flower
                let purpleFlower = self.childNode(withName: "Flower_Purple") as! Flower
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
    
    func sendNutrient(_ nutrient:Nutrient) {
        let messageDict = ["nutrientColor":nutrient.nutrientColor,"nutrientWorth":nutrient.worth, "nutrientX":(nutrient.position.x as! Int),"nutrientY":(nutrient.position.y as! Int)]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendOnion(_ onion:Onion) {
        let messageDict = ["onionColor":onion.onionColor,"onionX":onion.position.x,"onionY":onion.position.y]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlower(_ flower:Flower) {
        let messageDict = ["flowerColor":flower.flowerColor,"flowerX":flower.position.x,"flowerY":flower.position.y]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendPlayerNum() {
        let messageDict = ["player":self.currentPlayer]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendCorrectedPos(_ player:Player) {
        let messageDict = ["correctXPos":CGFloat(player.position.x),"correctYPos":CGFloat(player.position.y)]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendOnionNum(_ onion:Onion,randX:CGFloat) {
        let messageDict = ["randXSeed":randX,"forOnion":onion.onionColor]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlowerNum(_ flower:Flower,randX:CGFloat) {
        let messageDict = ["randXSeed":randX,"forFlower":flower.flowerColor]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
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
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
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
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objectTouched = self.atPoint(location)
            let objectPlayerOn = self.atPoint(ThePlayer.position)
            if objectTouched == UP_BTN {
                ThePlayer.moveTo = "Up"
            } else if objectTouched == RIGHT_BTN {
                ThePlayer.moveTo = "Right"
            } else if objectTouched == LEFT_BTN {
                ThePlayer.moveTo = "Left"
            } else if objectTouched == DOWN_BTN {
                ThePlayer.moveTo = "Down"
            } else if objectTouched == ACTION_BTN {
                ThePlayer.playerChars = " "
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
                ThePlayer.playerChars = "q"
            } else if objectTouched == CALL_BTN {
                ThePlayer.recallPikmin()
                ThePlayer.playerChars = "b"
            } else if objectTouched == ZOOM_BTN {
                if self.camera!.xScale == 1 {
                    self.camera!.run(SKAction.scale(to: 0.75, duration: 0.25))
                } else if self.camera!.xScale == 0.75 {
                    self.camera!.run(SKAction.scale(to: 0.5, duration: 0.25))
                } else if self.camera!.xScale == 0.5 {
                    self.camera!.run(SKAction.scale(to: 1, duration: 0.25))
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
            } else if objectTouched == ACTION_BTN {
                if ThePlayer.pikminToThrow != nil {
                    ThePlayer.throwPikmin()
                    ThePlayer.playerChars = ""
                }
            } else {
                ThePlayer.playerChars = ""
            }
        }
    }
    
    func enemyExtras() {
        let objectEnemyOn = self.atPoint(TheEnemy.position)
        let chars = TheEnemy.playerChars
        if chars.contains(" ") {
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
        } else if chars.contains("q") {
            lastEnemyButton = "q"
            TheEnemy.makePikminIdle()
        } else if chars.contains("b") {
            lastEnemyButton = "b"
            TheEnemy.recallPikmin()
        } else if chars == "" {
            if lastEnemyButton == " " {
                TheEnemy.throwPikmin()
            }
            lastEnemyButton = ""
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.camera!.position = ThePlayer.position
        ThePlayer.move()
        TheEnemy.move()
        enemyExtras()
    }
}
