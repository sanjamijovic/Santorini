//
//  FileParser.swift
//  Santorini
//
//  Created by Sanja Mijovic on 1/4/19.
//  Copyright © 2019 Sanja Mijovic. All rights reserved.
//

import Foundation

class FileParser {
    var fileName:String
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    func parseInput() -> Board {
        let board = Board(rows: 5, collumns: 5, numOfPlayers: 2, numOfFiguresPerPlayer: 2)
        board.setCurrentPlayer(playerId: 0)
        do {
            print(Bundle.main)
            
            if let  filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
//                let text = try String(contentsOfFile: filePath, encoding: UTF8StringEncoding, error: nil)!
                let text = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
                let lines = text.components(separatedBy: "\n")
                
                for (index, line) in lines.enumerated() {
                    let positions = line.components(separatedBy: " ")
                    
                    if(index == 0 || index == 1) { // positioning figures
                        for position in positions {
                            if(position != ""){
                                let (row, collumn) = parseToken(token: position)
                                board.addFigure(playerId: index, row: row, collumn: collumn)
                                board.changeCurrentPlayer()
                            }
                        }
                    } else {
                            var rowFrom:Int = 0
                            var collumnFrom:Int = 0
                            var rowTo:Int
                            var collumnTo:Int
                            
                            for (index, position) in positions.enumerated() {
                                if(position != "") {
                                    if(index == 0) {
                                        (rowFrom, collumnFrom) = parseToken(token: position)
                                    } else if (index == 1) {
                                        (rowTo, collumnTo) = parseToken(token: position)
                                        board.moveFigure(rowFrom: rowFrom, collumnFrom: collumnFrom, rowTo: rowTo, collumnTo: collumnTo)
                                    } else if (index == 2) {
                                        let (rowBuild, collumnBuild) = parseToken(token: position)
                                        board.addBlock(row: rowBuild, collumn: collumnBuild)
                                        board.changeCurrentPlayer()
                                    } else {
                                        break
                                    }
                                }
                            }
                    }
                }
                
            }
        } catch {
            print(error.localizedDescription)
        }
        return board
    }
    
    func parseToken(token:String) -> (row:Int, collumn:Int) {
        let rowCharacter:Character = token[token.startIndex]
        let collumnCharacter:Character = token[token.index(after: token.startIndex)]
        
        
        let startingValue = Int(("a" as UnicodeScalar).value)
        let s = String(rowCharacter).lowercased()
        
        let uniCode = UnicodeScalar(s)
        let row:Int = Int(uniCode!.value) - startingValue // shift values to start at zero
        let collumn = Int(String(collumnCharacter))! - 1
        
        return(row, collumn)
    }
    
    func makeToken(row:Int, collumn:Int) -> String{
        let startingValue = Int(("A" as UnicodeScalar).value)
        var ret = String(Character(UnicodeScalar(startingValue + row)!))
        ret.append("\(collumn + 1)")
        return ret
    }
    
    private func makeText(moves:[[Field]]) -> String {
        var text:String = ""
        for (index, fields) in moves.enumerated() {
            if(index == 0 || index == 1) {
                let figureToken1 = makeToken(row: fields[0].getRow(), collumn: fields[0].getCollumn())
                let figureToken2 = makeToken(row: fields[1].getRow(), collumn: fields[1].getCollumn())
                let line = figureToken1 + " " + figureToken2 + "\n"
                text.append(line)
            } else {
                var line = ""
                for i in 0..<fields.count {
                    let token = makeToken(row: fields[i].getRow(), collumn: fields[i].getCollumn())
                    line.append(token + " ")
                }
                line.append("\n")
                text.append(line)
            }
        }
        return text
    }
    
    func write(moves:[[Field]]) {
        let fileManger = FileManager.default
        let DocumentDirURL = try! fileManger.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("FilePath: \(fileURL.path)")
        
        
        if fileManger.fileExists(atPath: fileURL.path){
            do{
                try fileManger.removeItem(atPath: fileURL.path)
            }catch let error {
                print("error occurred, here are the details:\n \(error)")
            }
        }
        
        let writeString = makeText(moves: moves)
        do {
            // Write to the file
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }
}
