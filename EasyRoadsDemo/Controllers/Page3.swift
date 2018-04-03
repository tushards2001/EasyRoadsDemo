//
//  Page3.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import CoreLocation

protocol Page3Delegate: class {
    func getStarted(sender: Page3)
}

class Page3: UIViewController {
    
    var locationManager: CLLocationManager!
    
    var topColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    var bottomColor = UIColor(red: 43.0/255.0, green: 107.0/255.0, blue: 132.0/255.0, alpha: 1.0)
    
    
    @IBOutlet weak var btnGetStarted: UIButton!
    weak var delegate: Page3Delegate?
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnGetStarted.layer.cornerRadius = 3
        btnGetStarted.layer.masksToBounds = true
        btnGetStarted.layer.borderColor = UIColor.white.cgColor
        btnGetStarted.layer.borderWidth = 1.0
        
        print("Page3")
        
        createGradientLayer(topColor: topColor, bottomColor: bottomColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        /*if !isLoacationServiceEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }*/
    }
    
    func isLoacationServiceEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    @IBAction func actionGetStarted(_ sender: UIButton) {
        delegate?.getStarted(sender: self)
    }
    
    func createGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        self.backgroundView.layer.addSublayer(gradientLayer)
        
    }
    
}

extension Page3: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
}
