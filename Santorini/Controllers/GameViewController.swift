//
//  GameViewController.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/18/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol GameDelegate {
    func present(title:String, message:String)
}


class GameViewController: UIViewController, GameDelegate {
    func present(title: String, message: String) {
        let gameOverAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKAction - back to initial view
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        }
        
        //cancelAction - cancel the Alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        gameOverAlertController.addAction(OKAction)
        gameOverAlertController.addAction(cancelAction)
        self.present(gameOverAlertController, animated:false, completion:nil)
    }
    
    enum GameLevel {
        case low, medium, high
    }
    
    enum GameType {
        case onePlayer, twoPlayers, AIGame
    }
    
    var level:GameLevel?
    var type:GameType?
    var iteration:Bool?
    var readFile:Bool?
    
    @IBOutlet var gameView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if let scene = GameScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            scene.userData = NSMutableDictionary()
            scene.userData?.setValue(readFile, forKey: "readFile")
            scene.userData?.setValue(level, forKey: "level")
            scene.userData?.setValue(type, forKey: "type")
            scene.userData?.setValue(iteration, forKey: "iteration")
            scene.gameDelegate = self
            
            gameView.presentScene(scene)
        }
    }
    
}
