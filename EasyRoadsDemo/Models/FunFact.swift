//
//  FunFact.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import Foundation

class FunFact: NSObject {
    
    var factImageName: String!
    var factTitle: String!
    var factStatistics: String!
    
    init(withTitle factTitle: String, imageName factImageName: String, statistics factStatistics: String) {
        super.init()
        
        self.factTitle = factTitle
        self.factImageName = factImageName
        self.factStatistics = factStatistics
    }
    
}
