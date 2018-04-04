//
//  CustomMarkerInfoWindow.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import GoogleMaps

protocol CustomMarkerInfoWindowDelegate: class {
    func removeMarkerInfoWindow(_ sender: CustomMarkerInfoWindow, marker: GMSMarker)
}

class CustomMarkerInfoWindow: UIView {
    
    var marker: GMSMarker!
    var title: String!
    
    weak var delegate: CustomMarkerInfoWindowDelegate?
    
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.sizeToFit()
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeMarkerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.3), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(frame: CGRect, marker: GMSMarker, title: String) {
        super.init(frame: frame)
        
        self.marker = marker
        self.title = title
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        setupView()
    }
    
    func setupView() {
        
        self.backgroundColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        // add title label
        addSubview(titleLabel)
        titleLabel.text = self.title
        
        // add remove button
        addSubview(removeMarkerButton)
        removeMarkerButton.addTarget(self, action: #selector(removeMarkerButtonTapped), for: .touchUpInside)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0": titleLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0": removeMarkerButton]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0(30)]-[v1]-|", options: [], metrics: nil, views: ["v0": titleLabel, "v1": removeMarkerButton]))
    }
    
    @objc func removeMarkerButtonTapped() {
        delegate?.removeMarkerInfoWindow(self, marker: self.marker)
    }
    
}
