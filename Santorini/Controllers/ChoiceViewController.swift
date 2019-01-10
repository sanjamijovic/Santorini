//
//  ChoiceViewController.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/18/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import UIKit

class ChoiceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var readFileButton: UIButton!
    
    var readFiles:Bool = false
    
    let values = [
        ["Two players", "Player vs. AI", "AI vs AI"],
        ["Low", "Medium", "High"],
        ["Iterative", "All"]
    ]
    
    var type: String = "Player vs. AI"
    var level: String = "Low"
    var iteration:String = "Iterative"
    
    var presentLevel:Bool = false
    var presentIterationType:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        picker.delegate = self
        picker.dataSource = self
        readFileButton.addTarget(self, action: #selector(readFileClicked), for: .touchUpInside)
    }
    
    @objc func readFileClicked() {
        readFiles = true
    }
    
    func numberOfComponents(in pickerView : UIPickerView) -> Int{
        if(presentLevel && presentIterationType) {
            return 3
        } else if(presentLevel) {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return values[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            type = values[0][row]
        } else if component == 1{
            level = values[1][row]
        } else {
            iteration = values[2][row]
        }
        
        if(type == "Player vs. AI" || type == "AI vs AI") {
            presentLevel = true
        } else {
            presentLevel = false
        }
        
        if(type == "AI vs AI") {
            presentIterationType = true
        } else {
            presentIterationType = false
        }
        
        pickerView.reloadAllComponents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc?.readFile = readFiles
            switch(type) {
            case "Player vs. AI":
                vc?.type = GameViewController.GameType.onePlayer
                break
            case "Two players":
                vc?.type = GameViewController.GameType.twoPlayers
                break
            case "AI vs AI":
                vc?.type = GameViewController.GameType.AIGame
                if(iteration == "Iterative") {
                    vc?.iteration = true
                } else {
                    vc?.iteration = false
                }
                break
            default:
                break
            }
            
            switch(level) {
            case "Low":
                vc?.level = GameViewController.GameLevel.low
                break
            case "Medium":
                vc?.level = GameViewController.GameLevel.medium
                break
            case "High":
                vc?.level = GameViewController.GameLevel.high
                break
            default:
                break
            }
        }

    }

}
