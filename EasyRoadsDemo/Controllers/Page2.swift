//
//  Page2.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

class Page2: UIViewController {
    
    var funFacts = [FunFact]()
    
    var topColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    var bottomColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 1.0)
    
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var lblFunFacts: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Page2")
        
        createGradientLayer(topColor: topColor, bottomColor: bottomColor)
        
        initFunFacts()
        
        addFunFactView()
    }
    
    func createGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.backgroundView.layer.addSublayer(gradientLayer)
        
    }
    
    func initFunFacts() {
        
        let funFact1 = FunFact(withTitle: "Total Trips", imageName: "icon_briefcase", statistics: "160")
        funFacts.append(funFact1)
        
        let funFact2 = FunFact(withTitle: "Total Locations", imageName: "icon_map", statistics: "450")
        funFacts.append(funFact2)
        
        let funFact3 = FunFact(withTitle: "Total Attractions", imageName: "icon_location", statistics: "1300")
        funFacts.append(funFact3)
        
        let funFact4 = FunFact(withTitle: "Total Accommodations", imageName: "icon_home", statistics: "800")
        funFacts.append(funFact4)
        
        let funFact5 = FunFact(withTitle: "Total Activities", imageName: "icon_navigation", statistics: "60")
        funFacts.append(funFact5)
        
    }
    
    func addFunFactView() {
        
        let funFactView = FunFactsView(frame: CGRect.zero, funFacts: funFacts)
        funFactView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(funFactView)
        
        funFactView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        funFactView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        funFactView.topAnchor.constraint(equalTo: self.lblFunFacts.bottomAnchor, constant: 20).isActive = true
        funFactView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70).isActive = true
    }
    
}
