//
//  PlacesTableViewCell.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/17/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

protocol PlacesTableViewCellDelegate: class {
    func placeRemoved(sender: PlacesTableViewCell, location: Location)
}

class PlacesTableViewCell: UITableViewCell {
    
    var location: Location? {
        didSet {
            if let marker = location?.marker {
                if let title = marker.title {
                    lblTitle.text = "\(title)"
                    
                    closeButton.isHidden = (title == "Current Location")
                } else {
                    lblTitle.text = "-"
                }
            } else {
                lblTitle.text = "-"
            }
        }
    }
    
    weak var delegate: PlacesTableViewCellDelegate?
    
    let lblTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.sizeToFit()
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon_close_marker")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        
        // add close button
        addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
        
        // add title label
        addSubview(lblTitle)
        
        // constraints
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-[v1(32)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": lblTitle, "v1": closeButton]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": lblTitle]))
        
        addConstraint(NSLayoutConstraint(item: closeButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
    }
    
    @objc func closeButtonTapped() {
        print("closeButtonTapped")
        delegate?.placeRemoved(sender: self, location: self.location!)
    }

}
