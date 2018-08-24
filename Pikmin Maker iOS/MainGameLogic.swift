//
//  MainGameLogic.swift
//  Pikmin
//
//  Created by Bryan Mazariegos on 8/23/18.
//  Copyright © 2018 Bryan Mazariegos. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

let BackmostLayer:CGFloat = -999999
let BackLayer:CGFloat = 10
let MidLayer:CGFloat = 20
let FrontLayer:CGFloat = 30
let UILayer:CGFloat = 999999
let ghostAtlas = SKTextureAtlas(named: "Ghosts")
let machineAtlas = SKTextureAtlas(named: "Machines")
let monsterAtlas = SKTextureAtlas(named: "Monsters")
let pikminAtlas = SKTextureAtlas(named: "Pikmin")
let playerAtlas = SKTextureAtlas(named: "Players")
let worldAtlas = SKTextureAtlas(named: "World")

enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

class MainGameLogic:SKScene, MCBrowserViewControllerDelegate {
    var ThePlayer = Player(texture: playerAtlas.textureNamed("Olimar_Down_Stand"))
    var TheEnemy = Player(imageNamed:"Olimar_Down_Stand")
    var TheShip = Ship(texture: worldAtlas.textureNamed("Ship_Empty"))
    let RedOnion = Onion(texture: worldAtlas.textureNamed("Onion_Inactive"))
    let BlueOnion = Onion(texture: worldAtlas.textureNamed("Onion_Inactive"))
    let YellowOnion = Onion(texture: worldAtlas.textureNamed("Onion_Inactive"))
    
    let Space = SKSpriteNode(imageNamed:"space")
    
    var sundial = SKShapeNode(circleOfRadius: 20)
    
    var pikminCount = SKLabelNode()
    
    var backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
    
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
    
    var timeFrame:Double = 10 //Default 30
    
    var inPlay = false
    var connected = false
    
    var currentPlayer:String = "2"
    
    var appDelegate:AppDelegate!
    
    var lastEnemyButton = ""
    
    override func didMove(to view: SKView) {
        trueSemiWidth = self.frame.width/2
        trueSemiHeight = self.frame.height/2
        MAP.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        MAP.zPosition = BackmostLayer
        
        ThePlayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ThePlayer.zPosition = FrontLayer
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
        
        let PurpleFlower = Flower(texture: worldAtlas.textureNamed("Flower_Purple_Open"))
        PurpleFlower.zPosition = MidLayer
        PurpleFlower.flowerColor = "Purple"
        
        let WhiteFlower = Flower(texture: worldAtlas.textureNamed("Flower_White_Open"))
        WhiteFlower.zPosition = MidLayer
        
        TheShip.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 300)
        TheShip.zPosition = MidLayer
        TheShip.setUp()
        
