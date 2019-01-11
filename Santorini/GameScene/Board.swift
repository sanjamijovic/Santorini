//
//  Board.swift
//  Santorini
//
//  Created by Sanja Mijovic on 1/3/19.
//  Copyright © 2019 Sanja Mijovic. All rights reserved.
//

import Foundation

class Board {
    private var stateMatrix:[[Field]] = [[Field]]()
    private var numOfRows:Int
    private var numOfCollumns:Int
    private var numOfPlayers:Int
    private var numOfFiguresPerPlayer:Int
    private var winner:Int? = nil
    
    private var currentPlayer:Int?
    private var playerFiguresPositions:[[Field]] = [[Field]]()
    
    init(board:Board) {
        self.numOfRows = board.numOfRows
        self.numOfCollumns = board.numOfCollumns
        self.numOfPlayers = board.numOfPlayers
        self.numOfFiguresPerPlayer = board.numOfFiguresPerPlayer
        self.winner = board.winner
        self.currentPlayer = board.currentPlayer
        
        for i in 0..<numOfRows {
            var subArray = [Field]()
            for j in 0..<numOfCollumns {
                subArray.append(Field(field:board.getFieldState(row: i, collumn: j)))
            }
            stateMatrix.append(subArray)
        }
        
        for i in 0..<numOfPlayers {
            var positions = [Field]()
            for j in 0..<numOfFiguresPerPlayer {
                let figure = board.getGamePiece(playerId: i, figureId: j)
                positions.append(Field(field: board.getFieldState(row: figure.getRow(), collumn: figure.getCollumn())))
            }
            playerFiguresPositions.append(positions)
        }
    }
    
    init(rows:Int, collumns:Int, numOfPlayers:Int, numOfFiguresPerPlayer:Int) {
        self.numOfRows = rows
        self.numOfCollumns = collumns
        self.numOfPlayers = numOfPlayers
        self.numOfFiguresPerPlayer = numOfFiguresPerPlayer
        
        for i in 0..<numOfRows {
            var subArray = [Field]()
            for j in 0..<numOfCollumns {
                subArray.append(Field(row: i, collumn:j, blockState: Field.BlockState.EMPTY, hasPlayer: false))
            }
            stateMatrix.append(subArray)
        }
        
        for _ in 0..<numOfPlayers {
            var positions = [Field]()
            for _ in 0..<numOfFiguresPerPlayer {
                positions.append(Field())
            }
            playerFiguresPositions.append(positions)
        }
    }
    
    func getFieldState(row:Int, collumn:Int) -> Field {
        return stateMatrix[row][collumn]
    }
    
    func setFieldState(row:Int, collumn:Int, newState:Field) {
        stateMatrix[row][collumn] = newState
    }
    
