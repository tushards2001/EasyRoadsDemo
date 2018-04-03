//
//  Page1.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import Foundation

class Page1: UIViewController {
    
    let easyRoadLabel: UILabel = {
        let label = UILabel()
        label.text = "EasyRoads"
        label.textAlignment = .center
        label.font = UIFont(name: "Pattaya-Regular", size: 48)
        //label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var topColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    var bottomColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 1.0)
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        print("Page1")
        
        createGradientLayer(topColor: topColor, bottomColor: bottomColor)
        
        /*view.addSubview(easyRoadLabel)
        
        self.easyRoadLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        self.easyRoadLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        self.easyRoadLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        self.easyRoadLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true*/
    }
    
    func createGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.backgroundView.layer.addSublayer(gradientLayer)
        
    }
    
}

