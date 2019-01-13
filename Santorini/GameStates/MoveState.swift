//
//  MoveState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/31/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation

class MoveState:GameState {
    var figureRow:Int
    var figureCollumn:Int
    
    var moveRow:Int?
    var moveCollumn:Int?
    var buildRow:Int? = nil
    var buildCollumn:Int? = nil
    
    init(playerId: Int, figureRow:Int, figureCollumn:Int) {
        self.figureRow = figureRow
        self.figureCollumn = figureCollumn
        super.init(playerId: playerId)
    }
    
    override func action(context: GameScene) {
        if(context.toDelay()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.action(row: self.moveRow!, collumn: self.moveCollumn!, context: context)
            })
        } else {
            action(row: self.moveRow!, collumn: self.moveCollumn!, context: context)
        }
    }
    
    override func action(row: Int, collumn: Int, context: GameScene) {
        let previousFieldState:Field = context.getFieldState(row: figureRow, collumn: figureCollumn)
        let newFieldState:Field = context.getFieldState(row: row, collumn: collumn)
        var possibleMove: Bool = newFieldState.canPutFigure()
        
        if(possibleMove) {
            if(abs(figureRow - row) > 1 || abs(figureCollumn - collumn) > 1 || newFieldState.numOfBlocks() - previousFieldState.numOfBlocks() > 1) {
                possibleMove = false
            }
        }
        
        if(!possibleMove) {
            print("Imposible move ", row, " ", collumn)
        } else {
            context.moveFigure(rowFrom: self.figureRow, collumnFrom: self.figureCollumn, rowTo: row, collumnTo: collumn)
            let newState = BuildState(playerId: playerId, figureRow: row, figureCollumn: collumn)
            if(buildRow != nil && buildCollumn != nil) {
                newState.setBuildRow(row: buildRow!)
                newState.setBuildCollumn(collumn: buildCollumn!)
            }
            context.setGameState(newState: newState)
        }
        
    }
    
    func setMoveRow(row:Int) {
        self.moveRow = row
    }
    
    func setMoveCollumn(collumn:Int) {
        self.moveCollumn = collumn
    }
    
    func setBuildRow(row:Int) {
        self.buildRow = row
    }
    
    func setBuildCollumn(collumn:Int) {
        self.buildCollumn = collumn
    }

}
