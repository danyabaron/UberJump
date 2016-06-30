//
//  GameViewController.swift
//  UberJump
//
//  Created by Danya  on 6/21/16.
//  Copyright (c) 2016 Danya Baron. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        
        skView.presentScene(scene)
        
        }
    }

    func shouldAutorotate() -> Bool {
        return true
    }

    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func prefersStatusBarHidden() -> Bool {
        return true
    }

