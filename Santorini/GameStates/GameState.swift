//
//  GameState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/31/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation

class GameState {
    var playerId:Int
    
    init(playerId:Int) {
        self.playerId = playerId
    }
    
    func action(row:Int, collumn:Int, context:GameScene) {}
    func action(context:GameScene) {} // wrapper for the other method for AI machine to call
}