    func gameOver() -> Bool {
        var numCantMove = 0
        for i in 0..<numOfRows {
            for j in 0..<numOfCollumns {
                if(stateMatrix[i][j].playerOn() && stateMatrix[i][j].numOfBlocks() == 3) {
                    winner = stateMatrix[i][j].getPlayer()
                    return true
                }
                if(stateMatrix[i][j].playerOn()) {
                    if(!canMove(row: i, collumn: j)) {
                        numCantMove += 1
                        if(numCantMove == 2) {
                            winner = 1 - stateMatrix[i][j].getPlayer()
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func getWinner() -> Int? {
        return winner
    }
    
    func canBuild(row:Int, collumn:Int) -> Bool {
        for i in max(0, row - 1)..<min(row + 2, numOfRows) {
            for j in max(0, collumn - 1)..<min(collumn+2, numOfCollumns) {
                if(i == row && j == collumn) {
                    continue
                }
                if(stateMatrix[i][j].canBuild()) {
                    return true
                }
            }
        }
        return false
    }
    
    func canMove(row:Int, collumn:Int) -> Bool {
        for i in max(0, row - 1)..<min(row + 2, numOfRows) {
            for j in max(0, collumn - 1)..<min(collumn+2,numOfCollumns) {
                if(i == row && j == collumn) {
                    continue
                }
                if(stateMatrix[i][j].canPutFigure() && stateMatrix[i][j].numOfBlocks() - stateMatrix[row][collumn].numOfBlocks() <= 1) {
                    return true
                }
            }
        }
        return false
    }
    
    func moveFigure(rowFrom:Int, collumnFrom:Int, rowTo:Int, collumnTo:Int) -> Int{
        let playerId = stateMatrix[rowFrom][collumnFrom].removePlayer()
        stateMatrix[rowTo][collumnTo].putPlayer(playerId: playerId)
        
        var figureCount = 1
        if(playerFiguresPositions[playerId][0].getRow() == rowFrom && playerFiguresPositions[playerId][0].getCollumn() == collumnFrom) {
            figureCount = 0
        }
        playerFiguresPositions[playerId][figureCount] = stateMatrix[rowTo][collumnTo]
        return playerId
    }
    
    func moveFigure(figureId:Int, position:Field) -> Int {
        let figure = playerFiguresPositions[currentPlayer!][figureId]
        return moveFigure(rowFrom: figure.getRow(), collumnFrom: figure.getCollumn(), rowTo: position.getRow(), collumnTo: position.getCollumn())
    }
    
    func addFigure(playerId:Int, row:Int, collumn:Int) {
        stateMatrix[row][collumn].putPlayer(playerId: playerId)
        let figureCount = (playerFiguresPositions[playerId][0].playerOn() ? 1 : 0)
        playerFiguresPositions[playerId][figureCount] = stateMatrix[row][collumn]
    }
    
    func addBlock(row:Int, collumn:Int) -> Int {
        stateMatrix[row][collumn].addBlock()
        return stateMatrix[row][collumn].numOfBlocks()
    }
    
    func getCurrentPlayer() -> Int? {
        return currentPlayer
    }
    
    func setCurrentPlayer(playerId:Int) {
        currentPlayer = playerId
    }
    
    func distance(playerId:Int, node:Field) -> Int {
        return Field.distance(field1: node, field2: playerFiguresPositions[playerId][0]) +
               Field.distance(field1: node, field2: playerFiguresPositions[playerId][1])
    }
    
    func possibleMovesForCurrentPlayer(figureId:Int, build:Bool) -> [Field] {
        let figure = getGamePiece(playerId: currentPlayer!, figureId: figureId)
        return getPossibleMoves(node: figure, build: build)
    }
    
    func changeCurrentPlayer() {
        currentPlayer = 1 - currentPlayer!
    }
    
    func getGamePiece(playerId:Int, figureId:Int) -> Field {
        let figure = playerFiguresPositions[playerId][figureId]
        return stateMatrix[figure.getRow()][figure.getCollumn()]
    }
    
    func getPossibleMoves(node:Field, build:Bool) -> [Field] {
        var ret:[Field] = [Field]()
        let row = node.getRow()
        let collumn = node.getCollumn()
        
        for i in max(0, row - 1)..<min(row + 2, 5) {
            for j in max(0, collumn - 1)..<min(collumn + 2,5) {
                if(i==row && j==collumn) {
                    continue
                }
                if((!build && stateMatrix[i][j].canPutFigure() && stateMatrix[i][j].numOfBlocks() - node.numOfBlocks() <= 1) ||
                    (build && stateMatrix[i][j].canBuild())) {
                    ret.append(stateMatrix[i][j])
                }
            }
        }
        return ret
    }
    
    func getFigureId(playerId:Int, row:Int, collumn:Int) -> Int {
        return (playerFiguresPositions[playerId][0].getRow() == row &&
            playerFiguresPositions[playerId][0].getCollumn() == collumn ? 0 : 1)
    }
    
    func toString() -> String {
        var ret:String = String()
        
        for i in 0..<numOfRows {
            for j in 0..<numOfCollumns {
                let fieldState = stateMatrix[i][j]
                
                ret.append("\(fieldState.numOfBlocks())")
                if(fieldState.playerOn()) {
                    ret.append("+\(fieldState.getPlayer())")
                } else {
                    ret.append("     ")
                }
            }
            ret.append("\n")
        }
        return ret
    }
    
    func evaluate_old(move:Field, build:Field, playerId:Int) -> Int {
        let distance = self.distance(playerId: playerId, node: build) - self.distance(playerId: 1 - playerId, node: build)
        return move.numOfBlocks() + build.numOfBlocks() * distance
    }
    
    func evaluate_try(move:Field, build:Field, playerId:Int) -> Int {
        if(gameOver()) {
            return (winner == playerId ? Int.max : Int.min)
        }
        let distance = self.distance(playerId: playerId, node: build) - self.distance(playerId: 1 - playerId, node: build)
        let c1 = (playerId == move.getPlayer() ? 1 : -1)
        
        let movesAtBuildField = getPossibleMoves(node: build, build: false)
        let movesAtMoveFied = getPossibleMoves(node: move, build: false)
        var sumOfBlocksBuild = 0
        var sumOfBlocksMove = 0
        for m1 in movesAtBuildField {
            sumOfBlocksBuild += m1.numOfBlocks()
        }
        for m2 in movesAtMoveFied {
            sumOfBlocksMove += m2.numOfBlocks()
        }
        let movesCountMove = (movesAtMoveFied.count == 0 ? 1 : movesAtMoveFied.count)
        let movesCountBuild = (movesAtBuildField.count == 0 ? 1 : movesAtBuildField.count)
        
        return move.numOfBlocks() * c1 * sumOfBlocksMove - c1 * distance * build.numOfBlocks()
        
    }
    
    func evaluate(move:Field, build:Field, playerId:Int) -> Int {
        if(gameOver()) {
            return (winner == playerId ? Int.max : Int.min)
        }
        let maxFigure0 = getGamePiece(playerId: playerId, figureId: 0)
        let maxFigure1 = getGamePiece(playerId: playerId, figureId: 1)
        
        let minFigure0 = getGamePiece(playerId: 1 - playerId, figureId: 0)
        let minFigure1 = getGamePiece(playerId: 1 - playerId, figureId: 1)
        
        let c1 = (playerId == move.getPlayer() ? 1 : -1)
        
        let distance = self.distance(playerId: 1 - playerId, node: build) - self.distance(playerId: playerId, node: build)
        return c1 * move.numOfBlocks() + c1 * build.numOfBlocks() * distance + 4 * (maxFigure0.numOfBlocks() + maxFigure1.numOfBlocks())
            - 2 * (minFigure0.numOfBlocks() + minFigure1.numOfBlocks())
    }
    
}
