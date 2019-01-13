//
//  ChooseFigureState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/31/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation

class ChooseFigureState: GameState {
    
    override func action(context: GameScene) {
        let low = GameViewController.GameLevel.low
        let medium = GameViewController.GameLevel.medium
        var maxDepth:Int
        switch context.level {
        case low:
            maxDepth = 2
        case medium:
            maxDepth = 3
        default:
            maxDepth = 4
        }
        let optimized = (playerId == 1)
        let (bestScore1, bestMove1, bestBuild1) = context.minimax(board: context.getBoard(), playerId: playerId, maxDepth: maxDepth, currentDepth: 0, figureId: 0, pruning: true,
            optimized: optimized)
        let (bestScore2, bestMove2, bestBuild2) = context.minimax(board: context.getBoard(), playerId: playerId, maxDepth: maxDepth, currentDepth: 0, figureId: 1, pruning: true,
            optimized: optimized)
        
        var newState:MoveState
        var figure:Field
        
        if(bestScore1 > bestScore2) {
            figure = context.getBoard().getGamePiece(playerId: playerId, figureId: 0)
            newState = MoveState(playerId: self.playerId, figureRow: figure.getRow(), figureCollumn: figure.getCollumn())
            newState.setMoveRow(row: bestMove1.getRow())
            newState.setMoveCollumn(collumn: bestMove1.getCollumn())
            newState.setBuildRow(row: bestBuild1.getRow())
            newState.setBuildCollumn(collumn: bestBuild1.getCollumn())
        }
        else {
            figure = context.getBoard().getGamePiece(playerId: playerId, figureId: 1)
            newState = MoveState(playerId: self.playerId, figureRow: figure.getRow(), figureCollumn: figure.getCollumn())
            newState.setMoveRow(row: bestMove2.getRow())
            newState.setMoveCollumn(collumn: bestMove2.getCollumn())
            newState.setBuildRow(row: bestBuild2.getRow())
            newState.setBuildCollumn(collumn: bestBuild2.getCollumn())
            
        }
        
        if(context.toDelay()) {
            context.selectFigure(playerId: self.playerId, row: figure.getRow(), collumn: figure.getCollumn())
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                context.setGameState(newState: newState)
            })
        } else {
            context.setGameState(newState: newState)
        }
    }
    
    override func action(row: Int, collumn: Int, context: GameScene) {
        let fieldState = context.getFieldState(row: row, collumn: collumn)
        if(fieldState.playerOn() && fieldState.getPlayer() == playerId) {
            context.setGameState(newState: MoveState(playerId: self.playerId, figureRow: row, figureCollumn: collumn))
        } else {
            print("Invalid figure")
        }
    }
}
