//
//  PositioningState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/31/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import SpriteKit

class PositioningState:GameState {
    var figureId:Int
    
    init(playerId:Int, figureId:Int) {
        self.figureId = figureId
        super.init(playerId: playerId)
    }
    
    override func action(context:GameScene) {
        var row:Int?
        var collumn:Int?
        while(true) {
            row = Int.random(in: 0..<5)
            collumn = Int.random(in: 0..<5)
            if(!context.getFieldState(row: row!, collumn:collumn!).playerOn()) {
                break
            }
            
        }
        if(context.toDelay()) { // present chosen figure after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
               self.action(row:row!, collumn:collumn!, context:context)
            })
        } else {
            self.action(row:row!, collumn:collumn!, context:context)
        }
    }
    
    override func action(row:Int, collumn:Int, context:GameScene) {
        let fieldState = context.getFieldState(row: row, collumn: collumn)
        if (fieldState.numOfBlocks() == 0 && !fieldState.playerOn()) {
            fieldState.putPlayer(playerId: playerId)
            
            context.addFigure(playerId: playerId, row: row, collumn: collumn)
            
            switch(playerId, figureId) {
                case (0, 1):
                    context.setPlayer(playerId: 1)
                    context.setGameState(newState: PositioningState(playerId: 1, figureId: 1))
                case (1, 1):
                    context.setPlayer(playerId: 0)
                    context.setGameState(newState: PositioningState(playerId: 0, figureId: 2))
                case (0, 2):
                    context.setPlayer(playerId: 1)
                    context.setGameState(newState: PositioningState(playerId: 1, figureId: 2))
                case (1, 2):
                    context.setPlayer(playerId: 0)
                    context.setGameState(newState: ChooseFigureState(playerId: 0))
                case (_, _):
                    break
            }
        }
    }
}
