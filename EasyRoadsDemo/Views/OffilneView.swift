//
//  OffilneView.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/5/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

class OfflineView: UIView {
    
    
    let blurEffect: UIBlurEffect = {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        return blur
    }()
    
    let imageViewNoCellular: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_no_cellular")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let imageViewNoWiFi: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_no_wifi")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let lblMessage: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        // background color
        self.backgroundColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 0.5)
        
        // blur view
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        // no connection icons
        addSubview(imageViewNoWiFi)
        addSubview(imageViewNoCellular)
        
        // message label
        addSubview(lblMessage)
        lblMessage.text = "You seems to have no internet connection. Make sure you are connected to WiFi or your mobile data is on"
        
        
        // constraints
        self.addConstraintsWithFormat(format: "H:|-30-[v0]-30-|", views: lblMessage)
        self.addConstraintsWithFormat(format: "V:[v0(\(frame.height/2))]-60-|", views: lblMessage)
        

        
        
        self.addConstraint(NSLayoutConstraint(item: imageViewNoWiFi, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.5, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: imageViewNoWiFi, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -50))
        
        self.imageViewNoWiFi.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.imageViewNoWiFi.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        
        self.addConstraint(NSLayoutConstraint(item: imageViewNoCellular, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.5, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: imageViewNoCellular, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 50))
        
        self.imageViewNoCellular.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.imageViewNoCellular.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
}
