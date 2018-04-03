//
//  MapViewController.swift
//  EasyRoadsDemo
//
//  Created by MacBookPro on 4/3/18.
//  Copyright © 2018 basicdas. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var searchView: SearchView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //initLocationManager()
        
        setupGoogleMap()
        
        
        setupStatusBar()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupSearchView()
    }
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupGoogleMap() {
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: 19.2793524032638, longitude: 72.8749670740896, zoom: 10.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 19.2793524032638, longitude: 72.8749670740896)
        marker.title = "You"
        marker.snippet = "You are here"
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupStatusBar() {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 44.0/255.0, green: 79.0/255.0, blue: 111.0/255.0, alpha: 1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
    }
    
    func setupSearchView() {
        searchView = SearchView(frame: CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height))
        self.view.addSubview(searchView)
        searchView.delegate = self
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension MapViewController: SearchViewDelegate {
    
    func sliderTapped(sender: SearchView, state: SliderState) {
        if state == SliderState.SliderStateOpened {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.searchView.frame = CGRect(x: 10, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.searchView.state = SliderState.SliderStateOpened
                self.searchView.showKeyboard()
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.searchView.frame = CGRect(x: UIScreen.main.bounds.width - 60 - 8, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            }, completion: { (finished) in
                self.searchView.state = SliderState.SliderStateClosed
                self.searchView.dismissKeyboard()
            })
            
        }
    }
    
    func searchBarTextChanged(sender: SearchView, searchString: String) {
        print("\(searchString)")
        
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchString, bounds: nil, filter: nil) { (results, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                for result in results! {
                    if let result = result as? GMSAutocompletePrediction {
                        //print("\(result.attributedFullText.string)")
                        print("\(String(describing: result.placeID))")
                    }
                }
            }
        }
        
        placeClient.lookUpPlaceID("ElJNaXJhIFJvYWQgRWFzdCwgQUcgTmFnYXIsIE1JREMsIE1pcmEgUm9hZCBFYXN0LCBNaXJhIEJoYXlhbmRhciwgTWFoYXJhc2h0cmEsIEluZGlh") { (place, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            } else {
                print("\(String(describing: place?.coordinate.latitude))/\(String(describing: place?.coordinate.longitude))")
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        print("\(location.coordinate.latitude)/\(location.coordinate.longitude)")
    }
    
}
