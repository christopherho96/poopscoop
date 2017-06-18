//
//  HomeScreenScene.swift
//  poopscoop
//
//  Created by Christopher Ho on 2017-06-10.
//  Copyright © 2017 chovo. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class HomeScreenScene: SKScene {
    
    
    let startGame = SKLabelNode(fontNamed: "SugarpunchDEMO")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height / 2)
        self.addChild(background)
        
        let titleOfGame = SKLabelNode(fontNamed: "SugarpunchDEMO")
        titleOfGame.text = "Poop Scoop"
        titleOfGame.fontSize = 200
        titleOfGame.fontColor = SKColor.white
        titleOfGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        titleOfGame.zPosition = 100
        self.addChild(titleOfGame)
        
        
        
        let scoopIcon = SKSpriteNode(imageNamed: "scoop180")
        scoopIcon.setScale(1.7)
        scoopIcon.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        
        scoopIcon.zPosition = 1
        self.addChild(scoopIcon)

        
        
        startGame.text = "Start Game"
        startGame.fontSize = 150
        startGame.name = "startgame"
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.2)
        
        startGame.zPosition = 1
        self.addChild(startGame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
          
            
            if startGame.contains(pointOfTouch){
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
    }
    
}
