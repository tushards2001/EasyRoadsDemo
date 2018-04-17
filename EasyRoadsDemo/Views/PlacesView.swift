//
//  PlacesView.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/17/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

protocol PlacesViewDelegate: class {
    func sliderTapped(sender: PlacesView, state: SliderState)
    func placeRemoved(sender: PlacesView, location: Location)
}

class PlacesView: UIView {
    
    var state: SliderState = SliderState.SliderStateClosed
    
    weak var delegate: PlacesViewDelegate?
    
    var locations = [Location]() {
        didSet {
            placesTableView.reloadData()
        }
    }
    
    let sliderButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon_places")
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 0.75)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let backPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 0.75)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func setupViews() {
        
        // slider button
        addSubview(sliderButton)
        sliderButton.addTarget(self, action: #selector(self.silderButtonTapped), for: .touchUpInside)
        //sliderButton.roundCorners([.topLeft, .bottomLeft], radius: 15)
        
        
        // search panel
        addSubview(backPanel)
        
       
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0][v1(60)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": backPanel, "v1": sliderButton]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0(60)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sliderButton]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": backPanel]))
        
        
        // placesTableView
        
        addSubview(placesTableView)
        self.placesTableView.register(PlacesTableViewCell.self, forCellReuseIdentifier: "cell")
        self.placesTableView.tableFooterView = UIView()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.reloadData()
        
        placesTableView.leftAnchor.constraint(equalTo: self.backPanel.leftAnchor, constant: 16).isActive = true
        placesTableView.topAnchor.constraint(equalTo: self.backPanel.topAnchor, constant: 16).isActive = true
        placesTableView.rightAnchor.constraint(equalTo: self.backPanel.rightAnchor, constant: -16).isActive = true
        placesTableView.bottomAnchor.constraint(equalTo: self.backPanel.bottomAnchor, constant: 16).isActive = true
    }
    
    @objc func silderButtonTapped() {
        print("silderButtonTapped")
        if state == SliderState.SliderStateClosed {
            delegate?.sliderTapped(sender: self, state: SliderState.SliderStateOpened)
            self.sliderButton.setImage(UIImage(named: "icon_close"), for: .normal)
        } else {
            delegate?.sliderTapped(sender: self, state: SliderState.SliderStateClosed)
            self.sliderButton.setImage(UIImage(named: "icon_places"), for: .normal)
        }
    }
    
}


// MARK:- TableView Delegate
extension PlacesView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlacesTableViewCell
        
        if let location = locations[indexPath.row] as? Location {
            cell.location = location
        } else {
            cell.textLabel?.text = "-"
        }
        
        
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 50
     }*/
    
}

extension PlacesView: PlacesTableViewCellDelegate {
    
    func placeRemoved(sender: PlacesTableViewCell, location: Location) {
        delegate?.placeRemoved(sender: self, location: location)
    }
    
}
