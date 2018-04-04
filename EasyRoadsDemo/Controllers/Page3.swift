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

enum LocationAccessPermission: String {
    case denied
    case authorized
    case notDetermined
}

class Page3: UIViewController {
    
    var locationManager: CLLocationManager!
    
    var locationAccessPermission: LocationAccessPermission!
    
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
        btnGetStarted.setTitle("", for: .normal)
        
        
        print("Page3")
        
        createGradientLayer(topColor: topColor, bottomColor: bottomColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnGetStarted.isHidden = true
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
        
        if locationAccessPermission == LocationAccessPermission.authorized {
            delegate?.getStarted(sender: self)
        } else if locationAccessPermission == LocationAccessPermission.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationAccessPermission == LocationAccessPermission.denied {
            if let url = URL(string: UIApplicationOpenSettingsURLString){
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(url, completionHandler: nil)
                    print("\n--- in ios 10 ")
                } else{
                    UIApplication.shared.openURL(url)
                    print("\n--- in ios other than 10 ")
                }
            }
            
            /*if let url = URL(string: "prefs:root=Privacy&path=LOCATION/com.basicdas.EasyRoadsDemo") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            }*/
        }
        
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
            locationAccessPermission = LocationAccessPermission.notDetermined
            manager.requestWhenInUseAuthorization()
            //self.btnGetStarted.isHidden = false
            //self.btnGetStarted.setTitle("Allow Location Access", for: .normal)
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            //manager.startUpdatingLocation()
            locationAccessPermission = LocationAccessPermission.authorized
            self.btnGetStarted.isHidden = false
            self.btnGetStarted.setTitle("Get Started", for: .normal)
            print("Authorized")
            break
        case .authorizedAlways:
            // If always authorized
            //manager.startUpdatingLocation()
            locationAccessPermission = LocationAccessPermission.authorized
            self.btnGetStarted.isHidden = false
            self.btnGetStarted.setTitle("Get Started", for: .normal)
            print("Authorized Always")
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            locationAccessPermission = LocationAccessPermission.denied
            self.btnGetStarted.isHidden = false
            self.btnGetStarted.setTitle("Allow Location Access", for: .normal)
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            print("Denied")
            locationAccessPermission = LocationAccessPermission.denied
            self.btnGetStarted.isHidden = false
            self.btnGetStarted.setTitle("Allow Location Access", for: .normal)
            break
        default:
            break
        }
    }
    
}
