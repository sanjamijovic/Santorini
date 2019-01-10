//
//  FieldState.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/31/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation

class Field {
    enum BlockState :Int {
        case EMPTY, ONE_BLOCK, TWO_BLOCKS, THREE_BLOCKS, TOWER
        
        func numOfBlocks() -> Int {
            return self.rawValue
        }
        
        func nextValue() -> BlockState {
            return BlockState(rawValue: self.rawValue + 1) ?? self
        }
    }
    
    private var blockState:BlockState
    private var hasPlayer:Bool
    private var playerId:Int
    private var row:Int
    private var collumn:Int
    
    init(field:Field) {
        self.blockState = field.blockState
        self.hasPlayer = field.hasPlayer
        self.playerId = field.playerId
        self.row = field.row
        self.collumn = field.collumn
    }
    
    init(row:Int = 0, collumn:Int = 0, blockState:BlockState? = BlockState.EMPTY, hasPlayer:Bool? = false, playerId:Int? = nil) {
        self.blockState = blockState!
        self.hasPlayer = hasPlayer!
        self.playerId = playerId ?? -1
        self.row = row
        self.collumn = collumn
    }
    
    func putPlayer(playerId:Int) {
        hasPlayer = true
        self.playerId = playerId
    }
    
    func removePlayer() -> Int{
        hasPlayer = false
        return playerId
    }
    
    func playerOn() -> Bool {
        return hasPlayer
    }
    
    func getPlayer() -> Int {
        if !hasPlayer {
            return -1
        }
        return playerId
    }
    
    func numOfBlocks() -> Int {
        return blockState.numOfBlocks()
    }
    
    func canPutFigure() -> Bool {
        if hasPlayer || blockState == BlockState.TOWER {
            return false
        }
        return true
    }
    
    func canBuild() -> Bool {
        if hasPlayer || blockState == BlockState.TOWER {
            return false
        }
        return true
    }
    
    func addBlock() {
        self.blockState = blockState.nextValue()
    }
    
    func getRow() -> Int {
        return row
    }
    
    func getCollumn() -> Int {
        return collumn
    }
    
    class func distance(field1 first:Field, field2 second:Field) -> Int{
        let dx = abs(first.getCollumn() - second.getCollumn())
        let dy = abs(first.getRow() - second.getRow())
        
        let diagonalMoves = min(dx, dy)
        let straightMoves = max(dx, dy) - diagonalMoves
        
        return diagonalMoves + straightMoves
    }
}
