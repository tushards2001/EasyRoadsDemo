//
//  FunFactsView.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/4/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit

class FunFactsView: UIView {
    
    var funFacts = [FunFact]()
    
    let funFactTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    init(frame: CGRect, funFacts: [FunFact]) {
        super.init(frame: frame)
        self.funFacts = funFacts
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        addSubview(funFactTableView)
        funFactTableView.register(FunFactTableViewCell.self, forCellReuseIdentifier: "cell")
        funFactTableView.showsVerticalScrollIndicator = false
        funFactTableView.delegate = self
        funFactTableView.dataSource = self
        funFactTableView.tableFooterView = UIView()
        funFactTableView.separatorStyle = .none
        
        funFactTableView.reloadData()
        
        // add constraint
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[v0]-|", options: [], metrics: nil, views: ["v0": funFactTableView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: [], metrics: nil, views: ["v0": funFactTableView]))
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension FunFactsView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return funFacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FunFactTableViewCell
        
        let funFact = funFacts[indexPath.row]
        cell.funFact = funFact
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
