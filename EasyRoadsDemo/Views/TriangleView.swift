//
//  TriangleView.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/17/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

class TriangleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxX))
        context.closePath()
        
        context.setFillColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
        context.fillPath()
    }
    
}
