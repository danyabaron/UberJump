//
//  GameScene.swift
//  UberJump
//
//  Created by Danya  on 6/21/16.
//  Copyright (c) 2016 Danya Baron. All rights reserved.
//

import SpriteKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        scaleFactor = self.size.width / 320.0
        
        //add gravity
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        //add background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        
        //reset
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false
        
        //add midground
        midgroundNode = createMidgroundNode()
        addChild(midgroundNode)
        
        //set contact delegate
        physicsWorld.contactDelegate = self
        
        
        // Foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        // HUD
        hudNode = SKNode()
        addChild(hudNode)
        
        //load level
        let levelPlist = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        
        //height at which player ends level
        endLevelY = levelData["EndY"]!.integerValue
        
        
        
        
        // Add the platforms
        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]
        
        for platformPosition in platformPositions {
            let patternX = platformPosition["x"]?.floatValue
            let patternY = platformPosition["y"]?.floatValue
            let pattern = platformPosition["pattern"] as! NSString
            
            // Look up the pattern
            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            for platformPoint in platformPattern {
                let x = platformPoint["x"]?.floatValue
                let y = platformPoint["y"]?.floatValue
                let type = PlatformType(rawValue: platformPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(platformNode)
            }
        }
        
        // Add the stars
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        for starPosition in starPositions {
            let patternX = starPosition["x"]?.floatValue
            let patternY = starPosition["y"]?.floatValue
            let pattern = starPosition["pattern"] as! NSString
            
            // Look up the pattern
            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let x = starPoint["x"]?.floatValue
                let y = starPoint["y"]?.floatValue
                let type = StarType(rawValue: starPoint["type"]!.integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(starNode)
            }
        }
        
        
        // Add the player
        player = createPlayer()
        foregroundNode.addChild(player)
        
        
        // Tap to Start
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        hudNode.addChild(tapToStartNode)
        
        //build the HUD
        
        //Stars 
        //1
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height - 30)
        hudNode.addChild(star)
        
        //2
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPoint(x: 50, y: self.size.height - 40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        //3
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        hudNode.addChild(lblStars)
        
        //4
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        //5
        lblScore.text = "0"
        hudNode.addChild(lblScore)
        
        
        
        
        // CoreMotion
        // 1
        motionManager.accelerometerUpdateInterval = 0.2
        // 2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {
            (accelerometerData: CMAccelerometerData?, error: NSError?) in
            // 3
            let acceleration = accelerometerData!.acceleration
            // 4
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
        })
    }
    
    
    // Layered Nodes
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var player: SKNode!
    
    // To Accommodate iPhone 6
    var scaleFactor: CGFloat!
    
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    
    var endLevelY = 0
    
    // motion manager for accelerometer
    let motionManager = CMMotionManager()
    
    //acceleration value from accelerometer 
    var xAcceleration: CGFloat = 0.0
    
    //labels for score and stars
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!
    
    //max y reached by player
    var maxPlayerY: Int!
    
    //game over
    var gameOver = false
    
    
    
    
    func createBackgroundNode() -> SKNode {
        // 1
        // Create the node
        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor
        
        // 2
        // Go through images until the entire background is built
        for index in 0...19 {
            // 3
            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))
            // 4
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
            //5
            backgroundNode.addChild(node)
        }
        
        // 6
        // Return the completed background node
        return backgroundNode
    }
    
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        playerNode.physicsBody?.dynamic = false
        playerNode.physicsBody?.allowsRotation = false
        
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
        
        
        return playerNode
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // if we are playing, ignore touches
        if player.physicsBody!.dynamic {
            return
        }
        
        //remove the tap to start node
        tapToStartNode.removeFromParent()
        
        //start player by putting them in physics simulation
        player.physicsBody?.dynamic = true
        
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }

    func createStarAtPosition(position: CGPoint, ofType type: StarType) -> StarNode {
        //1
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        
        node.position = thePosition
        node.name = "NODE_STAR"
        
        //2
        node.starType = type
        var sprite: SKSpriteNode
        if type == .Special {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        } else {
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.addChild(sprite)
        
        //3
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        //4
        node.physicsBody?.dynamic = false
        
        
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        
        
        
        return node
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var updateHUD = false
        
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        
        let other = whichNode as! GameObjectNode
        
        updateHUD = other.collisionWithPlayer(player)
        
        //update hud if necessary
        if updateHUD {
            //update hud in part 2
            
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
    }
    
    
    
    func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        //1
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        //2
        var sprite: SKSpriteNode
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        } else {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        node.addChild(sprite)
        
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
        
    }
    
    func createMidgroundNode() -> SKNode {
        //create node
        let theMidgroundNode = SKNode()
        var anchor: CGPoint!
        var xPosition: CGFloat!
        
        //1
        //add branches to midground
        for index in 0...9 {
            var spriteName: String
            //2
            
            let r = arc4random() % 2
            if r > 0  {
                spriteName = "BranchRight"
                anchor = CGPoint(x: 1.0, y: 0.5)
                xPosition = self.size.width
            } else {
                spriteName = "BranchLeft"
                anchor = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
            }
            
            //3
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.anchorPoint = anchor
            branchNode.position = CGPoint(x: xPosition, y: 500.0 * CGFloat(index))
            theMidgroundNode.addChild(branchNode)
        }
            return theMidgroundNode
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if gameOver {
            return
        }
        
        
        //new max height?
        //1
        if Int(player.position.y) > maxPlayerY {
            //2
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY!
            //3
            maxPlayerY = Int(player.position.y)
            //4
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
        
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodesWithName("NODE_PLATFORM", usingBlock: {
            (node, stop) in
            print("found platform node")
            let platform = node as! PlatformNode
            if self.player.position.y > platform.position.y + 145 {
                print("attempt to remove platform")
                platform.removeFromParent()
            }
        })
        
        foregroundNode.enumerateChildNodesWithName("NODE_STAR", usingBlock: {
            (node, stop) in
            print("found star node")
            let star = node as! StarNode
            if self.player.position.y > star.position.y + 145 {
                print("attempt to remove star")
                star.removeFromParent()
            }
        })
        
        
        //calculate player y offset
        
        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y-200.0))
        }
        
        // 1
        // Check if we've finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // 2
        // Check if we've fallen too far
        if Int(player.position.y) < maxPlayerY - 800 {
            endGame()
        }
        
    }
    
    override func didSimulatePhysics() {
        //set velocity based on x-axis acceleration
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
        
        //set x bounds
        if player.position.x < -20.0 {
            player.position = CGPoint(x: self.size.width + 20.0, y: player.position.y)
        } else if (player.position.x > self.size.width + 20.0) {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }
    
    
    func endGame() {
        gameOver = true
        
        GameState.sharedInstance.saveState()
        
    
        let reveal = SKTransition.fadeWithDuration(0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
        
        
    }
    
}

