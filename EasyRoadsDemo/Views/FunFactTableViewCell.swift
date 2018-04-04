//
//  FunFactTableViewCell.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

class FunFactTableViewCell: UITableViewCell {
    
    var funFact: FunFact? {
        didSet {
            
            if let imageName = funFact?.factImageName {
                iconImageView.image = UIImage(named: imageName)
            }
            
            if let title = funFact?.factTitle {
                lblTitle.text = title
            }
            
            if let statistics = funFact?.factStatistics {
                lblStatistics.text = statistics
            }
            
        }
    }
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let lblTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 0.5)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.sizeToFit()
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblStatistics: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.sizeToFit()
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        //add image view
        addSubview(iconImageView)
        
        // add title label
        addSubview(lblTitle)
        
        // add statistics label
        addSubview(lblStatistics)
        
        // add constraints
        self.addConstraintsWithFormat(format: "H:|-20-[v0(50)]-20-[v1]-20-|", views: iconImageView, lblTitle)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.addConstraintsWithFormat(format: "V:[v0(20)]-2-[v1(36)]-|", views: lblTitle, lblStatistics)
        
        addConstraint(NSLayoutConstraint(item: lblStatistics, attribute: .left, relatedBy: .equal, toItem: lblTitle, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: lblStatistics, attribute: .right, relatedBy: .equal, toItem: lblTitle, attribute: .right, multiplier: 1, constant: 0))
    }

}
