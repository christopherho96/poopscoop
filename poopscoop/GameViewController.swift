//
//  GameViewController.swift
//  poopscoop
//
//  Created by Christopher Ho on 2017-06-07.
//  Copyright © 2017 chovo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate{
    
    
   func authPlayer(){
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil{
                self.present(view!, animated: true, completion: nil)
            }else{
                
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
        }
    }
    
    public func saveHighScore(number: Int){
        
        if GKLocalPlayer.localPlayer().isAuthenticated{
            
            let scoreReporter = GKScore(leaderboardIdentifier: "poopscoopleaderboard")
            
            scoreReporter.value = Int64(number)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: nil)
            
        }
        
    }
    
    func showLeaderBoard(){
        let viewController = self.view.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authPlayer()
        
        let view = self.view as! SKView
            // Load the SKScene from 'GameScene.sks'
        
        
            
            let scene = HomeScreenScene(size: CGSize(width:1536, height: 2048))
        
  
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
        
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showLeaderBoard), name: NSNotification.Name(rawValue: "showLeaderboard"), object: nil)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
