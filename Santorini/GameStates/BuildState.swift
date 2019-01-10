//
//  BuildState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 1/1/19.
//  Copyright © 2019 Sanja Mijovic. All rights reserved.
//

import Foundation

class BuildState: GameState {
    private var figureRow:Int
    private var figureCollumn:Int
    
    private var buildRow:Int?
    private var buildCollumn:Int?
    
    init(playerId: Int, figureRow:Int, figureCollumn:Int) {
        self.figureRow = figureRow
        self.figureCollumn = figureCollumn
        super.init(playerId: playerId)
    }
    
    override func action(context: GameScene) {
//        let figureId = context.getBoard().getFigureId(playerId: playerId, row: figureRow, collumn: figureCollumn)
//        let (_, bestMove) = context.minimax(board: context.getBoard(), playerId: playerId, maxDepth: 5, currentDepth: 0, figureId: figureId, build: true)
        if(context.toDelay()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.action(row: self.buildRow!, collumn: self.buildCollumn!, context: context)
            })
        } else {
            self.action(row: buildRow!, collumn: buildCollumn!, context: context)
        }
    }
    
    override func action(row: Int, collumn: Int, context: GameScene) {
        let fieldState = context.getFieldState(row: row, collumn: collumn)
        var possibleAction:Bool = fieldState.canBuild()
        
        if(possibleAction) {
            if(abs(figureRow - row) > 1 || abs(figureCollumn - collumn) > 1) {
                possibleAction = false
            }
        }
        
        if(!possibleAction) {
            print("Impossible action ", self.figureRow, " ", self.figureCollumn, " pokusao ", row, " ", collumn)
        } else {
            context.addBlock(row:row, collumn:collumn)
            let player = 1 - playerId
            context.setPlayer(playerId: player)
            if(context.level != GameViewController.GameLevel.low) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    context.setGameState(newState: ChooseFigureState(playerId:player))
                })
            } else {
            context.setGameState(newState: ChooseFigureState(playerId:player))
            }
        }
    }
    
    func setBuildRow(row: Int) {
        self.buildRow = row
    }
    
    func setBuildCollumn(collumn:Int) {
        self.buildCollumn = collumn
    }
}
