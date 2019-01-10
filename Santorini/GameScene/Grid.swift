//
//  Grid.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/19/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    var rows:Int!
    var cols:Int!
    var blockSize:CGFloat!
    
    var gameScene:GameScene?
    
    var playerFigures:[[SKNode]] = [[SKNode]]()
    
    convenience init?(blockSize:CGFloat,rows:Int,cols:Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize,rows: rows, cols:cols) else {
            return nil
        }
        self.init(texture: texture, color:SKColor.clear, size: texture.size())
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
        self.isUserInteractionEnabled = true
        
        let firstPlayerFigures = [SKNode]()
        playerFigures.append(firstPlayerFigures)
        
        let secondPlayerFigures = [SKNode]()
        playerFigures.append(secondPlayerFigures)
        
    }
    
    class func gridTexture(blockSize:CGFloat,rows:Int,cols:Int) -> SKTexture? {
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        // Draw vertical lines
        for i in 0...cols {
            let x = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        // Draw horizontal lines
        for i in 0...rows {
            let y = CGFloat(i)*blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        SKColor.white.setStroke()
        bezierPath.lineWidth = 3.0
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset: CGFloat = blockSize / 2.0 + 0.5
        var x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0
        x += offset
        var y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0
        y += offset
        return CGPoint(x:x, y:y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let gameScene:GameScene = self.parent as? GameScene {
                if(gameScene.canMakeAction()) {
                    let position = touch.location(in:self)
                    let node = atPoint(position)
                    
                    if isPlayer(node:node) {
                        let pulseUp = SKAction.scale(to: 0.30, duration: 0.25)
                        let pulseDown = SKAction.scale(to: 0.25, duration: 0.25)
                        let pulse = SKAction.sequence([pulseUp, pulseDown])
                        let repeatPulse = SKAction.repeat(pulse, count: 2)
                        node.run(repeatPulse)
                    }
                    
                    let x = size.width / 2 + position.x
                    let y = size.height / 2 - position.y
                    let row = Int(floor(y / blockSize))
                    let col = Int(floor(x / blockSize))
                    
                    gameScene.getGameState().action(row: row, collumn: col, context: gameScene)
                }
            }
            
        }
    }
    
    func selectFigure(playerId:Int, row:Int, collumn:Int) {
        let nodesAtPoint = nodes(at: gridPosition(row: row, col: collumn))
        let i = (nodesAtPoint.contains(playerFigures[playerId][0]) ? 0 : 1)
        let pulseUp = SKAction.scale(to: 0.30, duration: 0.5)
        let pulseDown = SKAction.scale(to: 0.25, duration: 0.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeat(pulse, count: 2)
        playerFigures[playerId][i].run(repeatPulse)
    }
    
    func isPlayer(node:SKNode) -> Bool {
        return playerFigures[0].contains(node) || playerFigures[1].contains(node)
    }
    
    func addFigure(playerId:Int, row:Int, collumn:Int) {
        let imageString = (playerId == 0 ? "gamepiece0" : "gamepiece1")
        
        let playerPiece = SKSpriteNode(imageNamed: imageString)
        playerPiece.setScale(0.25)
        playerPiece.position = gridPosition(row: row, col: collumn)
        playerPiece.zPosition = 0
        addChild(playerPiece)
        self.playerFigures[playerId].append(playerPiece)
    }
    
    func moveFigure(playerId:Int, rowFrom:Int, collumnFrom:Int, rowTo:Int, collumnTo:Int) {
        let nodesAtPoint = nodes(at: gridPosition(row: rowFrom, col: collumnFrom))
        let i = (nodesAtPoint.contains(playerFigures[playerId][0]) ? 0 : 1)
        playerFigures[playerId][i].position = gridPosition(row: rowTo, col: collumnTo)
    }
    
    func putBlocks(row:Int, collumn:Int, level:Int) {
        let fileNames = ["level1", "level2", "level3", "tower"]
        
        let rectNode = nodes(at: gridPosition(row: row, col: collumn)).first
        if(rectNode == nil || isPlayer(node: rectNode!)) {
//            let rn = SKSpriteNode(color: color, size: CGSize(width: blockSize - 3, height: blockSize - 3))
            let  rn = SKSpriteNode(texture: SKTexture(imageNamed: fileNames[level]))
            rn.position = gridPosition(row: row, col: collumn)
            rn.setScale(0.25)
            rn.zPosition = -1
            addChild(rn)
        } else {
            let n:SKSpriteNode = rectNode as! SKSpriteNode
//            n.color = color
            n.texture = SKTexture(imageNamed: fileNames[level])
        }
    }
    
    func present(board:Board) {
        for i in 0..<rows {
            for j in 0..<cols {
                let fieldState = board.getFieldState(row: i, collumn: j)
                let numOfBlocks = fieldState.numOfBlocks()
                let hasPlayer = fieldState.playerOn()
                
                // present blocks
                if(numOfBlocks > 0) {
                    putBlocks(row: i, collumn: j, level: numOfBlocks - 1)
                }
                //present figure
                if(hasPlayer) {
                    addFigure(playerId: fieldState.getPlayer(), row: i, collumn: j)
                }
            }
        }
    }
}
