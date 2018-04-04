//
//  SearchView.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import GooglePlaces

public enum SliderState: String {
    case SliderStateOpened
    case SliderStateClosed
}

protocol SearchViewDelegate: class {
    func sliderTapped(sender: SearchView, state: SliderState)
    func searchBarTextChanged(sender: SearchView, searchString: String)
    func predictionSelected(sender: SearchView, prediction: GMSAutocompletePrediction)
    func clearMap(sender: SearchView)
}

class SearchView: UIView {
    
    var state: SliderState = SliderState.SliderStateClosed
    
    var predictions = [GMSAutocompletePrediction]()
    
    weak var delegate: SearchViewDelegate?
    
    let sliderButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon_search")
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 0.75)
        //button.addTarget(self, action: #selector(), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let clearAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear All", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let searchPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 0.75)
        //view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchBar: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.backgroundColor = UIColor.clear
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.textColor = UIColor(white: 1.0, alpha: 0.7)
        textField.placeholder = "Search Place..."
        textField.isUserInteractionEnabled = true
        textField.isExclusiveTouch = true
        textField.allowsEditingTextAttributes = true
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        textField.clearsOnBeginEditing = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        addSubview(sliderButton)
        sliderButton.addTarget(self, action: #selector(self.silderButtonTapped), for: .touchUpInside)
        sliderButton.roundCorners([.topLeft, .bottomLeft], radius: 15)
        
        
        addSubview(searchPanel)
        
        
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0(60)][v1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sliderButton, "v1": searchPanel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0(60)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sliderButton]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": searchPanel]))
        
        
        
        
        addSubview(searchBar)
        searchBar.delegate = self
        searchBar.setLeftPaddingPoints(10)
        searchBar.setRightPaddingPoints(50)
        searchBar.attributedPlaceholder = NSAttributedString(string: "Search Place...",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBar.addTarget(self, action: #selector(textFieldDidTap(_:)), for: .touchUpInside)
        
        
        // search bar
        searchBar.leftAnchor.constraint(equalTo: self.searchPanel.leftAnchor, constant: 16).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.searchPanel.topAnchor, constant: 16).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.searchPanel.rightAnchor, constant: -16).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[v0(40)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": searchBar]))
        
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-16-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": searchBar]))
        
        
        // clear button
        
        addSubview(clearAllButton)
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped(_:)), for: .touchUpInside)
        clearAllButton.centerXAnchor.constraint(equalTo: self.searchPanel.centerXAnchor).isActive = true
        clearAllButton.bottomAnchor.constraint(equalTo: self.searchPanel.bottomAnchor, constant: -16).isActive = true
        clearAllButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        clearAllButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        // placesTableView
        
        addSubview(placesTableView)
        self.placesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.placesTableView.tableFooterView = UIView()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.reloadData()
        
        placesTableView.leftAnchor.constraint(equalTo: self.searchPanel.leftAnchor, constant: 8).isActive = true
        placesTableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 16).isActive = true
        placesTableView.rightAnchor.constraint(equalTo: self.searchPanel.rightAnchor, constant: -8).isActive = true
        placesTableView.bottomAnchor.constraint(equalTo: self.clearAllButton.topAnchor, constant: -16).isActive = true
        
    }
    
    @objc func clearAllButtonTapped(_ sender: UIButton) {
        searchBar.text = ""
        predictions.removeAll()
        placesTableView.reloadData()
        delegate?.clearMap(sender: self)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            delegate?.searchBarTextChanged(sender: self, searchString: textField.text!)
        }
    }
    
    @objc func textFieldDidTap(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    @objc func silderButtonTapped() {
        print("silderButtonTapped")
        if state == SliderState.SliderStateClosed {
            delegate?.sliderTapped(sender: self, state: SliderState.SliderStateOpened)
            //searchBar.becomeFirstResponder()
        } else {
            delegate?.sliderTapped(sender: self, state: SliderState.SliderStateClosed)
            //searchBar.resignFirstResponder()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sliderButton.roundCorners([.topLeft, .bottomLeft], radius: 15)
    }
    
    
    public func showKeyboard() {
        self.searchBar.becomeFirstResponder()
    }
    
    public func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    public func updatePredictionsData(withArray data:[GMSAutocompletePrediction]) {
        predictions.removeAll()
        predictions = data
        self.placesTableView.reloadData()
    }
    
    
}

extension SearchView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let prediction = predictions[indexPath.row] as? GMSAutocompletePrediction {
            cell.textLabel?.text = "\(prediction.attributedPrimaryText.string)"
            cell.detailTextLabel?.text = "\(String(describing: prediction.attributedSecondaryText?.string))"
        } else {
            cell.textLabel?.text = "-"
        }
        
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prediction = predictions[indexPath.row] as? GMSAutocompletePrediction {
            delegate?.predictionSelected(sender: self, prediction: prediction)
        }
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }*/
    
}

extension SearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
}

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
