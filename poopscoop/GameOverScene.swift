//
//  GameOverScene.swift
//  poopscoop
//
//  Created by Christopher Ho on 2017-06-10.
//  Copyright © 2017 chovo. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    let backToHomeScreenLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
    
    override func didMove(to view: SKView) {
        let controller = self.view?.window?.rootViewController as! GameViewController
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height / 2)
        self.addChild(background)
        
        //game over label
        let gameOverLabel = SKLabelNode(fontNamed: "SugarpunchDEMO")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 100
        self.addChild(gameOverLabel)
        
        //score label of game just run
        let gameScoreLabel = SKLabelNode(fontNamed: "SugarPunchDEMO")
        gameScoreLabel.text = "Score: \(score)"
        gameScoreLabel.fontSize = 125
        gameScoreLabel.fontColor = SKColor.white
        gameScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        gameScoreLabel.zPosition = 1
        self.addChild(gameScoreLabel)
        
        
        //set high score default each time app is opened
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScoreSaved")
        
        if score > highScore{
            highScore = score
            defaults.set(highScore, forKey: "highScoreSaved")
            controller.saveHighScore(number: highScore)
        }
        
        //high score label
        let highScoreLabel = SKLabelNode(fontNamed: "SugarPunchDEMO")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
       
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        
        backToHomeScreenLabel.text = "Home Page"
        backToHomeScreenLabel.fontSize = 90
        backToHomeScreenLabel.fontColor = SKColor.white
        backToHomeScreenLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        backToHomeScreenLabel.zPosition = 1
        self.addChild(backToHomeScreenLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch){
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
            if backToHomeScreenLabel.contains(pointOfTouch){
                
                let sceneToMoveTo = HomeScreenScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }

        }
    }
}
