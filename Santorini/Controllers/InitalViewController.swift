//
//  InitalView.swift
//  Santorini
//
//  Created by Sanja Mijovic on 12/18/18.
//  Copyright © 2018 Sanja Mijovic. All rights reserved.
//

import Foundation
import UIKit
import iOSDropDown

class InitalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignbackground()
    }
    
    func assignbackground(){
        let background = UIImage(named: "kopija")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    
}