        Space.zPosition = BackmostLayer - 1
        Space.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.size.height/2)
        Space.setScale(4)
        
        nightOverlay = SKShapeNode(rect: self.frame)
        nightOverlay.zPosition = -1000
        nightOverlay.position = CGPoint(x: -self.frame.width/2, y: -self.frame.height/2)
        nightOverlay.fillColor = SKColor.black
        nightOverlay.alpha = 0.0
        nightOverlay.strokeColor = SKColor.clear
        self.camera!.addChild(nightOverlay)
        
        sundial.zPosition = UILayer
        sundial.position = CGPoint(x: 0, y: self.frame.height/2 - 20)
        sundial.fillColor = SKColor.yellow
        sundial.alpha = 1
        self.camera!.addChild(sundial)
        
        pikminCount.zPosition = UILayer
        pikminCount.horizontalAlignmentMode = .right
        pikminCount.position = CGPoint(x: self.frame.width/2 - 50, y: self.frame.height/2 - 26)
        pikminCount.alpha = 1
        self.camera!.addChild(pikminCount)
        
        self.camera?.zPosition = UILayer
        
        var nutrientsAdded = 0
        while nutrientsAdded < 12 { //Default 12
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
            
            let nutrient = Nutrient(texture: worldAtlas.textureNamed("Nutrient_\(color)"))
            nutrient.nutrientColor = color
            nutrient.position = CGPoint(x: self.frame.midX + randX, y: self.frame.midY + randY)
            nutrient.zPosition = BackLayer
            self.addChild(nutrient)
        }
        
        var devicesAdded = 0
        while devicesAdded < 14 { //Default 14
            devicesAdded += 1
            
            let device = Machine(texture: machineAtlas.textureNamed("Electrode_Inactive"))
            self.addChild(device)
            device.randomizePosition()
            device.setUp()
            device.zPosition = BackLayer
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
        self.addChild(TheEnemy)
        self.addChild(MAP)
        self.addChild(RedOnion)
        self.addChild(BlueOnion)
        self.addChild(YellowOnion)
        self.addChild(TheShip)
        self.addChild(PurpleFlower)
        self.addChild(WhiteFlower)
        self.addChild(Space)
        self.addChild(backgroundMusic)
        
        self.view?.ignoresSiblingOrder = true
        self.view?.showsDrawCount = true
        
        RedOnion.randomizePosition()
        YellowOnion.randomizePosition()
        BlueOnion.randomizePosition()
        WhiteFlower.randomizePosition()
        PurpleFlower.randomizePosition()
        
        TheEnemy.isHidden = true
        
        runAppDelegateSetUpCode()
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.peerChangedStateWithNotification), name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.handleReceivedDataWithNotification), name:  NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification"), object: nil)
    }
    
    func runAppDelegateSetUpCode() {
        fatalError("Must implement 'runAppDelegateSetUpCode'")
    }
    
    func presentMPCBrowser() {
        fatalError("Must implement 'presentMPCBrowser'")
    }
    
    func dismissMPCBrowser() {
        fatalError("Must implement 'dismissMPCBrowser'")
    }
    
    func connectWithPlayer() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            appDelegate.mpcHandler.browser.maximumNumberOfPeers = 2
            presentMPCBrowser()
        }
    }
    
    func peerChangedStateWithNotification(_ notification:Notification){
        let userInfo = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let state = userInfo.object(forKey: "state") as! Int
        
        if state == MCSessionState.connected.rawValue {
            print(connected)
            sendPlayerNum()
            if TheEnemy.isHidden {
                TheEnemy.isHidden = false
            }
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
                //print("Received PlayerInfo#, Going to read and assign it")
                if playerName != nil {
                    TheEnemy.moveTo = playerDirection!
                    TheEnemy.playerChars = playerChars!
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
                let onionXPos:CGFloat? = message.object(forKey: "onionX") as? CGFloat
                let onionYPos:CGFloat? = message.object(forKey: "onionY") as? CGFloat
                //print("Received PlayerInfo#, Going to read and assign it")
                if onionColor != nil {
                    if onionColor == "Red" {
                        self.RedOnion.position = CGPoint(x: onionXPos!, y: onionYPos!)
                    } else if onionColor == "Blue" {
                        self.BlueOnion.position = CGPoint(x: onionXPos!, y: onionYPos!)
                    } else if onionColor == "Yellow" {
                        self.YellowOnion.position = CGPoint(x: onionXPos!, y: onionYPos!)
                    }
                }
            }
        } else if message.object(forKey: "flowerColor") != nil {
            if currentPlayer == "2" {
                let flowerColor:String? = message.object(forKey: "flowerColor") as? String
                let flowerXPos:CGFloat? = message.object(forKey: "flowerX") as? CGFloat
                let flowerYPos:CGFloat? = message.object(forKey: "flowerY") as? CGFloat
                //print("Received PlayerInfo#, Going to read and assign it")
                if flowerColor != nil {
                    let flower = Flower(imageNamed:"Flower_" + flowerColor! + "_Open")
                    flower.flowerColor = flowerColor!
                    flower.position = CGPoint(x: flowerXPos!, y: flowerYPos!)
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
        let messageDict = ["nutrientColor":nutrient.nutrientColor,"nutrientWorth":nutrient.worth, "nutrientX":Int(nutrient.position.x),"nutrientY":(Int(nutrient.position.y))] as [String : Any]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendOnion(_ onion:Onion) {
        let messageDict = ["onionColor":onion.onionColor,"onionX":onion.position.x,"onionY":onion.position.y] as [String : Any]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlower(_ flower:Flower) {
        let messageDict = ["flowerColor":flower.flowerColor,"flowerX":flower.position.x,"flowerY":flower.position.y] as [String : Any]
        
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
        let messageDict = ["randXSeed":randX,"forOnion":onion.onionColor] as [String : Any]
        
        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: MCSessionSendDataMode.reliable)
            //print("Sent Player#")
        } catch {
            print("Error: Couldn't send Player#")
        }
    }
    
    func sendFlowerNum(_ flower:Flower,randX:CGFloat) {
        let messageDict = ["randXSeed":randX,"forFlower":flower.flowerColor] as [String : Any]
        
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
        messageDict = ["playerName":ThePlayer.character,"direction":ThePlayer.moveTo,"chars":ThePlayer.playerChars]
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
            
            var devicesAdded = 0
            while devicesAdded < 0 { //Default 10
                devicesAdded += 1
                
                let device = Machine(texture: machineAtlas.textureNamed("Electrode_Inactive"))
                self.addChild(device)
                device.randomizePosition()
                device.setUp()
                device.zPosition = BackLayer
            }
            
            if RedOnion.parent == nil {
                self.addChild(RedOnion)
                self.addChild(BlueOnion)
                self.addChild(YellowOnion)
            }
            
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
        dismissMPCBrowser()
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismissMPCBrowser()
        //appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func receiveDownPressData(inputReceived:String,objectsPlayerOn:[SKNode],pikColor:String) {
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
        
        if inputReceived == "MP" {
            connectWithPlayer()
        } else if inputReceived == "Up" {
            if TheShip.followShip {
                TheShip.toMultiplayer()
            } else {
                ThePlayer.moveTo = "Up"
            }
        } else if inputReceived == "Right" {
            if TheShip.followShip {
                backgroundMusic.removeFromParent()
                backgroundMusic = SKAudioNode(fileNamed: "forestOfHope")
                backgroundMusic.autoplayLooped = true
                self.addChild(backgroundMusic)
            } else {
                ThePlayer.moveTo = "Right"
            }
        } else if inputReceived == "Left" {
            if TheShip.followShip {
                backgroundMusic.removeFromParent()
                backgroundMusic = SKAudioNode(fileNamed: "forestNaval")
                backgroundMusic.autoplayLooped = true
                self.addChild(backgroundMusic)
            } else {
                ThePlayer.moveTo = "Left"
            }
        } else if inputReceived == "Down" {
            if TheShip.followShip {
                TheShip.backToEarth()
            } else {
                ThePlayer.moveTo = "Down"
            }
        }
        
        checkPlayerOn()
        
        if inputReceived == "Action" {
            ThePlayer.playerChars = " "
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
        } else if inputReceived == "Idle" {
            ThePlayer.makePikminIdle()
            ThePlayer.playerChars = "q"
        } else if inputReceived == "Recall" {
            ThePlayer.recallPikmin()
            ThePlayer.playerChars = "b"
        } else if inputReceived == "Zoom" {
            if self.camera!.xScale == 1 {
                self.camera!.run(SKAction.scale(to: 0.75, duration: 0.25))
            } else if self.camera!.xScale == 0.75 {
                self.camera!.run(SKAction.scale(to: 0.5, duration: 0.25))
            } else if self.camera!.xScale == 0.5 {
                self.camera!.run(SKAction.scale(to: 5, duration: 0.25))
            } else if self.camera!.xScale == 5 {
                self.camera!.run(SKAction.scale(to: 1, duration: 0.25))
            }
        } else if inputReceived.contains("Deposit") || inputReceived.contains("Withdraw") {
            pikminOut = pikminCount3()
            print(pikColor + " Pikmin following Player: " + String(self.pikminCount(pikColor)))
            
            if inputReceived == "Deposit" {
                print("Depositing Pikmin. Color: " + pikColor)
                
                if self.pikminCount(pikColor) > 0 {
                    var index = -1
                    var found = false
                    while index < ThePlayer.pikminFollowing.count - 1 && !found {
                        index += 1
                        
                        if !ThePlayer.pikminFollowing[index].busy && !ThePlayer.pikminFollowing[index].attacking && !ThePlayer.pikminFollowing[index].movingToHome && ThePlayer.pikminFollowing[index].pikminColor == pikColor {
                            
                            ThePlayer.pikminFollowing[index].movingToHome = true
                            ThePlayer.pikminFollowing[index].idle = true
                            ThePlayer.pikminFollowing[index].returning = false
                            ThePlayer.pikminFollowing[index].run(SKAction.sequence([SKAction.wait(forDuration: Double(index)/100),ThePlayer.pikminFollowing[index].pikminLeft]))
                            ThePlayer.pikminFollowing.remove(at: index)
                            found = true
                        }
                    }
                }
            } else if inputReceived == "Withdraw" {
                print("Withdrawing Pikmin. Color: " + pikColor)
                
                if self.pikminCount2(pikColor) > 0 {
                    var index = -1
                    var found = false
                    while index < existingPikmin.count - 1 && !found {
                        index += 1
                        
                        if existingPikmin[index].inHome && existingPikmin[index].pikminColor == pikColor {
                            existingPikmin[index].inHome = false
                            existingPikmin[index].isHidden = false
                            existingPikmin[index].becomeAwareToFollow()
                            found = true
                        }
                    }
                }
            }
        } else if inputReceived == "EndDay" {
            TheShip.getIn(ThePlayer)
            TheShip.toggleMenuOverlay()
        }
    }
    
    func receiveDePressData(inputReceived:String) {
        if inputReceived == "Up" || inputReceived == "Down" || inputReceived == "Left" || inputReceived == "Right" {
            ThePlayer.moveTo = ""
        }
        
        if inputReceived == "Action" {
            pikminOut = pikminCount3()
            if ThePlayer.pikminToThrow != nil {
                ThePlayer.throwPikmin()
                ThePlayer.playerChars = ""
            }
        } else if inputReceived == "Recall" {
            pikminOut = pikminCount3()
            ThePlayer.recallCircle.removeAllActions()
            ThePlayer.playerChars = ""
            ThePlayer.recallCircle.run(SKAction.scale(to: 1, duration: 0.15),completion:{
                self.ThePlayer.callingPikmin = false
            })
        } else {
            ThePlayer.playerChars = ""
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
            TheEnemy.move()
            enemyExtras()
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
            /*
            if RedOnion.awake && !ThePlayer.timeForSpace {
                var seeds = 0
                while seeds < 5 {
                    seeds += 1
                    RedOnion.dispelSeed()
                }
            }
            */
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
        
        if gameTime > 19 ||	 gameTime < 7 {
            let random = arc4random_uniform(10) + 1
            if random <= 3 {
                let aMonster = Monster(texture: monsterAtlas.textureNamed("Monster_Red_Bulborb_Down_Stand"))
                aMonster.zPosition = BackLayer
                aMonster.monsterSpecies = "Red_Bulborb"
                aMonster.setUp()
                self.addChild(aMonster)
                aMonster.randomizePosition()
            }
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
