//
//  GameObjectNode.swift
//  UberJump
//
//  Created by Danya  on 6/22/16.
//  Copyright © 2016 Danya Baron. All rights reserved.
//

import SpriteKit


enum StarType: Int {
    case Normal = 0
    case Special
}

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}


enum PlatformType: Int {
    case Normal = 0
    case Break
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        //only bounce the player if he's falling
        if player.physicsBody?.velocity.dy < 0 {
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250.0)
            
            //remove if it is a Break type platform
            if platformType == .Break {
                self.removeFromParent()
            }
        }
        
        //no stars for platforms
        return false
    }
}




class GameObjectNode: SKNode {
    func collisionWithPlayer(player: SKNode) -> Bool {
        // Award score
        
        return false
    }
    
//    func checkNodeRemoval(playerY: CGFloat) {
//        if playerY > self.position.y + 300.0 {
//            self.removeFromParent()
//        }
//    }
}
class StarNode: GameObjectNode {
    let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    
    
    var starType = StarType?()
    
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        //boost player up
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)
        
        //remove this star
        // Play sound
        runAction(starSound, completion: {
            // Remove this Star
            self.removeFromParent()
        })
        
        GameState.sharedInstance.score += (starType == .Normal ? 20 : 100)
        
        GameState.sharedInstance.stars += (starType == .Normal ? 1 : 5)
        
        //hud needs to update new stars and score
        return true
    }
}