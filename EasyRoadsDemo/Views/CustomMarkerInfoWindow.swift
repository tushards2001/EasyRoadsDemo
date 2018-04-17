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
    func closeMarkerInfoWindow(_ sender: CustomMarkerInfoWindow, marker: GMSMarker)
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
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeMarkerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let closeMarkerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
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
        self.layer.masksToBounds = false
        
        // add title label
        addSubview(titleLabel)
        titleLabel.text = self.title
        
        // add remove button
        addSubview(removeMarkerButton)
        removeMarkerButton.addTarget(self, action: #selector(removeMarkerButtonTapped), for: .touchUpInside)
        
        // add close marker button
        addSubview(closeMarkerButton)
        closeMarkerButton.addTarget(self, action: #selector(closeMarkerButtonTapped), for: .touchUpInside)
        
        
        // add constraints
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0": titleLabel]))
        self.closeMarkerButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        self.removeMarkerButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        self.closeMarkerButton.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -4).isActive = true
        self.removeMarkerButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 4).isActive = true
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-[v1(30)]-|", options: [], metrics: nil, views: ["v0": titleLabel, "v1": removeMarkerButton]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-[v1(30)]-|", options: [], metrics: nil, views: ["v0": titleLabel, "v1": closeMarkerButton]))
        
        
        // add pointy triangle
        let triangle = TriangleView(frame: CGRect.zero)
        triangle.backgroundColor = .clear
        triangle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(triangle)
        
        triangle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        triangle.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        triangle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        triangle.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
    }
    
    @objc func removeMarkerButtonTapped() {
        delegate?.removeMarkerInfoWindow(self, marker: self.marker)
    }
    
    @objc func closeMarkerButtonTapped() {
        delegate?.closeMarkerInfoWindow(self, marker: self.marker)
    }
    
}
