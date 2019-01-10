//
//  GameScene.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/23/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import SpriteKit


let NUM_ROWS = 5
let NUM_COLLUMNS = 5
let NUM_PLAYERS = 2
let NUM_FIGURES_PER_PLAYER = 2

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameState:GameState = PositioningState(playerId: 0,figureId: 1)
    var level:GameViewController.GameLevel?
    var type:GameViewController.GameType?
    private var board:Board = Board(rows: NUM_ROWS, collumns: NUM_COLLUMNS, numOfPlayers: NUM_PLAYERS, numOfFiguresPerPlayer: NUM_FIGURES_PER_PLAYER)
    
    var grid:Grid?
    
    var playerLabels:[String] = ["", ""]
    var playerArrows:[SKSpriteNode] = []
    
    var path:UIBezierPath!
    var iteration:Bool?
    var readFile:Bool?
    var writeToFile:Bool? = true
    
    var gameDelegate: GameDelegate?
    
    var moves:[[Field]] = [[Field]]()
    
    override func didMove(to: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.backgroundColor = UIColor(red:0.71, green:0.89, blue:1.00, alpha:1.0)
        
        computeLevelAndType()
        
        // add player simbols on top of screen
        let firstPlayerSymbol:SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gamepiece0"))
        firstPlayerSymbol.position = CGPoint(x: 50, y: self.frame.maxY - 100)
        firstPlayerSymbol.setScale(0.25)
        addChild(firstPlayerSymbol)
        
        let secondPlayerSymbol:SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "gamepiece1"))
        secondPlayerSymbol.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 100)
        secondPlayerSymbol.setScale(0.25)
        addChild(secondPlayerSymbol)
        
        // assign labels to player symbols
        computePlayerLabels()
        let firstPlayerLabel:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        firstPlayerLabel.text = playerLabels[0]
        firstPlayerLabel.fontSize = 30
        firstPlayerLabel.position = CGPoint(x: 20 + firstPlayerLabel.frame.width / 2, y: self.frame.maxY - 100 - firstPlayerLabel.frame.height * 2)
        addChild(firstPlayerLabel)
        
        let secondPlayerLabel:SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        secondPlayerLabel.text = playerLabels[1]
        secondPlayerLabel.fontSize = 30
        secondPlayerLabel.position = CGPoint(x: self.frame.maxX - 20 - secondPlayerLabel.frame.width / 2, y: self.frame.maxY - 100 - secondPlayerLabel.frame.height * 2)
        addChild(secondPlayerLabel)
        
        // assign arrows to players for determining who is on move
        let firstPlayerArrow:SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "arrow_right"))
        firstPlayerArrow.setScale(0.1)
        firstPlayerArrow.position = CGPoint(x: 50 + firstPlayerSymbol.frame.width * 2, y: self.frame.maxY - 100)
        addChild(firstPlayerArrow)
        playerArrows.append(firstPlayerArrow)
        
        let secondPlayerArrow:SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "arrow_left"))
        secondPlayerArrow.setScale(0.1)
        secondPlayerArrow.position = CGPoint(x: self.frame.maxX - 50 - secondPlayerSymbol.frame.width * 2, y: self.frame.maxY - 100)
        addChild(secondPlayerArrow)
        playerArrows.append(secondPlayerArrow)
        
        // present board grid
        if let grid = Grid(blockSize: 100.0, rows:5, cols:5) {
            grid.position = CGPoint (x:frame.midX, y:frame.midY)
            addChild(grid)
            self.grid = grid
        }
        
        if(self.scene?.userData != nil) {
            if(readFile!) {
                let fp = FileParser(fileName: "input")
                board = fp.parseInput()
                grid?.present(board: board)
                setPlayer(playerId: board.getCurrentPlayer()!)
                setGameState(newState: ChooseFigureState(playerId: board.getCurrentPlayer()!))
            } else {
                // first player's turn to position his first figure
                setPlayer(playerId: 0)
                setGameState(newState: PositioningState(playerId: 0, figureId: 1))
            }
        }
        
    }
    
    func computeLevelAndType() {
        level = self.scene?.userData?.value(forKey: "level") as? GameViewController.GameLevel
        type = self.scene?.userData?.value(forKey: "type") as? GameViewController.GameType
        readFile = self.scene?.userData?.value(forKey: "readFile") as? Bool
        iteration = self.scene?.userData?.value(forKey: "iteration") as? Bool
    }
    
    func computePlayerLabels() {
        let onePlayer = GameViewController.GameType.onePlayer
        let twoPlayers = GameViewController.GameType.twoPlayers
        let AIGame = GameViewController.GameType.AIGame
        
        switch type {
            case onePlayer:
                playerLabels[0] = "Player"
                playerLabels[1] = "Computer"
            case twoPlayers:
                playerLabels[0] = "Player1"
                playerLabels[1] = "Player2"
            case AIGame:
                playerLabels[0] = "Computer1"
                playerLabels[1] = "Computer2"
            default: break
        }
    }
    
    func setPlayer(playerId:Int) {
        // present the arrow to point on player who is on turn
        board.setCurrentPlayer(playerId: playerId)
        if(type == GameViewController.GameType.AIGame && !iteration!) {
            return
        }
        playerArrows[playerId].isHidden = false
        playerArrows[1 - playerId].isHidden = true
    }
    
    
    func getFieldState(row:Int, collumn:Int) -> Field {
        return board.getFieldState(row:row, collumn:collumn)
    }
    
    func setFieldState(row:Int, collumn:Int, newState:Field) {
        board.setFieldState(row: row, collumn: collumn, newState: newState)
    }
    
    func getGameState() -> GameState {
        return gameState
    }
    
    func setGameState(newState:GameState) {
        gameState = newState
        if(gameOver()) {
            if(writeToFile!) {
                let fp = FileParser(fileName: "output")
                fp.write(moves: moves)
            }
            
            if(type == GameViewController.GameType.AIGame && !iteration!) {
                print(board.toString())
                grid!.present(board: board)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.gameOver(winnerId: self.board.getWinner()!)
                })
            } else {
                gameOver(winnerId: board.getWinner()!)
            }
        } else if((type == GameViewController.GameType.onePlayer && board.getCurrentPlayer() == 1) ||
            type == GameViewController.GameType.AIGame) {
            newState.action(context: self)
        }
    }
    
    func gameOver() -> Bool {
        return board.gameOver()
    }
    
    func gameOver(winnerId:Int) {
        gameDelegate?.present(title: "Game over", message: playerLabels[winnerId] + " won")
    }
    
    func canBuild(row:Int, collumn:Int) -> Bool {
        return board.canBuild(row: row, collumn: collumn)
    }
    
    func canMove(row:Int, collumn:Int) -> Bool {
        return board.canMove(row: row, collumn: collumn)
    }
    
    func moveFigure(rowFrom:Int, collumnFrom:Int, rowTo:Int, collumnTo:Int) {
        let playerId = board.moveFigure(rowFrom: rowFrom, collumnFrom: collumnFrom, rowTo: rowTo, collumnTo: collumnTo)
        
        var move = [Field] ()
        move.append(Field(row: rowFrom, collumn: collumnFrom))
        move.append(Field(row: rowTo, collumn: collumnTo))
        moves.append(move)
        
        if(type == GameViewController.GameType.AIGame && !iteration!) {
            return
        }
            
        grid?.moveFigure(playerId: playerId, rowFrom: rowFrom, collumnFrom: collumnFrom, rowTo: rowTo, collumnTo: collumnTo)
    }
    
    func addFigure(playerId:Int, row:Int, collumn:Int) {
        board.addFigure(playerId: playerId, row: row, collumn: collumn)
        
        if(moves.count <= playerId) {
            moves.append([Field]())
            moves[playerId].append(board.getGamePiece(playerId: playerId, figureId: 0))
        } else {
            moves[playerId].append(board.getGamePiece(playerId: playerId, figureId: 1))
        }
        
        if(type == GameViewController.GameType.AIGame && !iteration!) {
            return
        }
        grid?.addFigure(playerId: playerId, row: row, collumn: collumn)
    }
    
    func addBlock(row:Int, collumn:Int) {
        let numOfBlocks = board.addBlock(row: row, collumn: collumn)
        
        let move = Field(row: row, collumn: collumn)
        moves[moves.endIndex - 1].append(move)
        
        if(type == GameViewController.GameType.AIGame && !iteration!) {
            return
        }
        grid?.putBlocks(row: row, collumn: collumn, level: numOfBlocks - 1)
    }
    
    func minimax(board:Board, playerId:Int, maxDepth:Int, currentDepth:Int, figureId:Int, move:Field? = nil, build:Field? = nil) -> (bestScore:Int, bestMove:Field, bestBuild:Field) {
        if(board.gameOver() || currentDepth == maxDepth) {
            return (bestScore: board.evaluate(move: move!, build: build!, playerId: playerId), bestMove: move!, bestBuild:build!)
        }
        var bestMove:Field = Field()
        var bestBuild:Field = Field()
        var bestScore:Int
        bestScore = (board.getCurrentPlayer() == playerId ? Int.min : Int.max)
        
        for move in board.possibleMovesForCurrentPlayer(figureId: figureId, build: false) {
            let newBoard = Board(board: board) // make copy
            var currentScore:Int
            newBoard.moveFigure(figureId: figureId, position: move)
            
            for build in newBoard.possibleMovesForCurrentPlayer(figureId: figureId, build: true) {
                let newNewBoard = Board(board: newBoard)
                newNewBoard.addBlock(row: build.getRow(), collumn: build.getCollumn())
                newNewBoard.changeCurrentPlayer()
                
                let (score1, _, _) = minimax(board: newNewBoard, playerId: playerId, maxDepth: maxDepth, currentDepth: currentDepth + 1, figureId: 0, move: move, build: build)
                let (score2, _, _) = minimax(board: newNewBoard, playerId: playerId, maxDepth: maxDepth, currentDepth: currentDepth + 1, figureId: 1, move: move, build: build)
                
                if(board.getCurrentPlayer() == playerId) {
                    currentScore = max(score1, score2)
                } else {
                    currentScore = min(score1, score2)
                }
                
                if (board.getCurrentPlayer() == playerId) { // MAX PLAYER
                    if (currentScore > bestScore) {
                        bestScore = currentScore
                        bestMove = move
                        bestBuild = build
                    }
                } else {                                    // MIN PLAYER
                    if (currentScore < bestScore) {
                        bestScore = currentScore
                        bestMove = move
                        bestBuild = build
                    }
                }
            }
        }
        
        return (bestScore, bestMove, bestBuild)
    }
    
    func minimaxAlphaBeta(board:Board, playerId:Int, maxDepth:Int, currentDepth:Int, figureId:Int, move:Field? = nil, build:Field? = nil, alpha:Int = Int.min, beta:Int = Int.max) -> (bestScore:Int, bestMove:Field, bestBuild:Field) {
        if(board.gameOver() || currentDepth == maxDepth) {
            return (bestScore: board.evaluate(move: move!, build: build!, playerId: playerId), bestMove: move!, bestBuild:build!)
        }
        var bestMove:Field = Field()
        var bestBuild:Field = Field()
        var bestScore:Int = (board.getCurrentPlayer() == playerId ? Int.min : Int.max)
        
        var alphaToPass:Int = alpha
        var betaToPass:Int = beta
        
        for move in board.possibleMovesForCurrentPlayer(figureId: figureId, build: false) {
            let newBoard = Board(board: board) // make copy
            var currentScore:Int
            newBoard.moveFigure(figureId: figureId, position: move)
            
            for build in newBoard.possibleMovesForCurrentPlayer(figureId: figureId, build: true) {
                let newNewBoard = Board(board: newBoard)
                newNewBoard.addBlock(row: build.getRow(), collumn: build.getCollumn())
                newNewBoard.changeCurrentPlayer()
                
                let (score1, _, _) = minimaxAlphaBeta(board: newNewBoard, playerId: playerId, maxDepth: maxDepth, currentDepth: currentDepth + 1, figureId: 0, move: move, build: build,
                                             alpha: alphaToPass, beta:betaToPass)
                let (score2, _, _) = minimaxAlphaBeta(board: newNewBoard, playerId: playerId, maxDepth: maxDepth, currentDepth: currentDepth + 1, figureId: 1, move: move, build: build,
                                             alpha: alphaToPass, beta:betaToPass)
                
                if(board.getCurrentPlayer() == playerId) {
                    currentScore = max(score1, score2)
                } else {
                    currentScore = min(score1, score2)
                }
                
                if (board.getCurrentPlayer() == playerId) { // MAX PLAYER
                    if (currentScore > bestScore) {
                        bestScore = currentScore
                        bestMove = move
                        bestBuild = build
                        if(bestScore >= beta) {
                            return (bestScore, bestMove, bestBuild)
                        }
                        alphaToPass = max(alpha, bestScore)
                    }
                } else {                                    // MIN PLAYER
                    if (currentScore < bestScore) {
                        bestScore = currentScore
                        bestMove = move
                        bestBuild = build
                        if(bestScore <= alpha) {
                            return (bestScore, bestMove, bestBuild)
                        }
                        betaToPass = min(bestScore, beta)
                    }
                }
            }
        }
        
        return (bestScore, bestMove, bestBuild)
    }
    
    func getBoard() -> Board {
        return board
    }
    
    func canMakeAction() -> Bool {
        if((type == GameViewController.GameType.onePlayer && board.getCurrentPlayer() == 1) || type == GameViewController.GameType.AIGame) {
            return false
        }
        return true
    }
    
    func selectFigure(playerId: Int, row: Int, collumn: Int) {
        if(type == GameViewController.GameType.AIGame && !iteration!) {
            return
        }
        grid?.selectFigure(playerId: playerId, row: row, collumn: collumn)
    }
    
    func toDelay() -> Bool {
        return !(type == GameViewController.GameType.AIGame && !iteration!)
    }
 }
