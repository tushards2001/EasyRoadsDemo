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

enum OptimizationState: String {
    case show
    case dontShow
}

protocol SearchViewDelegate: class {
    func sliderTapped(sender: SearchView, state: SliderState)
    func searchBarTextChanged(sender: SearchView, searchString: String)
    func predictionSelected(sender: SearchView, prediction: GMSAutocompletePrediction)
    func clearMap(sender: SearchView)
    func optimizeRoutes(sender: SearchView, optimization: OptimizationState)
}

class SearchView: UIView {
    
    var state: SliderState = SliderState.SliderStateClosed
    var optimizedState = OptimizationState.dontShow
    
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
    
    let optimizeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon_unchecked")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 10)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("Optimize", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let clearAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear All", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .right
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let searchPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 0.75)
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
        textField.textColor = UIColor.white
        textField.placeholder = "Search Place..."
        textField.isUserInteractionEnabled = true
        textField.clearButtonMode = UITextFieldViewMode.always
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
        
        // slider button
        addSubview(sliderButton)
        sliderButton.addTarget(self, action: #selector(self.silderButtonTapped), for: .touchUpInside)
        sliderButton.roundCorners([.topLeft, .bottomLeft], radius: 15)
        
        
        // search panel
        addSubview(searchPanel)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0(60)][v1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sliderButton, "v1": searchPanel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0(60)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": sliderButton]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": searchPanel]))
        
        
        
        // search bar
        addSubview(searchBar)
        searchBar.delegate = self
        searchBar.setLeftPaddingPoints(10)
        searchBar.setRightPaddingPoints(50)
        searchBar.attributedPlaceholder = NSAttributedString(string: "Search Place...",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBar.addTarget(self, action: #selector(textFieldDidTap(_:)), for: .touchUpInside)
        
        // constraints
        searchBar.leftAnchor.constraint(equalTo: self.searchPanel.leftAnchor, constant: 16).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.searchPanel.topAnchor, constant: 16).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.searchPanel.rightAnchor, constant: -16).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        
        // clear button
        addSubview(clearAllButton)
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped(_:)), for: .touchUpInside)
        clearAllButton.rightAnchor.constraint(equalTo: self.searchPanel.rightAnchor, constant: -8).isActive = true
        clearAllButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 8).isActive = true
        clearAllButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        clearAllButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        
        // optimize button
        addSubview(optimizeButton)
        optimizeButton.addTarget(self, action: #selector(toggleOptimizeState(_:)), for: .touchUpInside)
        optimizeButton.leftAnchor.constraint(equalTo: self.searchPanel.leftAnchor, constant: 16).isActive = true
        optimizeButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 8).isActive = true
        optimizeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        optimizeButton.rightAnchor.constraint(equalTo: self.clearAllButton.leftAnchor, constant: -8).isActive = true
        
        
        // placesTableView
        
        addSubview(placesTableView)
        self.placesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.placesTableView.tableFooterView = UIView()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.reloadData()
        
        placesTableView.leftAnchor.constraint(equalTo: self.searchPanel.leftAnchor, constant: 8).isActive = true
        placesTableView.topAnchor.constraint(equalTo: self.clearAllButton.bottomAnchor, constant: 16).isActive = true
        placesTableView.rightAnchor.constraint(equalTo: self.searchPanel.rightAnchor, constant: -8).isActive = true
        placesTableView.bottomAnchor.constraint(equalTo: self.searchPanel.bottomAnchor, constant: 0).isActive = true
        
    }
    
    @objc func toggleOptimizeState(_ sender: UIButton) {
        if optimizedState == OptimizationState.show {
            optimizedState = OptimizationState.dontShow
            optimizeButton.setImage(UIImage(named: "icon_unchecked"), for: .normal)
        } else {
            optimizedState = OptimizationState.show
            optimizeButton.setImage(UIImage(named: "icon_checked"), for: .normal)
        }
    }
    
    @objc func clearAllButtonTapped(_ sender: UIButton) {
        searchBar.text = ""
        predictions.removeAll()
        placesTableView.reloadData()
        
        delegate?.clearMap(sender: self)
        self.sliderButton.setImage(UIImage(named: "icon_search"), for: .normal)
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
            self.sliderButton.setImage(UIImage(named: "icon_close"), for: .normal)
            self.searchBar.text = ""
            self.predictions.removeAll()
            self.placesTableView.reloadData()
        } else {
            delegate?.sliderTapped(sender: self, state: SliderState.SliderStateClosed)
            self.sliderButton.setImage(UIImage(named: "icon_search"), for: .normal)
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
            self.sliderButton.setImage(UIImage(named: "icon_search"), for: .normal)
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




